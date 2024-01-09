//
//  CutoffFrequencySlider.swift
//  Aural
//
//  Copyright © 2023 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

class CutoffFrequencySlider: EffectsUnitSlider {
    
    var frequency: Float {
        20 * powf(10, (floatValue - 20) / 6660)
    }
    
    func setFrequency(_ freq: Float) {
        self.floatValue = 6660 * log10(freq / 20) + 20
    }
}

class FilterCutoffFrequencySlider: CutoffFrequencySlider {
    
    var bandIndex: Int! {
        
        didSet {
            (cell as! FilterCutoffFrequencySliderCell).bandIndex = bandIndex
        }
    }
}

class CutoffFrequencySliderCell: EffectsUnitSliderCell {
    
    var filterType: FilterBandType = .lowPass
}

class FilterCutoffFrequencySliderCell: CutoffFrequencySliderCell {
    
    var bandIndex: Int!
    
    private var filterUnit: FilterUnitDelegateProtocol {
        audioGraphDelegate.filterUnit
    }
    
    override var controlStateColor: NSColor {
        
        let unitState = filterUnit.state

        if filterUnit[bandIndex].bypass {
            return systemColorScheme.inactiveControlColor
            
        } else {
            return unitState == .active ? systemColorScheme.activeControlColor : systemColorScheme.suppressedControlColor
        }
    }
    
    override func progressRect(forBarRect barRect: NSRect, andKnobRect knobRect: NSRect) -> NSRect {
        
        filterType == .lowPass ?
        NSRect(x: barRect.minX, y: barRect.minY, width: max(halfKnobWidth, (knobRect.minX + halfKnobWidth) - barRect.minX), height: barRect.height) :
        NSRect(x: knobRect.minX + halfKnobWidth, y: barRect.minY, width: max(halfKnobWidth, barRect.maxX - knobRect.minX + halfKnobWidth), height: barRect.height)
    }
}
