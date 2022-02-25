//
//  TintableLabel.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import Cocoa

class TintableLabel: NSTextField, Tintable {
    
    private var kvoToken: NSKeyValueObservation?
    
    func observeColorSchemeProperty(_ keyPath: KeyPath<ColorScheme, NSColor>) {
        
        kvoToken?.invalidate()
        
        kvoToken = systemColorScheme.observe(keyPath, options: [.initial, .new]) {[weak self] _, changedValue in
            self?.textColor = changedValue.newValue
        }
    }
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        observeColorSchemeProperty(\.primaryTextColor)
    }
 
    deinit {
        
        kvoToken?.invalidate()
        kvoToken = nil
    }
}
