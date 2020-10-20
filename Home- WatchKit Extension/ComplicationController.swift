//
// ComplicationController.swift
// Home+ WatchKit Extension
//
// 🖌 by Q on 2020-09-15.
//

import ClockKit
import SwiftUI

class ComplicationController: NSObject, CLKComplicationDataSource {
    
    var numberOfDevices: String { "7" }
    
    var homeImage: UIImage { UIImage(named: "home")! }
    var emptyHomeImage: UIImage { UIImage(named: "empty home")! }
    
    // MARK: - Timeline Configuration
    
    func getSupportedTimeTravelDirections(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTimeTravelDirections) -> Void) {
        handler([.forward, .backward])
    }
    
    func getTimelineEndDate(for complication: CLKComplication, withHandler handler: @escaping (Date?) -> Void) {
        handler(Date().addingTimeInterval(24.0 * 60.0 * 60.0))
    }
    
    func getPrivacyBehavior(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationPrivacyBehavior) -> Void) {
        handler(.showOnLockScreen)
    }
    

    
    // MARK: - Timeline Population
    
    func getCurrentTimelineEntry(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTimelineEntry?) -> Void) {
        // Call the handler with the current timeline entry
        handler(createTimelineEntry(forComplication: complication, date: Date()))
    }
    
    func getTimelineEntries(for complication: CLKComplication, after date: Date, limit: Int, withHandler handler: @escaping ([CLKComplicationTimelineEntry]?) -> Void) {
        // Call the handler with the timeline entries prior to the given date
        let fiveMinutes = 5.0 * 60.0
        let twentyFourHours = 24.0 * 60.0 * 60.0
        
        // Create an array to hold the timeline entries.
        var entries = [CLKComplicationTimelineEntry]()
        
        // Calculate the start and end dates.
        var current = date.addingTimeInterval(fiveMinutes)
        let endDate = date.addingTimeInterval(twentyFourHours)
        
        // Create a timeline entry for every five minutes from the starting time.
        // Stop once you reach the limit or the end date.
        while (current.compare(endDate) == .orderedAscending) && (entries.count < limit) {
            entries.append(createTimelineEntry(forComplication: complication, date: current))
            current = current.addingTimeInterval(fiveMinutes)
        }
        
        handler(entries)
    }
    
    // Return a timeline entry for the specified complication and date.
    func createTimelineEntry(forComplication complication: CLKComplication, date: Date) -> CLKComplicationTimelineEntry {
        
        // Get the correct template based on the complication.
        let template = createTemplate(forComplication: complication, date: date)
        
        // Use the template and date to create a timeline entry.
        return CLKComplicationTimelineEntry(date: date, complicationTemplate: template)
    }
    
    // Select the correct template based on the complication's family.
    func createTemplate(forComplication complication: CLKComplication, date: Date) -> CLKComplicationTemplate {
        switch complication.family {
        case .modularSmall:
            return createModularSmallTemplate(forDate: date)
        case .modularLarge:
            return createModularLargeTemplate(forDate: date)
        case .utilitarianSmall:
            return createUtilitarianSmallSquareTemplate(forDate: date)
        case .utilitarianLarge:
            return createUtilitarianLargeTemplate(forDate: date)
        case .circularSmall:
            return createCircularSmallTemplate(forDate: date)
        case .extraLarge: // no
            return createExtraLargeTemplate(forDate: date)
        case .graphicCorner:
            return createGraphicCornerTemplate(forDate: date)
        case .graphicCircular:
            return createGraphicCircleTemplate(forDate: date)
        case .graphicRectangular:
            return createGraphicRectangularTemplate(forDate: date)
        case .graphicBezel:
            return createGraphicBezelTemplate(forDate: date)
        case .graphicExtraLarge:
            if #available(watchOSApplicationExtension 7.0, *) {
                return createGraphicExtraLargeTemplate(forDate: date)
            } else {
                fatalError("Graphic Extra Large template is only available on watchOS 7.")
            }
        @unknown default:
            fatalError("*** Unknown Complication Family ***")
        }
    }
    
    // MARK: - Helpers
    
    var homeImageWithNumberOfDevices: UIImage {
        homeImage.drawText(numberOfDevices, color: .white)
    }
    
    var imageProvider: CLKImageProvider {
        let image = homeImage.drawText(numberOfDevices, color: .white)
        return CLKImageProvider(onePieceImage: image)
    }
    
    var textProvider: CLKTextProvider {
        let accessories = numberOfDevices == "1" ? "Accessory" : "Accessories"
        return CLKSimpleTextProvider(text: "\(numberOfDevices) \(accessories) on")
    }
    
    func createTintedImageProvider(_ size: CGSize) -> CLKImageProvider {
        let homeImageWithNumberOfDevices = homeImage.drawText(numberOfDevices, color: .white)
        let emptyHomeBackground = emptyHomeImage.resize(to: size)
        let numberOfDevicesImage = UIImage().resize(to: size).drawText(numberOfDevices, color: .white)
        
        return CLKImageProvider(
            onePieceImage: homeImageWithNumberOfDevices,
            twoPieceImageBackground: emptyHomeBackground,
            twoPieceImageForeground: numberOfDevicesImage
        )
    }
    
    func createFullColorImageProvider(_ size: CGSize) -> CLKFullColorImageProvider {
        let modifiedImage = homeImage
                .withRenderingMode(.alwaysOriginal)
                .withTintColor(.primaryYellow)
                .drawText(numberOfDevices, color: .white)
                .resize(to: size)
            
        return CLKFullColorImageProvider(
            fullColorImage: modifiedImage,
            tintedImageProvider: createTintedImageProvider(size)
        )
    }
    
    // MARK: - Helpers
    
    func createModularSmallTemplate(forDate date: Date) -> CLKComplicationTemplate {
        let template = CLKComplicationTemplateModularSmallSimpleImage()
        template.imageProvider = imageProvider
        return template
    }

    func createModularLargeTemplate(forDate date: Date) -> CLKComplicationTemplate {
        let template = CLKComplicationTemplateModularLargeStandardBody()
        template.headerTextProvider = textProvider
        template.body1TextProvider = CLKTextProvider()
        return template
    }

    func createUtilitarianSmallSquareTemplate(forDate date: Date) -> CLKComplicationTemplate {
        let template = CLKComplicationTemplateUtilitarianSmallSquare()
        template.imageProvider = imageProvider
        return template
    }
    
    func createUtilitarianLargeTemplate(forDate date: Date) -> CLKComplicationTemplate {
        let template = CLKComplicationTemplateUtilitarianLargeFlat()
        template.textProvider = textProvider
        return template
    }
    
    func createCircularSmallTemplate(forDate date: Date) -> CLKComplicationTemplate {
        let template = CLKComplicationTemplateCircularSmallSimpleImage()
        template.imageProvider = imageProvider
        return template
    }
    
    func createExtraLargeTemplate(forDate date: Date) -> CLKComplicationTemplate {
        let template = CLKComplicationTemplateExtraLargeSimpleImage()
        template.imageProvider = imageProvider
        return template
    }

    func createGraphicCornerTemplate(forDate date: Date) -> CLKComplicationTemplate {
        let template = CLKComplicationTemplateGraphicCornerCircularImage()
        template.imageProvider = createFullColorImageProvider(CGSize(width: 26, height: 26))
        return template
    }
    
    func createGraphicCircleTemplate(forDate date: Date) -> CLKComplicationTemplate {
        let template = CLKComplicationTemplateGraphicCircularImage()
        template.imageProvider = createFullColorImageProvider(CGSize(width: 34, height: 34))
        return template
    }
    
    // Return a large rectangular graphic template.
    func createGraphicRectangularTemplate(forDate date: Date) -> CLKComplicationTemplate {
        let template = CLKComplicationTemplateGraphicRectangularLargeImage()
        template.imageProvider = createFullColorImageProvider(CGSize(width: 46 , height: 46))
        return template
    }
    
    func createGraphicBezelTemplate(forDate date: Date) -> CLKComplicationTemplate {
        let circle = CLKComplicationTemplateGraphicCircularImage()
        circle.imageProvider = createFullColorImageProvider(CGSize(width: 26, height: 26))
        
        let template = CLKComplicationTemplateGraphicBezelCircularText()
        template.textProvider = CLKSimpleTextProvider(text: "\(numberOfDevices) Accessores on")
        template.circularTemplate = circle
        return template
    }
    
    @available(watchOSApplicationExtension 7.0, *)
    func createGraphicExtraLargeTemplate(forDate date: Date) -> CLKComplicationTemplate {
        let template = CLKComplicationTemplateGraphicExtraLargeCircularImage()
        template.imageProvider = createFullColorImageProvider(CGSize(width: 96, height: 96))
        return template
    }
}

