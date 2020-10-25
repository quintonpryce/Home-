//
// HomeKitManager.swift
// Home+ WatchKit Extension
//
// 🖌 by Q on 2020-09-15.
//

import HomeKit

protocol HomeObserver: AnyObject {
    func didUpdateAccessories(_ toggleableAccessories: [ToggleableAccessory])
}

protocol Home: AnyObject {
    var observer: HomeObserver? { get set }
    var numberOfAccessoriesOn: Int { get }
    func updateAccessories()
}

class PrimaryHome: NSObject, Home {
    // MARK: - Properties
    static let shared: Home = PrimaryHome()
    
    weak var observer: HomeObserver?
    
    var numberOfAccessoriesOn: Int = 0 {
        didSet {
            DispatchQueue.main.async {
                ComplicationHomeProvider.shared.forceReloadComplications()
            }
        }
    }
    
    private var background = DispatchQueue(label: "Background thread", qos: .userInitiated)
    
    private let homeManager = HMHomeManager()
    
    /// If the set value is not empty, the observer is called informing `didUpdateAccessories(_:)`.
    private var toggleableAccessories: [UUID: ToggleableAccessory] = [:]
    
    // MARK: - Initialization
    override init() {
        super.init()
        homeManager.delegate = self
    }
    
    // MARK: - Methods
    
    /// Removes all accessories from `toggleableAccessories`. Fetches all the primary/boolean/writable/services and sets the dictionary.
    func updateAccessories() {
        /// TODO: There is a bug that if you quickly click an accessory when you foreground, it will flicker.
        /// The issue is that we request a new value before the response comes back for the given accessory.
        guard let home = homeManager.primaryHome else { return }
        
        var toggleableAccessories: [UUID: ToggleableAccessory] = [:]
        
        let primaryServices = home.primaryServices
        
        // Filter out every characterstic that is either not a boolean, or is not writable.
        let toggleableCharacterstics = primaryServices.flatMap { service -> [HMCharacteristic] in
            service.characteristics.filter { $0.isBool && $0.isWriteable }
        }
        
        toggleableCharacterstics.forEach { $0.service?.accessory?.delegate = self }
        
        // Build the ToggleableAccessory and append it to the toggleableAccessories dictionary.
        toggleableCharacterstics.forEach { characteristic in
            guard let toggleableAccessory = buildToggleableAccessory(characteristic) else { return }
            requestUpdatedValue(for: characteristic)
            
            toggleableAccessories[characteristic.uniqueIdentifier] = toggleableAccessory
            
            // need to queue up updating values. Maybe a loading screen?
        }
        
        self.toggleableAccessories.removeAll()
        self.toggleableAccessories = toggleableAccessories
    }
    
    private func updateNumberOfAccessoriesOn() {
        background.async { [weak self] in
            guard let self = self else { return }
            
            let numberOfAccessoriesOnNow = Array(self.toggleableAccessories.values)
                .filter { $0.state == .on }.count
            
            guard numberOfAccessoriesOnNow != self.numberOfAccessoriesOn else { return }
            self.numberOfAccessoriesOn = numberOfAccessoriesOnNow
        }
    }
    
    private func sendObserverUpdatedAccessories() {
        let sortedAccessoriesArray = Array(toggleableAccessories.values.sorted { $0.name <= $1.name })
        
        updateNumberOfAccessoriesOn()
        
        guard !sortedAccessoriesArray.isEmpty else { return }
            
        observer?.didUpdateAccessories(sortedAccessoriesArray)
    }
    
    // MARK: - Helpers

    /// Reads the characterstics most up-to-date value, and updates the characterstic.
    private func requestUpdatedValue(for characteristic: HMCharacteristic) {
        Log.i("Requested readValue started for \(characteristic.service?.name ?? "").")
        characteristic.readValue { [weak self] error in
            Log.i("Requested readValue completed for \(characteristic.service?.name ?? "").")
            self?.charactersticValueUpdated(characteristic, error: error)
        }
    }
    
