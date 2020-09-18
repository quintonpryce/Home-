//
// HostingController.swift
// Home+ WatchKit Extension
//
// 🖌 by Q on 2020-09-15.
//

import WatchKit
import Foundation
import SwiftUI

class HostingController: WKHostingController<ContentView> {
    override var body: ContentView {
        return ContentView(dataSource: RowDataSource([
            AccessoryModel(id: 1, name: "Dining Room", imageName: "circle", on: false, action: { }),
            AccessoryModel(id: 2, name: "Living Room", imageName: "square", on: false, action: { }),
            AccessoryModel(id: 3, name: "Garage", imageName: "triangle", on: true, action: { }),
            AccessoryModel(id: 4, name: "Kitchen", imageName: "circle", on: true, action: { }),
            AccessoryModel(id: 5, name: "Bathroom", imageName: "square.fill", on: true, action: { }),
            AccessoryModel(id: 6, name: "Kids Room", imageName: "triangle", on: true, action: { })
            
        ]))
    }
}
