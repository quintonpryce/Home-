//
// ContentView.swift
// Home+ WatchKit Extension
//
// 🖌 by Q on 2020-09-15.
//

import SwiftUI

struct ContentView: View {
    // MARK: - Properties
    @ObservedObject
    var dataSource: RowDataSource
    
    var noHomeContent: some View {
        VStack {
            Spacer()
            Text("Uh oh!")
            Spacer()
            Text("It doesn't look like you have any accessories in your home.\n\nPlease open your Home app on your iPhone to set it up.")
            .font(.system(size: 10))
                .lineLimit(10)
            Spacer()
        }
    }
    
    var homeContent: some View {
        ForEach(dataSource.rows) { row in
            
            HStack(alignment: .firstTextBaseline, spacing: 8) {
                Spacer(1)
                
                // Column 1
                ToggleableAccessoryView(row.columnOneModel)
                
                // Column 2
                if let columnTwoModel = row.columnTwoModel {
                    ToggleableAccessoryView(columnTwoModel)
                } else {
                    BlankAccessory()
                }
                
                Spacer(1)
            }.listRowBackground(Color.clear)
        }
    }
    
    // MARK: - Body
    var body: some View {
        VStack {
            if dataSource.rows.isEmpty {
                noHomeContent
            } else {
                ScrollView {
                    Spacer(2)
                    homeContent
                }
            }
        }
        .onAppear {
            dataSource.forceUpdateAccessories()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(dataSource: RowDataSource(MockHome()))
    }
}