    /// Grabs the existing accessory if it exists, if not it attempts to build one and set the value there.
    /// If we get an accessory we set the state and a new action and set it to the appropriate accessory.
    private func stateUpdated(for characteristic: HMCharacteristic, to state: ToggleableAccessory.State) {
        let existingToggleableAccessory = toggleableAccessories[characteristic.uniqueIdentifier]
        guard var toggleableAccessory = existingToggleableAccessory ?? buildToggleableAccessory(characteristic) else {
            return
        }
        Log.i("State updated for: \(String(describing: toggleableAccessories[characteristic.uniqueIdentifier]?.name)).")
        
        toggleableAccessory.state = state
        toggleableAccessory.action = createToggleAction(for: characteristic, state: state)
        
        toggleableAccessories[characteristic.uniqueIdentifier]?.isLoading = false
        toggleableAccessories[characteristic.uniqueIdentifier]?.state = state
        toggleableAccessories[characteristic.uniqueIdentifier]?.action = createToggleAction(for: characteristic, state: state)
        sendObserverUpdatedAccessories()
    }
    
    /// Updates the characterstics ToggleableAccessory based on the value after some update from the characterstic.
    private func charactersticValueUpdated(_ characteristic: HMCharacteristic, error: Error?) {
        guard let isOn = characteristic.value as? Bool, error == nil else {
            stateUpdated(for: characteristic, to: .unresponsive)
            return
        }
        
        stateUpdated(for: characteristic, to: isOn ? .on : .off)
    }
    
    /// Returns a closure that will toggle the characteristic's value. If the existing value is not a boolean,
    /// the accessory matching the characteristic is set to unresponsive.
    private func toggle(_ characteristic: HMCharacteristic) {
        guard let isOn = characteristic.value as? Bool else {
            self.stateUpdated(for: characteristic, to: .unresponsive)
            return
        }
        
        toggleableAccessories[characteristic.uniqueIdentifier]?.state = !isOn ? .on : .off
        
        characteristic.service?.accessory?.delegate = nil
        characteristic.writeValue(!isOn) { [weak self] error in
            guard let self = self else { return }
            self.charactersticValueUpdated(characteristic, error: error)
            characteristic.service?.accessory?.delegate = self
        }
    }
    
    private func createToggleAction(for characteristic: HMCharacteristic, state: ToggleableAccessory.State) -> () -> Void {
        let action = { [weak self] in
            guard let self = self else { return }
            
            switch state {
            case .unresponsive:
                self.requestUpdatedValue(for: characteristic)
                
            case .on, .off:
                self.toggle(characteristic)
            }
        }
        
        return action
    }
    
    private func buildToggleableAccessory(_ characteristic: HMCharacteristic) -> ToggleableAccessory? {
        guard let service = characteristic.service else { return nil }
        
        let name = service.name
        
        let state = characteristic.toggleableState
        
        let action = createToggleAction(for: characteristic, state: state)
        
        let toggleableAccessory = ToggleableAccessory(
            name: name,
            state: state,
            action: action,
            isLoading: true
        )
        
        return toggleableAccessory
    }
}

extension HMHome {
    /// Primary services are usually the service that interacts with the accessory.
    var primaryServices: [HMService] {
        let primaryServices = accessories.flatMap { accessory -> [HMService] in
            accessory.services.filter { $0.isPrimaryService }
        }
        
        return primaryServices
    }
}

// MARK: - HMHomeManagerDelegate
extension PrimaryHome: HMHomeManagerDelegate {
    func homeManagerDidUpdateHomes(_ manager: HMHomeManager) {
        updateAccessories()
    }
}

extension HMCharacteristic {
    var toggleableState: ToggleableAccessory.State {
        guard let isOn = value as? Bool, isReachable else {
            return .unresponsive
        }
        
        return isOn ? .on : .off
    }
    
    var isReachable: Bool {
        service?.accessory?.isReachable ?? false
    }
    
    var isBool: Bool {
        return metadata?.format == HMCharacteristicMetadataFormatBool
    }
    
    var isWriteable: Bool {
        return properties.contains(HMCharacteristicPropertyWritable)
    }
    
    var displayName: String {
        return metadata?.manufacturerDescription ?? localizedDescription
    }
    
    var supportsNotifications: Bool {
        properties.contains(HMCharacteristicPropertySupportsEventNotification)
    }
}

extension PrimaryHome: HMAccessoryDelegate {
    func accessory(
        _ accessory: HMAccessory,
        service: HMService,
        didUpdateValueFor characteristic: HMCharacteristic
    ) {
        Log.i("Delegate for \(characteristic.service?.name ?? "") triggered.")
        charactersticValueUpdated(characteristic, error: nil)
    }
}
