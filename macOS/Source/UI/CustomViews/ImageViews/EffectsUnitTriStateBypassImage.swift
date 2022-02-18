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

protocol FXUnitStateObserver {
    
    func reTintOnChangeInState(of effectsUnit: EffectsUnitDelegateProtocol)
    
    func off()
    
    func on()
    
    func mixed()
    
    func redrawOnChangeInState(of effectsUnit: EffectsUnitDelegateProtocol)
    
    func redraw()
}

extension FXUnitStateObserver {
    
    func reTintOnChangeInState(of effectsUnit: EffectsUnitDelegateProtocol) {
        
        effectsUnit.observeState {newState in
            
            switch newState {
                
            case .bypassed: off()
                
            case .active: on()
                
            case .suppressed: mixed()
                
            }
        }
    }
    
    func off() {}
    
    func on() {}
    
    func mixed() {}
    
    func redrawOnChangeInState(of effectsUnit: EffectsUnitDelegateProtocol) {
        
        effectsUnit.observeState {_ in
            redraw()
        }
    }
    
    func redraw() {}
}

/*
    A special case On/Off image button used as a bypass switch for effects units, with preset images
 */
@IBDesignable
class EffectsUnitTriStateBypassImage: NSImageView, FXUnitStateObserver {
    
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
        contentTintColor = systemColorScheme.suppressedControlColor
    }
    
    private var _isOn: Bool = false
    
    // Sets the button state to be "Off"
    func off() {
        
        contentTintColor = systemColorScheme.bypassedControlColor
        _isOn = false
    }
    
    // Sets the button state to be "On"
    func on() {
        
        contentTintColor = systemColorScheme.activeControlColor
        _isOn = true
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

class EffectsUnitTriStateBypassPreviewImage: EffectsUnitTriStateBypassImage {
    
    override func awakeFromNib() {
        
//        offStateTintFunction = {Colors.Effects.defaultBypassedUnitColor}
//        onStateTintFunction = {Colors.Effects.defaultActiveUnitColor}
//        mixedStateTintFunction = {Colors.Effects.defaultSuppressedUnitColor}
    }
}
