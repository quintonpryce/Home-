//
// AccessoryView.swift
// Home- WatchKit Extension
//
// 🖌 by Q on 2020-09-17.
//

import SwiftUI

struct ToggleableAccessoryView: View {
    // MARK: - Dimensions
    private struct Dimension {
        static let cornerRadius: CGFloat = 8
    }
    
    // MARK: - Properties
    @ObservedObject
    var model: ToggleableAccessoryViewModel
    
    // MARK: - Initialization
    init(_ model: ToggleableAccessoryViewModel) {
        self.model = model
    }
    
    // MARK: - Subviews
    var image: some View {
        Image(systemName: model.imageName)
            .frame(width: 12, height: 16)
            .foregroundColor(.yellow)
            .shadow(radius: 10)
            .aspectRatio(contentMode: .fit)
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
    
    // MARK: - Body
    var body: some View {
        Button(action: { model.toggle() }) {
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
        let accessoryOn = ToggleableAccessory(name: "Test name", on: true, isResponsive: true, action: { })
        let accessoryOff = ToggleableAccessory(name: "Test name", on: false, isResponsive: true, action: { })
        let accessoryNotResponsive = ToggleableAccessory(name: "Test name", on: true, isResponsive: false, action: { })
        VStack {
            ToggleableAccessoryView(ToggleableAccessoryViewModel(id: 0, accessory: accessoryOn))
            ToggleableAccessoryView(ToggleableAccessoryViewModel(id: 0, accessory: accessoryOff))
            ToggleableAccessoryView(ToggleableAccessoryViewModel(id: 0, accessory: accessoryNotResponsive))
        }
    }
}
