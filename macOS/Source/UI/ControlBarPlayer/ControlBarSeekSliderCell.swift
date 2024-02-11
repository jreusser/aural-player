//
//  ControlBarSeekSliderCell.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  
import Cocoa

class ControlBarSeekSliderCell: SeekSliderCell {
    
    override var barRadius: CGFloat {0}
    override var barHeight: CGFloat {3}
    
    // Limit the tracking rect so that events don't conflict with clicks outside the (visible) slider.
    override func trackMouse(with event: NSEvent, in cellFrame: NSRect, of controlView: NSView, untilMouseUp flag: Bool) -> Bool {
        
        if event.locationInWindow.y <= 6 {
            return super.trackMouse(with: event, in: cellFrame, of: controlView, untilMouseUp: flag)
        }
        
        return false
    }
}
