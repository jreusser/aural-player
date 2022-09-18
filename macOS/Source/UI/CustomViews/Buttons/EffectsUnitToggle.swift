//
//  EffectsUnitToggle.swift
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
class EffectsUnitToggle: NSButton, FXUnitStateObserver {
    
    func redraw(forState newState: EffectsUnitState) {
        
        switch newState {

        case .bypassed:
            
            image = image?.tintedWithColor(systemColorScheme.inactiveControlColor)
            alternateImage = alternateImage?.tintedWithColor(systemColorScheme.inactiveControlColor)

        case .active:

            image = image?.tintedWithColor(systemColorScheme.activeControlColor)
            alternateImage = alternateImage?.tintedWithColor(systemColorScheme.activeControlColor)

        case .suppressed:

            image = image?.tintedWithColor(systemColorScheme.suppressedControlColor)
            alternateImage = alternateImage?.tintedWithColor(systemColorScheme.suppressedControlColor)
        }
    }
    
    func unitStateChanged(to newState: EffectsUnitState) {
        redraw(forState: newState)
    }
}
