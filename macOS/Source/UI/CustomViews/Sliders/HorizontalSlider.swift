//
//  HorizontalSlider.swift
//  Aural
//
//  Copyright © 2023 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import AppKit

class HorizontalSlider: AuralSlider {
    
    // MARK: Constants / state
    
    // Change these values to customize the appearance of the slider.
    
    /// Total width of the slider bar.
    private var barHeight: CGFloat {3}
    
    lazy var _barRect = bounds.insetBy(dx: 0, dy: (bounds.height - barHeight) / 2)
    
    override var barRect: NSRect {_barRect}
    
    var knobHeight: CGFloat {6}
    var knobWidth: CGFloat {12}
    lazy var halfKnobWidth = knobWidth / 2
    
    lazy var knobY = centerY - (knobHeight / 2)
    lazy var knobTravelRange = bounds.width - knobWidth
    
    override var knobPhysicalTravelRange: CGFloat {knobTravelRange}
    
    override var knobRect: NSRect {
        
        print("\nValue: \(doubleValue), Prog= \(progress)")
        
        let knobX = barRect.minX + (progress * knobTravelRange)
        return NSRect(x: knobX, y: knobY, width: knobWidth, height: knobHeight)
    }
    
    override var progressRect: NSRect {
        
        let progressRectWidth = halfKnobWidth + (progress * knobTravelRange)
        return CGRect(x: barRect.minX, y: barRect.minY, width: progressRectWidth, height: barRect.height)
    }
}

class SeekSlider: HorizontalSlider {
    override var knobWidth: CGFloat {18}
}

class VolumeSlider: HorizontalSlider {
    override var knobWidth: CGFloat {15}
}
