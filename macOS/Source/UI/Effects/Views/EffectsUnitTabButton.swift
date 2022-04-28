//
//  EffectsUnitTabButton.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  
import Cocoa

@IBDesignable
class EffectsUnitTabButton: OnOffImageButton, FXUnitStateObserver {
    
    var stateFunction: EffectsUnitStateFunction?
    
    @IBInspectable var mixedStateTooltip: String?
    
//    var mixedStateTintFunction: () -> NSColor = {Colors.Effects.suppressedUnitStateColor} {
//        didSet {reTint()}
//    }
    
    override func awakeFromNib() {
        
        // Override the tint functions from OnOffImageButton
//        offStateTintFunction = {Colors.Effects.bypassedUnitStateColor}
//        onStateTintFunction = {Colors.Effects.activeUnitStateColor}
    }
    
    override func off() {
        
        toolTip = offStateTooltip
        state = .off
        
//        if let cell = self.cell as? EffectsUnitTabButtonCell {
//
//            cell.unitState = .bypassed
//            redraw()
//        }
    }
    
    override func on() {
        
        toolTip = onStateTooltip
        state = .on
        
//        if let cell = self.cell as? EffectsUnitTabButtonCell {
//
//            cell.unitState = .active
//            redraw()
//        }
    }
    
    func mixed() {
        
        toolTip = mixedStateTooltip
        
//        if let cell = self.cell as? EffectsUnitTabButtonCell {
//            
//            cell.unitState = .suppressed
//            redraw()
//        }
    }
    
    func updateState() {
        
        let newState = stateFunction!()
        
        switch newState {
            
        case .bypassed: off()
            
        case .active: on()
            
        case .suppressed: mixed()
            
        }
    }
    
    var unitState: EffectsUnitState {
        stateFunction?() ?? .bypassed
    }
    
    var isSelected: Bool = false {
        
        didSet {
            redraw()
        }
    }
    
    func select() {
        isSelected = true
    }
    
    func unSelect() {
        isSelected = false
    }
}
