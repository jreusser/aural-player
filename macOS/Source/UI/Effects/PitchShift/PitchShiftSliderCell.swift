//
//  PitchShiftSliderCell.swift
//  Aural
//
//  Copyright © 2023 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

//import Cocoa
//
//class PitchShiftSliderCell: EffectsUnitSliderCell {
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
//            let gradient = integerValue > 0 ? foregroundGradient : foregroundGradient.reversed()
//            NSBezierPath.fillRoundedRect(panRect, radius: barRadius, withGradient: gradient, angle: -.horizontalGradientDegrees)
//        }
//    }
//    
//    override func knobRect(flipped: Bool) -> NSRect {
//        
//        let bar = barRect(flipped: flipped)
//        let val = CGFloat(integerValue)
//        let perc: CGFloat = 1200 + (val / 2)
//        
//        let startX = bar.minX + perc * bar.width / 2400
//        let xOffset = -(perc * knobWidth / 2400)
//        
//        let newX = startX + xOffset
//        let newY = bar.minY - knobHeightOutsideBar
//        
//        return NSRect(x: newX, y: newY, width: knobWidth, height: knobHeightOutsideBar * 2 + bar.height)
//    }
//}
