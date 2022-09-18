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
        
        image = .imgSwitch.withSymbolConfiguration(.init(pointSize: 12, weight: .heavy))
        
        offStateTooltip = offStateTooltip ?? "Activate this effects unit"
        onStateTooltip = onStateTooltip ?? "Deactivate this effects unit"
        mixedStateTooltip = "Re-activate this effects unit"
    }
    
    func unitStateChanged(to newState: EffectsUnitState) {
        
        switch newState {
            
        case .active:
            
            contentTintColor = systemColorScheme.activeControlColor
            toolTip = onStateTooltip
            
        case .bypassed:
            
            contentTintColor = systemColorScheme.inactiveControlColor
            toolTip = offStateTooltip
            
        case .suppressed:
            
            contentTintColor = systemColorScheme.suppressedControlColor
            toolTip = mixedStateTooltip
        }
    }
    
    // Sets the button state to be "Off"
    override func off() {}

    // Sets the button state to be "On"
    override func on() {}
}

class FilterBandTriStateBypassButton: NSButton, TintableFXUnitStateObserver {
    
    var bandIndex: Int!
    
    private var filterUnit: FilterUnitDelegateProtocol {
        audioGraphDelegate.filterUnit
    }
    
    func unitStateChanged(to newState: EffectsUnitState) {
        
        // TODO: How to deal with observers that have been removed from table cells ???
        guard bandIndex != nil, bandIndex < filterUnit.numberOfBands else {return}
        
        if filterUnit[bandIndex].bypass {
            
            contentTintColor = systemColorScheme.inactiveControlColor
            toolTip = "Activate this band"
            
        } else {
            
            contentTintColor = newState == .active ? systemColorScheme.activeControlColor : systemColorScheme.suppressedControlColor
            toolTip = "Deactivate this band"
        }
    }
}
