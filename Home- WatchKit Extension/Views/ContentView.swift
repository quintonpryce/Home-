//
// ContentView.swift
// Home+ WatchKit Extension
//
// 🖌 by Q on 2020-09-15.
//

import SwiftUI

struct ContentView: View {
    let dataSource: RowDataSource
    
    var scrollViewContent: some View {
        ForEach(dataSource.rows) { row in
            
            HStack(alignment: .firstTextBaseline, spacing: 8) {
                Spacer(minLength: 1)
                
                AccessoryView(row.columnOneModel); AccessoryView(row.columnTwoModel)
                
                Spacer(minLength: 1)
            }.listRowBackground(Color.clear)
        }
    }
    
    var body: some View {
        VStack {
            Spacer(minLength: 1)
            
            scrollViewContent
            
            ScrollView {
                Spacer(minLength: 4)
                
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(dataSource: RowDataSource([
            AccessoryModel(id: 1, name: "Dining Room", imageName: "circle", on: false, action: { }),
            AccessoryModel(id: 2, name: "Living Room", imageName: "square", on: false, action: { }),
            AccessoryModel(id: 3, name: "Garage", imageName: "triangle", on: true, action: { }),
            AccessoryModel(id: 4, name: "Kitchen", imageName: "circle", on: true, action: { }),
            AccessoryModel(id: 5, name: "Bathroom", imageName: "square.fill", on: true, action: { }),
            AccessoryModel(id: 6, name: "Kids Room", imageName: "triangle", on: true, action: { })
        ]))
    }
}
