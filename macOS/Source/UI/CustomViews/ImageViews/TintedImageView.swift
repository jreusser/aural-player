//
//  TintedImageView.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

@IBDesignable
class TintedImageView: NSImageView, Tintable, ColorSchemeable {
    
    private var kvoToken: NSKeyValueObservation?
    
    override var image: NSImage? {
        
        didSet {
            image?.isTemplate = true
        }
    }
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        image?.isTemplate = true
    }
    
    func observeColorSchemeProperty(_ keyPath: KeyPath<ColorScheme, NSColor>) {
        
        kvoToken = systemColorScheme.observe(keyPath, options: [.initial, .new]) {[weak self] changedObject, changedValue in
            self?.contentTintColor = changedValue.newValue
        }
    }
    
    deinit {
        
        kvoToken?.invalidate()
        kvoToken = nil
    }
}
