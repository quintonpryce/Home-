//
// HomeKitManager.swift
// Home+ WatchKit Extension
//
// 🖌 by Q on 2020-09-15.
//

import HomeKit

struct Accessory {
    let name: String
    let on: Bool
    
    let action: () -> Void
}

protocol HomeObserver: AnyObject {
    func didUpdateAccessories(_ accessories: [Accessory])
}

protocol Home: AnyObject {
    var observer: HomeObserver? { get set }
}

class PrimaryHome: NSObject, HMHomeManagerDelegate, Home {
    
    weak var observer: HomeObserver?
    
    let homeManager = HMHomeManager()
    
    override init() {
        super.init()
        homeManager.delegate = self
    }
    
    func homeManagerDidUpdateHomes(_ manager: HMHomeManager) {
        var accessories: [Accessory] = []
        
        manager.primaryHome!.accessories.forEach { accessory in
            accessory.services.filter { service in
                service.isPrimaryService
                
            }.forEach { primaryService in
                primaryService.characteristics.filter { $0.value is Bool }.forEach { characteristic in
                    print(primaryService.name)
                    guard let value = characteristic.value as? Bool else { return }
                    let action = {
                        characteristic.writeValue(!value) { error in
                            print(error.debugDescription)
                        }
                    }
                    accessories.append(Accessory(name: primaryService.name, on: value, action: action))
                }
            }
        }
        observer?.didUpdateAccessories(accessories)
    }
}
