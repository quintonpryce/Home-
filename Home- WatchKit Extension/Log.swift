//
// Log.swift
// Home- WatchKit Extension
//
// 🖌 by Q on 2020-10-25.
//

import Foundation

enum Log {
    static func d(_ message: String) {
        log("debug: " + message)
    }
    
    static func i(_ message: String) {
        log("info: " + message)
    }
    
    static func e(_ message: String) {
        log("error: " + message)
    }
    
    static func log(_ message: String) {
        print("[\(Date.dateTimeWithSeconds)] Home- " + message)
    }
}

extension Date {
    static var dateTimeWithSeconds: String {
        let date = Date()
        let calendar = Calendar.current
        
        let day = calendar.component(.day, from: date)
        let hour = calendar.component(.hour, from: date)
        let minutes = calendar.component(.minute, from: date)
        let seconds = calendar.component(.second, from: date)
        
        return "\(day) \(hour):\(minutes):\(seconds)"
    }
}
