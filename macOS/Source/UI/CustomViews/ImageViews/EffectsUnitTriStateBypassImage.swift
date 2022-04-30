//
//  EffectsUnitTriStateBypassImage.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

protocol FXUnitStateObserver: AnyObject {
    
    func unitStateChanged(to newState: EffectsUnitState)
    
    func colorForCurrentStateChanged(to newColor: PlatformColor)
    
    func redraw()
}

extension FXUnitStateObserver {
    
    func unitStateChanged(to newState: EffectsUnitState) {
        redraw()
    }
    
    func colorForCurrentStateChanged(to newColor: PlatformColor) {
        redraw()
    }
}

protocol TintableFXUnitStateObserver: FXUnitStateObserver {
    
    var contentTintColor: NSColor? {get set}
}

extension TintableFXUnitStateObserver {
    
    func unitStateChanged(to newState: EffectsUnitState) {
        
        switch newState {
            
        case .active:
            contentTintColor = systemColorScheme.activeControlColor
            
        case .bypassed:
            contentTintColor = systemColorScheme.inactiveControlColor
            
        case .suppressed:
            contentTintColor = systemColorScheme.suppressedControlColor
        }
    }
    
    func colorForCurrentStateChanged(to newColor: PlatformColor) {
        contentTintColor = newColor
    }
}

protocol TextualFXUnitStateObserver: FXUnitStateObserver {
    
    var textColor: NSColor? {get set}
}

extension TextualFXUnitStateObserver {
    
    func unitStateChanged(to newState: EffectsUnitState) {
        
        switch newState {
            
        case .active:
            textColor = systemColorScheme.activeControlColor
            
        case .bypassed:
            textColor = systemColorScheme.inactiveControlColor
            
        case .suppressed:
            textColor = systemColorScheme.suppressedControlColor
        }
    }
    
    func colorForCurrentStateChanged(to newColor: PlatformColor) {
        textColor = newColor
    }
}

/*
    A special case On/Off image button used as a bypass switch for effects units, with preset images
 */
@IBDesignable
class EffectsUnitTriStateBypassImage: NSImageView, TintableFXUnitStateObserver {
    
    override var image: NSImage? {
        
        didSet {
            image?.isTemplate = true
        }
    }
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        image?.isTemplate = true
    }
    
    func mixed() {
        state = .off
    }
    
    private var state: NSControl.StateValue = .off
    
    // Sets the button state to be "Off"
    func off() {
        state = .off
    }
    
    // Sets the button state to be "On"
    func on() {
        state = .on
    }
    
    // Convenience function to set the button to "On" if the specified condition is true, and "Off" if not.
    func onIf(_ condition: Bool) {
        condition ? on() : off()
    }
    
    // Toggles the On/Off state
    func toggle() {
        isOn ? off() : on()
    }
    
    // Returns true if the button is in the On state, false otherwise.
    var isOn: Bool {state == .on}
}

class EffectsUnitTriStateBypassPreviewImage: EffectsUnitTriStateBypassImage {
    
    override func awakeFromNib() {
        
//        offStateTintFunction = {Colors.Effects.defaultBypassedUnitColor}
//        onStateTintFunction = {Colors.Effects.defaultActiveUnitColor}
//        mixedStateTintFunction = {Colors.Effects.defaultSuppressedUnitColor}
    }
}
