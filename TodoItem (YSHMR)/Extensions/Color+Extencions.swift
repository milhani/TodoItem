import Foundation
import SwiftUI

extension Color {
    init(hex: String) {
        let r, g, b: CGFloat

        let start = hex.index(hex.startIndex, offsetBy: 1)
        let hexColor = String(hex[start...])

        if hexColor.count == 8 {
            let scanner = Scanner(string: hexColor)
            var hexNumber: UInt64 = 0

            if scanner.scanHexInt64(&hexNumber) {
                r = CGFloat((hexNumber & 0xff000000) >> 24) / 255
                g = CGFloat((hexNumber & 0x00ff0000) >> 16) / 255
                b = CGFloat((hexNumber & 0x0000ff00) >> 8) / 255
                //a = CGFloat(hexNumber & 0x000000ff) / 255

                self.init(red: r, green: g, blue: b)
                return
            }
        }
        self.init(red: 0, green: 0, blue: 0)
    }
    
    var hex: String? {
        guard let components = cgColor?.components, components.count >= 3 else {
            return nil
        }

        let r = components[0]
        let g = components[1]
        let b = components[2]

        return String(
            format: "#%02lX%02lX%02lX",
            lroundf(Float(r * 255)),
            lroundf(Float(g * 255)),
            lroundf(Float(b * 255))
        ).lowercased()
    }
}

extension Color {
    var rgbColor: UInt32 {
        let components = UIColor(self).cgColor.components!
        let r = UInt32(components[0] * 255.0) << 16
        let g = UInt32(components[1] * 255.0) << 8
        let b = UInt32(components[2] * 255.0)
        return r + g + b
    }
    
    func adjust(brightness: Double) -> Color {
        Color(UIColor(self).adjusted(by: CGFloat(brightness)))
    }
}

extension UIColor {
    func adjusted(by factor: CGFloat) -> UIColor {
        var hue: CGFloat = 0,
            saturation: CGFloat = 0,
            brightness: CGFloat = 0,
            alpha: CGFloat = 0
        
        getHue(&hue,
               saturation: &saturation,
               brightness: &brightness,
               alpha: &alpha)
        
        return UIColor(hue: hue, saturation: saturation, brightness: brightness * factor, alpha: alpha)
    }
}
