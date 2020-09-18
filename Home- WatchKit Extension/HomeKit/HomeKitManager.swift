//
// HomeKitManager.swift
// Home+ WatchKit Extension
//
// 🖌 by Q on 2020-09-15.
//

import HomeKit

struct Accessory {
    
}

struct Home {
    
    func getAccessories() -> [HMAccessory]? {
        let homes = HMHomeManager().homes
        guard let accessories = HMHomeManager().primaryHome?.accessories else { return nil }
        
        accessories[0].services.first?.characteristics
        return nil
    }
}
