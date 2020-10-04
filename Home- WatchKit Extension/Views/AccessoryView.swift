//
// AccessoryView.swift
// Home- WatchKit Extension
//
// 🖌 by Q on 2020-09-17.
//

import SwiftUI

struct AccessoryView: View {
    // MARK: - Data
    let data: AccessoryViewModel
    
    // MARK: - Initialization
    init(_ data: AccessoryViewModel) {
        self.data = data
    }
    
    // MARK: - Actions
    var action: () -> Void { data.action }
    
    // MARK: - Subviews
    var image: some View {
        Image(systemName: "circle")
            .resizable()
            .frame(width: 16, height: 16)
            .foregroundColor(.yellow)
            .shadow(radius: 10)
    }
    
    var title: some View {
        Text(self.data.name)
            .font(.system(size: 8))
            .minimumScaleFactor(0.1)
            .multilineTextAlignment(.center)
    }
    
    var overlay: some View {
        RoundedRectangle(cornerRadius: 8)
            .stroke(Color.yellow, lineWidth: 2)
    }
    
    // MARK: - Body
    var body: some View {
        Button(action: action) {
            VStack(alignment: .center, spacing: 0, content: {
                Spacer(2)
                image
                Spacer(4)
                title
                Spacer(1)
            })
            .frame(width: 50, height: 34, alignment: .center)
        }
        .frame(width: 60, height: 40, alignment: .top)
        .overlay(overlay)
    }
}
