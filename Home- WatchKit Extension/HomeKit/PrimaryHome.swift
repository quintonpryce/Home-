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
    func updateAccessories()
}

class PrimaryHome: NSObject, Home {
    // MARK: - Properties
    weak var observer: HomeObserver?
    
    let homeManager = HMHomeManager()
    
    // MARK: - Initialization
    override init() {
        super.init()
        homeManager.delegate = self
    }
    
    // MARK: - Methods
    func updateAccessories() {
        var toggleableAccessories: [ToggleableAccessory] = []
        
        guard let home = homeManager.primaryHome else { return }
        
        let primaryServices = home.accessories.flatMap { accessory -> [HMService] in
            accessory.services.filter { $0.isPrimaryService }
        }
        
        let toggleableCharacterstics = primaryServices.flatMap { service -> [HMCharacteristic] in
            service.characteristics.filter { $0.isBool && $0.isWriteable }
        }
        
        toggleableCharacterstics.forEach { characteristic in
            guard let service = characteristic.service else { return }
            
            let name = service.name
            let value = characteristic.value as? Bool
            // Need to preform a read on this to get the up to date value.
//            characteristic.readValue { error in
//            }
            let updateValue: () -> Void = {
                guard let on = value else { return }
                characteristic.writeValue(!on) { [weak self] error in
                    print("characterstic error: " + error.debugDescription)
                    self?.updateAccessories()
                }
            }
            
            let action = characteristic.supportsNotifications ? updateValue : updateAccessories
            
            let toggleableAccessory = ToggleableAccessory(
                name: name,
                on: value ?? false,
                isResponsive: characteristic.supportsNotifications,
                action: action
            )
            toggleableAccessories.append(toggleableAccessory)
        }
        
        observer?.didUpdateAccessories(toggleableAccessories)
    }
}

// MARK: - HMHomeManagerDelegate
extension PrimaryHome: HMHomeManagerDelegate {
    func homeManagerDidUpdateHomes(_ manager: HMHomeManager) {
        updateAccessories()
    }
}

private extension HMCharacteristic {
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
