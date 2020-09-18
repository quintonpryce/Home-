//
// AccessoryModel.swift
// Home- WatchKit Extension
//
// 🖌 by Q on 2020-09-17.
//

import SwiftUI

struct AccessoryModel: Identifiable {
    var id: Int
    
    let name: String
    let imageName: String
    let on: Bool
    
    let action: () -> Void
    
    // Empty model.
    init(id: Int) {
        self.id = id
        self.name = ""
        self.imageName = ""
        self.on = false
        self.action = { }
    }
    
    init(id: Int, name: String, imageName: String, on: Bool, action: @escaping () -> Void) {
        self.id = id
        self.name = name
        self.imageName = imageName
        self.on = on
        self.action = action
    }
}
