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
class EffectsUnitTriStateBypassButton: OnOffImageButton, FXUnitStateObserver {
    
    override var image: NSImage? {
        
        didSet {
            image?.isTemplate = true
        }
    }
    
    var mixedStateTooltip: String?
    
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
    
    // Sets the button state to be "Off"
    override func off() {
        
        contentTintColor = systemColorScheme.bypassedControlColor
        toolTip = offStateTooltip
        _isOn = false
    }
    
    // Sets the button state to be "On"
    override func on() {
        
        contentTintColor = systemColorScheme.activeControlColor
        toolTip = onStateTooltip
        _isOn = true
    }
    
    func mixed() {
        
        contentTintColor = systemColorScheme.suppressedControlColor
        toolTip = mixedStateTooltip
    }
}
