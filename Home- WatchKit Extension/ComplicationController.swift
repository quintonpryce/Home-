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
    var emptyHomeImage: UIImage { UIImage(named: "home")! }
    
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
        case .utilitarianSmall, .utilitarianSmallFlat:
            return createUtilitarianSmallFlatTemplate(forDate: date)
        case .utilitarianLarge:
            return createUtilitarianLargeTemplate(forDate: date)
        case .circularSmall:
            return createCircularSmallTemplate(forDate: date)
        case .extraLarge: // no
            return createExtraLargeTemplate(forDate: date)
        case .graphicCorner:
            return createGraphicCornerTemplate(forDate: date)
        case .graphicCircular:
            return Self.createGraphicCircleTemplate(forDate: date)
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
    
    var imageProvider: CLKImageProvider {
        let image = homeImage.drawText(numberOfDevices)
        return CLKImageProvider(onePieceImage: image)
    }
    
    func createModularSmallTemplate(forDate date: Date) -> CLKComplicationTemplate {
        let template = CLKComplicationTemplateModularSmallSimpleImage()
        template.imageProvider = imageProvider
        
        return template
    }

    func createModularLargeTemplate(forDate date: Date) -> CLKComplicationTemplate {
        let template = CLKComplicationTemplateModularLargeStandardBody()
        template.headerImageProvider = imageProvider
        template.headerTextProvider = CLKSimpleTextProvider(text: "\(numberOfDevices) Accessories on")
        template.body1TextProvider = CLKTextProvider()
        
        return template
    }

    func createUtilitarianSmallFlatTemplate(forDate date: Date) -> CLKComplicationTemplate {
        let template = CLKComplicationTemplateUtilitarianSmallFlat()
        return template
    }
    
    func createUtilitarianLargeTemplate(forDate date: Date) -> CLKComplicationTemplate {

        let template = CLKComplicationTemplateUtilitarianLargeFlat()
        return template
    }
    
    func createCircularSmallTemplate(forDate date: Date) -> CLKComplicationTemplate {
        let image = homeImage.drawText(numberOfDevices)
        let imageProvider = CLKImageProvider(onePieceImage: image)
        
        let template = CLKComplicationTemplateCircularSmallSimpleImage()
        template.imageProvider = imageProvider
        
        return template
    }
    
    func createExtraLargeTemplate(forDate date: Date) -> CLKComplicationTemplate {
        let template = CLKComplicationTemplateExtraLargeStackText()
        return template
    }

    func createGraphicCornerTemplate(forDate date: Date) -> CLKComplicationTemplate {
        let template = CLKComplicationTemplateGraphicCornerGaugeText()
        return template
    }
    
    // Return a graphic circle template.
    static func createGraphicCircleTemplate(forDate date: Date) -> CLKComplicationTemplate {
        // Create the data providers.
        let percentage:Float = 0.75
        if #available(watchOSApplicationExtension 7.0, *) {
            let uiimage = UIImage(systemName: "house.fill")!
            
            uiimage.withTintColor(.yellow)
            let image = CLKComplicationTemplateCircularSmallSimpleImage(imageProvider: CLKImageProvider(onePieceImage: uiimage))
            return image
        } else {
            // Fallback on earlier versions
        }

        let template = CLKComplicationTemplateGraphicCircularOpenGaugeSimpleText()

        return template
    }
    
    // Return a large rectangular graphic template.
    func createGraphicRectangularTemplate(forDate date: Date) -> CLKComplicationTemplate {
        let template = CLKComplicationTemplateGraphicRectangularTextGauge()
        return template
    }
    
    // Return a circular template with text that wraps around the top of the watch's bezel.
    func createGraphicBezelTemplate(forDate date: Date) -> CLKComplicationTemplate {
        
        // Create a graphic circular template with an image provider.
        let circle = CLKComplicationTemplateGraphicCircularImage()
        let image = UIImage(named: "home")!.withRenderingMode(.alwaysOriginal).drawText(numberOfDevices).withTintColor(.yellow)
        let resizedImage = image.copy(newSize: CGSize(width: 30, height: 30))!
        circle.imageProvider = CLKFullColorImageProvider(fullColorImage: resizedImage)
        
        let template = CLKComplicationTemplateGraphicBezelCircularText()
        template.textProvider = CLKSimpleTextProvider(text: "\(numberOfDevices) Accessores on")
        template.circularTemplate = circle
        return template
    }
    
    // Returns an extra large graphic template
    @available(watchOSApplicationExtension 7.0, *)
    func createGraphicExtraLargeTemplate(forDate date: Date) -> CLKComplicationTemplate {
        
        return CLKComplicationTemplateGraphicExtraLargeCircularOpenGaugeSimpleText()
    }
    
    // MARK: - Placeholder Templates
    
    func getLocalizableSampleTemplate(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTemplate?) -> Void) {
        let future = Date().addingTimeInterval(25.0 * 60.0 * 60.0)
        let template = createTemplate(forComplication: complication, date: future)
        handler(template)
    }
    
}

