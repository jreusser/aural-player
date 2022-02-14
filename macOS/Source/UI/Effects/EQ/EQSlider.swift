////
////  EQSlider.swift
////  Aural
////
////  Copyright © 2021 Kartik Venugopal. All rights reserved.
////
////  This software is licensed under the MIT software license.
////  See the file "LICENSE" in the project root directory for license terms.
////

import Cocoa

///
/// A custom vertical slider for the Equalizer view.
///
class EQSlider: EffectsUnitSlider {
    
    // MARK: State / constants
    
    // Change these values to customize the appearance of the slider.
    
    var knobHeight: CGFloat {12}
    var knobWidth: CGFloat {6}
    
    var barWidth: CGFloat {3}
    
    lazy var halfKnobHeight = knobHeight / 2
    
    lazy var knobX = centerX - (knobWidth / 2)
    private lazy var knobTravelRange = bounds.height - knobHeight
    
    override var knobPhysicalTravelRange: CGFloat {knobTravelRange}
    
    lazy var _barRect = bounds.insetBy(dx: (bounds.width - barWidth) / 2, dy: 0)
    
    override var barRect: NSRect {_barRect}
    
    private let eqUnit: EQUnitDelegateProtocol = objectGraph.audioGraphDelegate.eqUnit
    
    override var progressRect: NSRect {
        
        let progressRectHeight = halfKnobHeight + (progress * knobTravelRange)
        return NSRect(x: barRect.minX, y: barRect.minY, width: barRect.width, height: progressRectHeight)
    }
    
    override var knobRect: NSRect {
        
//        print("\nEQ Value: \(doubleValue), Prog= \(progress)")
        
        let knobY = barRect.minY + (progress * knobTravelRange)
        return NSRect(x: knobX, y: knobY, width: knobWidth, height: knobHeight)
    }
    
    // --------------------------------------------------------------------------------
    
    // MARK: KVO
    
    override func setUpKVO() {
        
        super.setUpKVO()
        
        eqUnit.observeState {[weak self] _ in
            self?.needsDisplay = true
        }
    }
}
