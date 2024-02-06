//
//  AUParameterSliderCell.swift
//  Aural
//
//  Copyright © 2023 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import Foundation

// Cell for sliders on generated AU Parameter control views.
class AUParameterSliderCell: HorizontalSliderCell {
    
    override var knobHeightOutsideBar: CGFloat {4.5}
    
    override func progressRect(forBarRect barRect: NSRect, andKnobRect knobRect: NSRect) -> NSRect {
        
        let minX = barRect.minX
        let maxX = knobRect.minX
        
        return NSRect(x: minX, y: barRect.minY, width: maxX - minX, height: barRect.height)
    }
}
