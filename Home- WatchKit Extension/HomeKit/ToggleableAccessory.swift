//
// ToggleableAccessory.swift
// Home- WatchKit Extension
//
// 🖌 by Q on 2020-10-04.
//

struct ToggleableAccessory {
    enum State {
        case on
        case off
        case unresponsive
    }
    let name: String
    let state: State
    
    let action: () -> Void
    
    init(name: String, on: Bool, isResponsive: Bool, action: @escaping () -> Void) {
        self.name = name
        
        if isResponsive {
            self.state = on ? .on : .off
        } else {
            self.state = .unresponsive
        }
        
        self.action = action
    }
}
