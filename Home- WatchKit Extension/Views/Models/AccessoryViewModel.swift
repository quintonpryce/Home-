//
// AccessoryViewModel.swift
// Home- WatchKit Extension
//
// 🖌 by Q on 2020-09-17.
//

import SwiftUI
import Combine

class AccessoryViewModel: Identifiable, ObservableObject {
    var objectWillChange = ObservableObjectPublisher()
    var id: Int
    
    let name: String
    var on: Bool {
        willSet {
            objectWillChange.send()
        }
    }
    private let action: () -> Void
    
    var textColor: Color { on ? .black : .white }
    
    private let lightGray = Color.white.opacity(0.95)
    var backgroundColor: Color { on ? lightGray : .black }
    var accentColor: Color { on ? .clear : .yellow }
    var imageName: String { on ? "lightbulb.fill" : "lightbulb" }
    
    // Empty model.
    init(id: Int) {
        self.id = id
        
        self.name = ""
        self.action = { }
        self.on = false
        
    }
    
    init(id: Int, accessory: Accessory) {
        self.id = id
        self.name = accessory.name
        self.action = accessory.action
        self.on = accessory.on
    }
    
    func toggle() {
        on = !on
        action()
    }
}
