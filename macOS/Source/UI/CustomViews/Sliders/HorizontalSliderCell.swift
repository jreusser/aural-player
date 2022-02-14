//
//  HorizontalSliderCell.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
/*
    Customizes the look and feel of all non-ticked horizontal sliders
*/

import Cocoa

// Base class for all horizontal slider cells
class HorizontalSliderCell: NSSliderCell {
    
    // TODO: Apply logic from SeekSliderCell.drawKnob and knobRect here in this class (so that all sliders can benefit from it)
    
    var barRadius: CGFloat {1}
    
//    var backgroundGradient: NSGradient {Colors.Player.sliderBackgroundGradient}
//    var foregroundGradient: NSGradient {Colors.Player.sliderForegroundGradient}
    var gradientDegrees: CGFloat {.horizontalGradientDegrees}
    
    var barInsetX: CGFloat {0}
    var barInsetY: CGFloat {0}
    
    var knobWidth: CGFloat {12}
    var knobHeightOutsideBar: CGFloat {3}
    var knobRadius: CGFloat {1}
    
    var foregroundGradient: NSGradient {
        
        let startColor: NSColor = systemColorScheme.activeControlColor
        let endColor = startColor.darkened(50)
        
        return NSGradient(starting: startColor, ending: endColor)!
    }

    var backgroundColor: NSColor {
        systemColorScheme.sliderBackgroundColor
    }

    var knobColor: NSColor {
        systemColorScheme.activeControlColor
    }
    
    lazy var range: Double = maxValue - minValue
    
    func drawLeftRect(inRect rect: NSRect, knobFrame: NSRect) {
        
        let halfKnobWidth = knobFrame.width / 2
        let leftRect = NSRect(x: rect.minX, y: rect.minY, width: max(halfKnobWidth, knobFrame.minX + halfKnobWidth), height: rect.height)
        
        NSBezierPath.fillRoundedRect(leftRect, radius: barRadius, withGradient: foregroundGradient, angle: gradientDegrees)
    }
    
    func drawRightRect(inRect rect: NSRect, knobFrame: NSRect) {
        
        let halfKnobWidth = knobFrame.width / 2
        let rightRect = NSRect(x: knobFrame.maxX - halfKnobWidth, y: rect.minY,
                               width: rect.width - (knobFrame.maxX - halfKnobWidth), height: rect.height)
        
        NSBezierPath.fillRoundedRect(rightRect, radius: barRadius, withColor: backgroundColor)
    }
    
    override func drawBar(inside aRect: NSRect, flipped: Bool) {
        
        let knobFrame = knobRect(flipped: false)
        
        drawLeftRect(inRect: aRect, knobFrame: knobFrame)
        drawRightRect(inRect: aRect, knobFrame: knobFrame)
    }

    override func knobRect(flipped: Bool) -> NSRect {
        
        let bar = barRect(flipped: flipped)
        let val = CGFloat(self.doubleValue)
        
        let startX = bar.minX + (val * bar.width / range)
        let xOffset = -(val * knobWidth / range)
        
        let newX = startX + xOffset
        let newY = bar.minY - knobHeightOutsideBar
        
        return NSRect(x: newX, y: newY, width: knobWidth, height: knobHeightOutsideBar * 2 + bar.height)
    }
    
    override func drawKnob(_ knobRect: NSRect) {
        
        let bar = barRect(flipped: true)
        let knobHeight: CGFloat = bar.height + knobHeightOutsideBar
        let knobMinX = knobRect.minX
        
        NSBezierPath.fillRoundedRect(NSRect(x: knobMinX, y: bar.minY - ((knobHeight - bar.height) / 2), width: knobWidth, height: knobHeight),
                                     radius: knobRadius,
                                     withColor: knobColor)
        
        NSBezierPath.strokeRoundedRect(NSRect(x: knobMinX, y: bar.minY - ((knobHeight - bar.height) / 2), width: knobWidth, height: knobHeight),
                                     radius: knobRadius,
                                       withColor: systemColorScheme.sliderBackgroundColor)
    }
    
    override func barRect(flipped: Bool) -> NSRect {
        super.barRect(flipped: flipped).insetBy(dx: barInsetX, dy: barInsetY)
    }
}
