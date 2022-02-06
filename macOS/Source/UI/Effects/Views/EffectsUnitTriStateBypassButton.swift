//
//  EffectsUnitTriStateBypassButton.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  
import Cocoa

/*
    A special case On/Off image button used as a bypass switch for effects units, with preset images
 */
class EffectsUnitTriStateBypassButton: OnOffImageButton {
    
    override var image: NSImage? {
        
        didSet {
            image?.isTemplate = true
        }
    }
    
    var stateFunction: EffectsUnitStateFunction?
    
    var unitState: EffectsUnitState {
        stateFunction?() ?? .bypassed
    }
    
    var mixedStateTooltip: String?
    
    // Tint to be applied when the button is in a "mixed" state (eg. when an effects unit is suppressed).
//    var mixedStateTintFunction: () -> NSColor = {Colors.Effects.suppressedUnitStateColor} {
//
//        didSet {
//
//            if unitState == .suppressed {
//                reTint()
//            }
//        }
//    }
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        
        image = Images.imgSwitch
        image?.isTemplate = true
        
        // Override the tint functions from OnOffImageButton
//        offStateTintFunction = {Colors.Effects.bypassedUnitStateColor}
//        onStateTintFunction = {Colors.Effects.activeUnitStateColor}
        
        offStateTooltip = offStateTooltip ?? "Activate this effects unit"
        onStateTooltip = onStateTooltip ?? "Deactivate this effects unit"
        mixedStateTooltip = offStateTooltip
    }
    
    // Bypass is the inverse of "On". If bypass is true, state is "Off".
    func setBypassState(_ bypass: Bool) {
        bypass ? off() : on()
    }
    
    func updateState() {
        
        switch unitState {
            
        case .bypassed: off()
            
        case .active: on()
            
        case .suppressed: mixed()
            
        }
    }
    
    func setUnitState(_ state: EffectsUnitState) {
        
        switch state {
            
        case .bypassed: off()
            
        case .active: on()
            
        case .suppressed: mixed()
            
        }
    }
    
    // Sets the button state to be "Off"
    override func off() {
        
//        contentTintColor = offStateTintFunction()
        toolTip = offStateTooltip
        _isOn = false
    }
    
    // Sets the button state to be "On"
    override func on() {
        
//        contentTintColor = onStateTintFunction()
        toolTip = onStateTooltip
        _isOn = true
    }
    
    func mixed() {
        
//        contentTintColor = mixedStateTintFunction()
        toolTip = mixedStateTooltip
    }
}