struct ComplicationController_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            if #available(watchOSApplicationExtension 7.0, *) {
                ComplicationController().createModularSmallTemplate(forDate: Date()).previewContext(faceColor: .red)
                ComplicationController().createModularLargeTemplate(forDate: Date()).previewContext(faceColor: .red)
                ComplicationController().createUtilitarianSmallSquareTemplate(forDate: Date()).previewContext(faceColor: .red)
                ComplicationController().createUtilitarianLargeTemplate(forDate: Date()).previewContext(faceColor: .red)
//                ComplicationController().createCircularSmallTemplate(forDate: Date()).previewContext(faceColor: .red)
//                ComplicationController().createExtraLargeTemplate(forDate: Date()).previewContext()
//
//                ComplicationController().createGraphicCornerTemplate(forDate: Date()).previewContext(faceColor: .red)
//                ComplicationController().createGraphicCircleTemplate(forDate: Date()).previewContext(faceColor: .red)
//                ComplicationController().createGraphicRectangularTemplate(forDate: Date()).previewContext(faceColor: .red)
//                ComplicationController().createGraphicBezelTemplate(forDate: Date()).previewContext(faceColor: .red)
                
                ComplicationController().createGraphicExtraLargeTemplate(forDate: Date()).previewContext()
                
                CLKComplicationTemplateGraphicCircularView(HomeComplication()).previewContext()
            } else {
            }
        }
    }
}

