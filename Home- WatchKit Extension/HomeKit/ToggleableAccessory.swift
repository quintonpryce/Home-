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
    var state: State
    
    var action: () -> Void
}
