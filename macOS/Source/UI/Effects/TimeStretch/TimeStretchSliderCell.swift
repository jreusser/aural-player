//
//  TimeStretchSliderCell.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import Cocoa

class TimeStretchSlider: EffectsUnitSlider {
    
    private let minRate: Float = 0.25
    
    /// Logarithmic scale.
    var rate: Float {
        
        get {
            minRate * powf(2, floatValue)
        }
        
        set(newRate) {
            floatValue = log2(newRate / minRate)
        }
    }
}

//class TimeStretchSliderCell: EffectsUnitSliderCell {
//    
//    // Draw entire bar with single gradient
//    override internal func drawBar(inside aRect: NSRect, flipped: Bool) {
//
//        // Background
//        NSBezierPath.fillRoundedRect(aRect, radius: barRadius, withColor: backgroundColor)
//        
//        drawTicks(aRect)
//        
//        // Draw rect between knob and center, to show panning
//        let knobCenter = knobRect(flipped: false).centerX
//        let barCenter = aRect.centerX
//        let panRectX = min(knobCenter, barCenter)
//        let panRectWidth = abs(knobCenter - barCenter)
//        
//        if panRectWidth > 0 {
//            
//            let panRect = NSRect(x: panRectX, y: aRect.minY, width: panRectWidth, height: aRect.height)
//            let gradient = floatValue > 2 ? foregroundGradient : foregroundGradient.reversed()
//            NSBezierPath.fillRoundedRect(panRect, radius: barRadius, withGradient: gradient, angle: -.horizontalGradientDegrees)
//        }
//    }
//    
//    override func knobRect(flipped: Bool) -> NSRect {
//        
//        let bar = barRect(flipped: flipped)
//        let val = CGFloat(floatValue)
//        
//        let startX = bar.minX + (val * bar.width / 4)
//        let xOffset = -(val * knobWidth / 4)
//        
//        let newX = startX + xOffset
//        let newY = bar.minY - knobHeightOutsideBar
//        
//        return NSRect(x: newX, y: newY, width: knobWidth, height: knobHeightOutsideBar * 2 + bar.height)
//    }
//}
