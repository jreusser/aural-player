//
//  ColorSchemeableBox.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import Cocoa

class ColorSchemeableBox: NSBox, ColorSchemeable {
    
    private var kvoToken: NSKeyValueObservation?
    
    func observeColorSchemeProperty(_ keyPath: KeyPath<ColorScheme, NSColor>) {
        
        kvoToken = systemColorScheme.observe(keyPath, options: [.initial, .new]) {[weak self] changedObject, changedValue in
            
            if let newColor = changedValue.newValue {
                self?.fillColor = newColor
            }
        }
    }
    
    deinit {
        
        kvoToken?.invalidate()
        kvoToken = nil
    }
}
