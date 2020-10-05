//
// RowDataSource.swift
// Home- WatchKit Extension
//
// 🖌 by Q on 2020-09-17.
//

import Foundation

class RowDataSource: ObservableObject {
    // MARK: - Types
    
    struct Row: Identifiable {
        let id: Int
        let columnOneModel: AccessoryViewModel
        let columnTwoModel: AccessoryViewModel? // Column 2 is optional in a row.
    }
    
    // MARK: - Properties
    @Published
    var rows: [Row] = []
    
    private let home: Home
    
    // MARK: - Initialization
    init( _ home: Home = PrimaryHome()) {
        self.home = home
        home.observer = self
    }
    
    // MARK: - Methods
    // TODO: Should this be in a delegate rather than a datasource?
    func forceUpdateAccessories() {
        home.updateAccessories()
    }
    
    private func updateRows(_ models: [AccessoryViewModel]) {
        guard !models.isEmpty else {
            self.rows = []
            return
        }
        
        let columnOneModels = models.filter { ($0.id + 1) % 2 == 0 }
        let columnTwoModels = models.filter { $0.id % 2 == 0 }
        
        var rows: [Row] = []
        
        (0...columnOneModels.count - 1).forEach {
            let columnOneModel = columnOneModels[$0]
            // If column two doesn't have the same number of models as column one, add an empty model
            let columnTwoModel = columnTwoModels.count > $0 ?
                columnTwoModels[$0] : nil
            
            
            let row = Row(id: $0, columnOneModel: columnOneModel, columnTwoModel: columnTwoModel)
            rows.append(row)
        }
        
        self.rows = rows
    }
}

// MARK: - HomeObserver
extension RowDataSource: HomeObserver {
    func didUpdateAccessories(_ accessories: [Accessory]) {
        var id = 0
        let viewModels = accessories.map { accessory -> AccessoryViewModel in
            id += 1
            return AccessoryViewModel(id: id, accessory: accessory)
        }
        
        updateRows(viewModels)
    }
}
