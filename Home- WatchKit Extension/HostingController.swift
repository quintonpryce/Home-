//
// HostingController.swift
// Home+ WatchKit Extension
//
// 🖌 by Q on 2020-09-15.
//

import WatchKit
import Foundation
import SwiftUI

class MockHome: Home {
    var observer: HomeObserver?
    
    init() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.updateAccessories()
        }
    }
    
    func updateAccessories() {
        observer?.didUpdateAccessories([
            ToggleableAccessory(name: "Dining Room", on: false, isResponsive: true, action: {  }),
            ToggleableAccessory(name: "Living Room", on: false, isResponsive: true, action: { }),
            ToggleableAccessory(name: "Garage", on: true, isResponsive: false, action: { }),
        ])
    }
}

class HostingController: WKHostingController<ContentView> {
    let home = PrimaryHome()
    
    override var body: ContentView {
        return ContentView(dataSource: RowDataSource(home))
    }
}
