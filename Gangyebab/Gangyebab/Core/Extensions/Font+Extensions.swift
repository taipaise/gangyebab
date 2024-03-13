//
//  Font+Extensions.swift
//  Gangyebab
//
//  Created by 이동현 on 3/11/24.
//

import UIKit

public extension UIFont {
    
    static func registerCustomFonts() {
        let fonts = [
            "omyu_pretty.ttf",
            "SOYO-Maple-Regular.otf",
            "SOYO-Maple-Bold.otf",
         ]
        
        fonts.forEach { font in
            registerFont(bundle: .main, fontName: font)
        }
    }
    
    static func registerFont(bundle: Bundle, fontName: String) {
        guard let fontURL = bundle.path(forResource: fontName, ofType: nil) else {
            fatalError("Couldn't find font \(fontName)")
        }
        
        guard let fontData = NSData(contentsOfFile: fontURL) else {
            fatalError("Couldn't load data from the font \(fontName)")
        }
        
        guard let fontDataProvider = CGDataProvider(data: fontData) else {
            fatalError("Couldn't load data from the font \(fontName)")
        }

        guard let font = CGFont(fontDataProvider) else {
            fatalError("Couldn't create font from data")
        }
        
        var error: Unmanaged<CFError>?
        let _ = CTFontManagerRegisterGraphicsFont(font, &error)
    }
    
}

public extension UIFont {
    
    static func soyo(size fontSize: CGFloat, weight: UIFont.Weight) -> UIFont {
        let fontName: String = "SOYO-Maple"
        let weightName: String
        
        switch weight {
        case .bold:
            weightName = "Blod"
        default:
            weightName = "Regular"
        }
        
        return UIFont(name: "\(fontName)-\(weightName)", size: fontSize) ?? .systemFont(ofSize: fontSize, weight: weight)
    }
    
    static func omyu(size fontSize: CGFloat) -> UIFont {
        let fontName: String = "omyu_pretty"
    
        return UIFont(name: "\(fontName)", size: fontSize) ?? .systemFont(ofSize: fontSize, weight: .regular)
    }
}
