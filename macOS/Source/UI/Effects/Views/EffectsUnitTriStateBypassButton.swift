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
class EffectsUnitTriStateBypassButton: OnOffImageButton, TintableFXUnitStateObserver {
    
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
        
        offStateTooltip = offStateTooltip ?? "Activate this effects unit"
        onStateTooltip = onStateTooltip ?? "Deactivate this effects unit"
        mixedStateTooltip = offStateTooltip
    }
    
    // Sets the button state to be "Off"
    override func off() {
        
        toolTip = offStateTooltip
        state = .off
    }
    
    // Sets the button state to be "On"
    override func on() {
        
        toolTip = onStateTooltip
        state = .on
    }
    
    func mixed() {
        
        toolTip = mixedStateTooltip
        state = .mixed
    }
}