struct HomeComplication: View {
    @State var numberOfDevices = 5
    var image: some View {
        return Image("home")
            .resizable()
            .aspectRatio(contentMode: .fill)
            .foregroundColor(.primaryYellow)
    }

    var body: some View {
        VStack {
            Text("\(numberOfDevices)").font(.headline)
                .padding(EdgeInsets(top: 10, leading: 0, bottom: 4, trailing: 0))
                .foregroundColor(.white)
                .background(image)
        }
    }
}

private extension UIImage {
    func drawText(_ text: String, color: UIColor) -> UIImage {
        let isSingleDigit = text.count == 1
        let text = text.count > 2 ? "99" : text
        let image = self
        
        let imageWidth = image.size.width
        var multiplier: CGFloat { isSingleDigit ? 0.6375 : 0.4375 }
        
        let fontSize: CGFloat = imageWidth * multiplier
        guard let font = UIFont(name: "Helvetica Bold", size: fontSize) else {
            return image
        }

        UIGraphicsBeginImageContextWithOptions(image.size, false, 0)

        let attributes: [NSAttributedString.Key: Any] = [
            .font: font,
            .foregroundColor: color,
        ]
        
        let imagePoint = CGRect(origin: .zero, size: image.size)
        image.draw(in: imagePoint)

        let imageCenterPoint = imageWidth / 2
        let centerPoint = isSingleDigit ? CGPoint(x: imageCenterPoint * 0.66, y: imageCenterPoint * 0.4) : CGPoint(x: imageCenterPoint * 0.52, y: imageCenterPoint * 0.69)
        let rect = CGRect(origin: centerPoint, size: image.size)
        
        text.draw(in: rect, withAttributes: attributes)

        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return newImage ?? image
    }

    
    // https://stackoverflow.com/questions/2658738/the-simplest-way-to-resize-an-uiimage
    func resize(to size: CGSize) -> UIImage {
        defer { UIGraphicsEndImageContext() }
        
        let isTransparent = false
        /// 0 for current device's pixel, 1 to force exact pixel size.
        let scale: CGFloat = .zero
        
        UIGraphicsBeginImageContextWithOptions(size, isTransparent, scale)
        
        draw(in: CGRect(origin: .zero, size: size))
        return UIGraphicsGetImageFromCurrentImageContext() ?? self
    }
    
}
