//
//  TintedImageButton.swift
//  Aural
//
//  Copyright © 2023 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

/*
    A special image button to which a tint can be applied, to conform to the current system color scheme.
 */
@IBDesignable
class TintedImageButton: NSButton {
    
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
}

extension NSButton: ColorSchemePropertyObserver {
    
    func colorChanged(to newColor: PlatformColor, forProperty property: KeyPath<ColorScheme, PlatformColor>) {
        
        if self is TintedImageButton {
            contentTintColor = newColor
        } else {
            redraw()
        }
    }
}

extension NSButton: ColorSchemeObserver {
    
    func colorSchemeChanged() {
        redraw()
    }
}

extension NSButton: FontSchemePropertyObserver {
    
    func fontChanged(to newFont: PlatformFont, forProperty property: KeyPath<FontScheme, PlatformFont>) {
        redraw()
    }
}

extension NSButton: FontSchemeObserver {
    
    func fontSchemeChanged() {
        redraw()
    }
}
