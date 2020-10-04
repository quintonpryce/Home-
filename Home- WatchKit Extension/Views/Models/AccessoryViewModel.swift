//
// AccessoryViewModel.swift
// Home- WatchKit Extension
//
// 🖌 by Q on 2020-09-17.
//

import SwiftUI

struct AccessoryViewModel: Identifiable {
    var id: Int
    
    let name: String
    let on: Bool
    
    let action: () -> Void
    
    // Empty model.
    init(id: Int) {
        self.id = id
        self.name = ""
        
        self.on = false
        self.action = { }
    }
    
    init(id: Int, accessory: Accessory) {
        self.id = id
        self.name = accessory.name
        self.on = accessory.on
        self.action = accessory.action
    }
    
    func toggle() {
        action()
    }
}
