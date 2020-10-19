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
    
    var numberOfAccessoriesOn: Int {
        Array(toggleableAccessories.values).filter { $0.state == .on }.count
    }
    
    private let homeManager = HMHomeManager()
    
    /// If the set value is not empty, the observer is called informing `didUpdateAccessories(_:)`.
    var toggleableAccessories: [UUID: ToggleableAccessory] = [:] {
        didSet {
            let toggleableAccessoriesArray = Array(toggleableAccessories.values)
            
            guard !toggleableAccessoriesArray.isEmpty else { return }
            
            observer?.didUpdateAccessories(toggleableAccessoriesArray)
        }
    }
    
    // MARK: - Initialization
    override init() {
        super.init()
        homeManager.delegate = self
    }
    
    // MARK: - Methods
    
    /// Removes all accessories from `toggleableAccessories`. Fetches all the primary/boolean/writable/services and sets the dictionary.
    func updateAccessories() {
        guard let home = homeManager.primaryHome else { return }
        
        var toggleableAccessories: [UUID: ToggleableAccessory] = [:]
        
        let primaryServices = home.primaryServices
        
        // Filter out every characterstic that is either not a boolean, or is not writable.
        let toggleableCharacterstics = primaryServices.flatMap { service -> [HMCharacteristic] in
            service.characteristics.filter { $0.isBool && $0.isWriteable }
        }
        
        // Build the ToggleableAccessory and append it to the toggleableAccessories dictionary.
        toggleableCharacterstics.forEach { characteristic in
            guard let toggleableAccessory = buildToggleableAccessory(characteristic) else { return }
            
            toggleableAccessories[characteristic.uniqueIdentifier] = toggleableAccessory
            requestUpdatedValue(for: characteristic)
        }
        
        self.toggleableAccessories.removeAll()
        self.toggleableAccessories = toggleableAccessories
    }
    
    // MARK: - Helpers

    /// Reads the characterstics most up-to-date value, and updates the characterstic.
    private func requestUpdatedValue(for characteristic: HMCharacteristic) {
        characteristic.readValue { [weak self] error in
            self?.charactersticValueUpdated(characteristic, error: error)
        }
    }
    
    /// Updates the existing characterstic with the new state if it exists, if not it attempts to build one and set the value there.
    private func stateUpdated(for characteristic: HMCharacteristic, to state: ToggleableAccessory.State) {
        let existingToggleableAccessory = toggleableAccessories[characteristic.uniqueIdentifier]
        guard var toggleableAccessory = existingToggleableAccessory ?? buildToggleableAccessory(characteristic) else {
            return
        }
        
        toggleableAccessory.state = state
        toggleableAccessory.action = createAction(for: characteristic, state: state)
        toggleableAccessories[characteristic.uniqueIdentifier] = toggleableAccessory
        
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
        
        characteristic.writeValue(!isOn) { [weak self] error in
            self?.charactersticValueUpdated(characteristic, error: error)
        }
    }
    
    private func createAction(for characteristic: HMCharacteristic, state: ToggleableAccessory.State) -> () -> Void {
        return { [weak self] in
            guard let self = self else { return }
            switch state {
            case .unresponsive:
                self.requestUpdatedValue(for: characteristic)
            case .on, .off:
                self.toggle(characteristic)
            }
        }
    }
    
    private func buildToggleableAccessory(_ characteristic: HMCharacteristic) -> ToggleableAccessory? {
        guard let service = characteristic.service else { return nil }
        
        let name = service.name
        
        let state = characteristic.toggleableState
        
        let action = createAction(for: characteristic, state: state)
        
        let toggleableAccessory = ToggleableAccessory(
            name: name,
            state: state,
            action: action
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

private extension HMCharacteristic {
    var toggleableState: ToggleableAccessory.State {
        guard let isReachable = service?.accessory?.isReachable, isReachable,
              let isOn = value as? Bool
        else {
            return .unresponsive
        }
        
        return isOn ? .on : .off
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

private extension HMService {
    
}
