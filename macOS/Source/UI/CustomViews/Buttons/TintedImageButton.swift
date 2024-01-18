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

@IBDesignable
class WhiteImageButton: NSButton {
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        image?.isTemplate = false
    }
    
    // A base image that is used as an image template.
    @IBInspectable var baseImage: NSImage? {
        
        // Re-tint the image whenever the base image is updated.
        didSet {
            self.image = baseImage?.filledWithColor(.white)
        }
    }
    
    override var image: NSImage? {
        
        didSet {
            image?.isTemplate = false
        }
    }
}

@IBDesignable
class FillableImageButton: NSButton {
    
    @IBInspectable var tintColor: NSColor!
    
    // A base image that is used as an image template.
    @IBInspectable var baseImage: NSImage!
    
    override var image: NSImage? {
        
        didSet {
            image?.isTemplate = false
        }
    }
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        fill(image: baseImage, withColor: tintColor)
    }
    
    func fill(image baseImage: NSImage, withColor tintColor: NSColor) {
        
        self.baseImage = baseImage
        self.tintColor = tintColor
        
        self.image = baseImage.filledWithColor(tintColor)
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
