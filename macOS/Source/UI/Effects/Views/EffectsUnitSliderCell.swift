//
//  EffectsUnitSliderCell.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

// Cell for all ticked effects sliders
class EffectsUnitSliderCell: HorizontalSliderCell {
    
    override var barRadius: CGFloat {1.5}
    
    override var knobWidth: CGFloat {10}
    override var knobRadius: CGFloat {1}
    override var knobHeightOutsideBar: CGFloat {2}
    
    lazy var observingSlider: EffectsUnitSlider = controlView as! EffectsUnitSlider
    
    override var foregroundGradient: NSGradient {
        
        switch fxUnitStateObserverRegistry.currentState(forObserver: observingSlider) {
            
        case .active:       return systemColorScheme.activeControlGradient
            
        case .bypassed:     return systemColorScheme.bypassedControlGradient
            
        case .suppressed:   return systemColorScheme.suppressedControlGradient
            
        }
    }
    
    override var knobColor: NSColor {
        
        switch fxUnitStateObserverRegistry.currentState(forObserver: observingSlider) {
            
        case .active:       return systemColorScheme.activeControlColor
            
        case .bypassed:     return systemColorScheme.bypassedControlColor
            
        case .suppressed:   return systemColorScheme.suppressedControlColor
            
        }
    }
}
