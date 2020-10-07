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
    
    private let action: () -> Void
    
    var state: Accessory.State {
        willSet { objectWillChange.send() }
    }
    
    var textColor: Color {
        switch state {
        case .on: return .black
        case .off: return .white
        case .unresponsive: return .white
        }
    }

    var backgroundColor: Color {
        switch state {
        case .on: return .lightGray
        case .off: return .black
        case .unresponsive: return .black
        }
    }
    
    var accentColor: Color {
        switch state {
        case .on: return .clear
        case .off: return .yellow
        case .unresponsive: return .red
        }
    }
    
    var imageName: String {
        switch state {
        case .on: return "lightbulb.fill"
        case .off: return "lightbulb"
        case .unresponsive: return "exclamationmark.triangle.fill"
        }
    }
    
    // Empty model.
    init(id: Int) {
        self.id = id
        
        self.name = ""
        self.state = .unresponsive
        
        self.action = { }
    }
    
    init(id: Int, accessory: Accessory) {
        self.id = id
        
        self.name = accessory.name
        self.state = accessory.state
        
        self.action = accessory.action
    }
    
    func toggle() {
        switch state {
        case .on: state = .off
        case .off: state = .on
        case .unresponsive: break
        }
        
        action()
    }
}

private extension Color {
    static var lightGray: Color { Color.white.opacity(0.95) }
}


struct AccessoryViewModel_Previews: PreviewProvider {
    static var previews: some View {
        let accessoryOn = Accessory(name: "Test name", on: true, isResponsive: true, action: { })
        let accessoryOff = Accessory(name: "Test name", on: false, isResponsive: true, action: { })
        let accessoryNotResponsive = Accessory(name: "Test name", on: true, isResponsive: false, action: { })
        VStack {
            AccessoryView(AccessoryViewModel(id: 0, accessory: accessoryOn))
            AccessoryView(AccessoryViewModel(id: 0, accessory: accessoryOff))
            AccessoryView(AccessoryViewModel(id: 0, accessory: accessoryNotResponsive))
        }
    }
}
