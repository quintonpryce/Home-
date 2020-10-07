//
// HomeKitManager.swift
// Home+ WatchKit Extension
//
// 🖌 by Q on 2020-09-15.
//

import HomeKit

protocol HomeObserver: AnyObject {
    func didUpdateAccessories(_ accessories: [Accessory])
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
        var accessories: [Accessory] = []
        
        guard let home = homeManager.primaryHome else { return }
        
        let primaryServices: [HMService] = home.accessories.flatMap { accessory -> [HMService] in
            accessory.services.filter { $0.isPrimaryService }
        }
        
        let toggleableCharacterstics: [HMCharacteristic] = primaryServices.flatMap { service -> [HMCharacteristic] in
            service.characteristics.filter { $0.value is Bool }
        }
        
        toggleableCharacterstics.forEach { characteristic in
            guard let value = characteristic.value as? Bool,
                  let service = characteristic.service else { return }
            
            let name = service.name
            let updateValue = {
                characteristic.writeValue(!value) { [weak self] error in
                    print("characterstic error: " + error.debugDescription)
                    self?.updateAccessories()
                }
            }
            
            let action = service.isUserInteractive ? updateValue : updateAccessories
            
            let accessory = Accessory(
                name: name,
                on: value,
                isResponsive: service.isUserInteractive,
                action: action
            )
            accessories.append(accessory)
        }
        
        observer?.didUpdateAccessories(accessories)
    }
}

// MARK: - HMHomeManagerDelegate
extension PrimaryHome: HMHomeManagerDelegate {
    func homeManagerDidUpdateHomes(_ manager: HMHomeManager) {
        updateAccessories()
    }
}
