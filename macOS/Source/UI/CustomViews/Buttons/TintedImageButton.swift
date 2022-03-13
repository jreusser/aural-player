//
//  TintedImageButton.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

/*
    A special image button to which a tint can be applied, to conform to the current system color scheme.
 */
@IBDesignable
class TintedImageButton: NSButton, ColorSchemeable, ColorSchemeObserver {
    
    var weight: NSFont.Weight = .heavy {
        
        didSet {
            image = image?.withSymbolConfiguration(.init(pointSize: 12, weight: weight))
        }
    }
    
    override var image: NSImage? {
        
        didSet {
            image?.isTemplate = true
        }
    }
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        image?.isTemplate = true
    }
 
    func colorChanged(to newColor: PlatformColor) {
        contentTintColor = newColor
    }
}
