//
// ToggleableAccessoryViewModel.swift
// Home- WatchKit Extension
//
// 🖌 by Q on 2020-09-17.
//

import SwiftUI
import Combine

class ToggleableAccessoryViewModel: Identifiable, ObservableObject {
    var objectWillChange = ObservableObjectPublisher()
    var id: Int
    
    let name: String
    
    private let action: () -> Void
    
    var state: ToggleableAccessory.State {
        willSet { objectWillChange.send() }
    }
    
    var isLoading: Bool = false
    
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
        case .off: return .primaryYellow
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
    
    init(id: Int, accessory: ToggleableAccessory) {
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
        
        isLoading = true
        
        action()
    }
}

private extension Color {
    static var lightGray: Color { Color.white.opacity(0.95) }
}


struct AccessoryViewModel_Previews: PreviewProvider {
    static var previews: some View {
        let accessoryOn = ToggleableAccessory(name: "Test name", state: .on, action: { })
        let accessoryOff = ToggleableAccessory(name: "Test name", state: .off, action: { })
        let accessoryNotResponsive = ToggleableAccessory(name: "Test name", state: .unresponsive, action: { })
        VStack {
            ToggleableAccessoryView(ToggleableAccessoryViewModel(id: 0, accessory: accessoryOn))
            ToggleableAccessoryView(ToggleableAccessoryViewModel(id: 0, accessory: accessoryOff))
            ToggleableAccessoryView(ToggleableAccessoryViewModel(id: 0, accessory: accessoryNotResponsive))
        }
    }
}