struct ComplicationController_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            if #available(watchOSApplicationExtension 7.0, *) {
                ComplicationController.createGraphicCircleTemplate(forDate: Date()).previewContext(faceColor: .red)
                
                ComplicationController().createCircularSmallTemplate(forDate: Date()).previewContext(faceColor: .red)
                
                ComplicationController().createModularSmallTemplate(forDate: Date()).previewContext()
                
                ComplicationController().createGraphicBezelTemplate(forDate: Date()).previewContext()
                
                ComplicationController().createGraphicCornerTemplate(forDate: Date()).previewContext()
                
                ComplicationController().createExtraLargeTemplate(forDate: Date()).previewContext()
            } else {
            }
            
        }
    }
}

struct HomeComplication: View {
    @State var numberOfDevices = 5

    var body: some View {
        VStack {
//            let image = UIImage(systemName: "house.fill")
//            image.size = CGSize(width: 10, height: 10)
            
            Text("\(numberOfDevices)").font(.headline)
                .padding(EdgeInsets(top: 10, leading: 0, bottom: 4, trailing: 0))
                .foregroundColor(.white).background(Image("home")
                                                                                            .resizable()
                                                                                            .aspectRatio(contentMode: .fill).foregroundColor(.yellow))
            
            
        }
            

    }
}

struct GaugeSample_Previews: PreviewProvider {
    static var previews: some View {
        if #available(watchOSApplicationExtension 7.0, *) {
            CLKComplicationTemplateGraphicCircularView(HomeComplication())
                .previewContext()
        } else {
            // Fallback on earlier versions
        }
    }
}


private extension UIImage {
    func drawText(_ text: String) -> UIImage {
        let isSingleDigit = text.count == 1
        let text = text.count > 2 ? "99" : text
        let image = self
        
        let fontSize: CGFloat = isSingleDigit ? 200 : 140
        guard let font = UIFont(name: "Helvetica Bold", size: fontSize) else {
            return image
        }
        
        let color: UIColor = .white

        UIGraphicsBeginImageContextWithOptions(image.size, false, 0)

        let attributes: [NSAttributedString.Key: Any] = [
            .font: font,
            .foregroundColor: color,
        ]
        
        let imagePoint = CGRect(origin: CGPoint.zero, size: image.size)
        image.draw(in: imagePoint)
        
        let centerPoint = isSingleDigit ? CGPoint(x: 105, y: 65) : CGPoint(x: 85, y: 110)
        let rect = CGRect(origin: centerPoint, size: image.size)
        
        text.draw(in: rect, withAttributes: attributes)

        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return newImage ?? image
    }

    
    // https://stackoverflow.com/questions/2658738/the-simplest-way-to-resize-an-uiimage
    func copy(newSize: CGSize, retina: Bool = true) -> UIImage? {
        // In next line, pass 0 to use the current device's pixel scaling factor (and thus account for Retina resolution).
        // Pass 1 to force exact pixel size.
        UIGraphicsBeginImageContextWithOptions(
            /* size: */ newSize,
            /* opaque: */ false,
            /* scale: */ retina ? 0 : 1
        )
        defer { UIGraphicsEndImageContext() }

        draw(in: CGRect(origin: .zero, size: newSize))
        return UIGraphicsGetImageFromCurrentImageContext()
    }
    
}
