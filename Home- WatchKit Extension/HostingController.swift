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
    
    var numberOfAccessoriesOn: Int = 0
    
    init() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.updateAccessories()
        }
    }
    
    func updateAccessories() {
        observer?.didUpdateAccessories([
            ToggleableAccessory(name: "Dining Room", state: .on, action: {  }),
            ToggleableAccessory(name: "Living Room", state: .unresponsive, action: { }),
            ToggleableAccessory(name: "Garage", state: .off, action: { }),
        ])
    }
}

class HostingController: WKHostingController<ContentView> {
    override var body: ContentView {
        return ContentView(dataSource: RowDataSource(PrimaryHome.shared))
    }
}
