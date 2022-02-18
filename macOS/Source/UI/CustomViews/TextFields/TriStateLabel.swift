//
//  TriStateLabel.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

/*
 An image button that can be toggled On/Off and displays different images depending on its state
 */
@IBDesignable
class EffectsUnitTriStateLabel: CenterTextLabel, FunctionLabel, FXUnitStateObserver {
    
    var stateFunction: EffectsUnitStateFunction?
    
    var unitState: EffectsUnitState {
        stateFunction?() ?? .bypassed
    }
    
    // The image displayed when the button is in an "Off" state
    var offStateColor: NSColor {systemColorScheme.bypassedControlColor}

    // The image displayed when the button is in an "On" state
    var onStateColor: NSColor {systemColorScheme.activeControlColor}

    var mixedStateColor: NSColor {systemColorScheme.suppressedControlColor}
    
    private var _isOn: Bool = false
    
    // Sets the button state to be "Off"
    func off() {
        
        self.textColor = offStateColor
        _isOn = false
    }
    
    // Sets the button state to be "On"
    func on() {
        
        self.textColor = onStateColor
        _isOn = true
    }
    
    func mixed() {
        self.textColor = mixedStateColor
    }
    
    // Convenience function to set the button to "On" if the specified condition is true, and "Off" if not.
    func onIf(_ condition: Bool) {
        condition ? on() : off()
    }
    
    // Toggles the On/Off state
    func toggle() {
        _isOn ? off() : on()
    }
    
    // Returns true if the button is in the On state, false otherwise.
    var isOn: Bool {_isOn}
}

class EffectsUnitTriStatePreviewLabel: EffectsUnitTriStateLabel {
    
//    override var offStateColor: NSColor {Colors.Effects.defaultBypassedUnitColor}
//
//    override var onStateColor: NSColor {Colors.Effects.defaultActiveUnitColor}
//
//    override var mixedStateColor: NSColor {Colors.Effects.defaultSuppressedUnitColor}
}
