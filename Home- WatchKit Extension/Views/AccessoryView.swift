//
// AccessoryView.swift
// Home- WatchKit Extension
//
// 🖌 by Q on 2020-09-17.
//

import SwiftUI

struct AccessoryView: View {
    // MARK: - Dimensions
    private struct Dimension {
        static let cornerRadius: CGFloat = 8
    }
    
    // MARK: - Properties
    @ObservedObject
    var model: AccessoryViewModel
    
    // MARK: - Initialization
    init(_ model: AccessoryViewModel) {
        self.model = model
    }
    
    // MARK: - Subviews
    var image: some View {
        Image(systemName: model.imageName)
            .resizable()
            .frame(width: 12, height: 16)
            .foregroundColor(.yellow)
            .shadow(radius: 10)
    }
    
    var title: some View {
        Text(model.name)
            .font(.system(size: 8))
            .foregroundColor(model.textColor)
            .minimumScaleFactor(0.1)
            .multilineTextAlignment(.center)
    }
    
    var overlay: some View {
        RoundedRectangle(cornerRadius: Dimension.cornerRadius)
            .stroke(model.accentColor, lineWidth: 2)
    }
    
    func toggle() {
        model.toggle()
    }
    
    // MARK: - Body
    var body: some View {
        Button(action: { toggle() }) {
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
        .background(model.backgroundColor)
        .cornerRadius(Dimension.cornerRadius)
    }
}

struct AccessoryView_Previews: PreviewProvider {
    static var previews: some View {
        let accessoryOn = Accessory(name: "Test name", on: true, action: { })
        let accessoryOff = Accessory(name: "Test name", on: false, action: { })
        VStack {
            AccessoryView(AccessoryViewModel(id: 0, accessory: accessoryOn))
            AccessoryView(AccessoryViewModel(id: 0, accessory: accessoryOff))
        }
    }
}
