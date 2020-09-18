//
// RowDataSource.swift
// Home- WatchKit Extension
//
// 🖌 by Q on 2020-09-17.
//

import Foundation

struct RowDataSource {
    struct Row: Identifiable {
        let id: Int
        let columnOneModel: AccessoryModel
        let columnTwoModel: AccessoryModel
    }
    let rows: [Row]
    
    init(_ models: [AccessoryModel]) {
        Home().getAccessories()
        let columnOneModels = models.filter { ($0.id + 1) % 2 == 0 }
        let columnTwoModels = models.filter { $0.id % 2 == 0 }
        
        var rows: [Row] = []
        
        (0...columnOneModels.count - 1).forEach {
            let columnOneModel = columnOneModels[$0]
            // If column two doesn't have the same number of models as column one, add an empty model
            let columnTwoModel = columnTwoModels.count > $0 ?
                columnTwoModels[$0] : AccessoryModel(id: columnOneModel.id + 1)
            
            let row = Row(id: $0, columnOneModel: columnOneModel, columnTwoModel: columnTwoModel)
            rows.append(row)
        }
        
        self.rows = rows
    }
}
