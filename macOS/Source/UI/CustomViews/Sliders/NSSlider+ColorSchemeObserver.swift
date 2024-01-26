//
//  NSSlider+ColorSchemePropertyObserver.swift
//  Aural
//
//  Copyright © 2023 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import Cocoa

extension NSSlider: ColorSchemeObserver {
    
    func colorChanged(to newColor: PlatformColor, forProperty property: ColorSchemeProperty) {
        redraw()
    }
    
    func colorSchemeChanged() {
        redraw()
    }
}
