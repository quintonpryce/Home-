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
            Accessory(name: "Dining Room", on: false, action: {  }),
            Accessory(name: "Living Room", on: false, action: { }),
            Accessory(name: "Garage", on: true, action: { }),
            Accessory(name: "Kitchen", on: true, action: { }),
            Accessory(name: "Bathroom", on: true, action: { })
        ])
    }
}

class HostingController: WKHostingController<ContentView> {
    let home = MockHome()
    
    override var body: ContentView {
        return ContentView(dataSource: RowDataSource(home))
    }
}
