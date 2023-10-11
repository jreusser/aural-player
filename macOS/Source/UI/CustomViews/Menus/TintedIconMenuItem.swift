//
//  TintedIconMenuItem.swift
//  Aural
//
//  Copyright © 2023 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

/*
    A special menu item (with an image) to which a tint can be applied, to conform to the current system color scheme.
 */
@IBDesignable
class TintedIconMenuItem: NSMenuItem, ColorSchemePropertyObserver {
    
    // A base image that is used as an image template.
    @IBInspectable var baseImage: NSImage?
    
    func colorChanged(to newColor: PlatformColor, forProperty property: KeyPath<ColorScheme, PlatformColor>) {
        image = baseImage?.tintedUsingCIFilterWithColor(newColor)
    }
}
