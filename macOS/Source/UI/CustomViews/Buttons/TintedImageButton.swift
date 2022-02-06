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
class TintedImageButton: NSButton, ColorSchemeable {
    
    private var kvoToken: NSKeyValueObservation?
    
    func observeColorSchemeProperty(_ keyPath: KeyPath<ColorScheme, NSColor>) {
        
        kvoToken = systemColorScheme.observe(keyPath, options: [.initial, .new]) {[weak self] _, changedValue in
            self?.contentTintColor = changedValue.newValue
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
        contentTintColor = systemColorScheme.buttonColor
//        image = image?.withSymbolConfiguration(.init(pointSize: 24, weight: .black))
    }
 
    deinit {
        
        kvoToken?.invalidate()
        kvoToken = nil
    }
}

// A contract for any object to which a tint can be applied (and re-applied). This is used by various UI elements to conform to the system color scheme.
protocol Tintable {
    
    func observeColorProperty<Object>(_ keyPath: KeyPath<Object, NSColor>, of object: Object) where Object: NSObject
}

extension Tintable {
    
    func observeColorProperty<Object>(_ keyPath: KeyPath<Object, NSColor>, of object: Object) where Object: NSObject {}
}

typealias TintFunction = () -> NSColor
