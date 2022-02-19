//
//  EQSliderCell.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

/*
    Customizes the look and feel of the parametric EQ sliders
 */
class EQSliderCell: EffectsUnitSliderCell {
    
    // ------------------------------------------------------------------------
    
    // MARK: Constants
    
    override var barRadius: CGFloat {1}
    
    override var knobWidth: CGFloat {10}
    override var knobRadius: CGFloat {1}
    
    private let tickInset: CGFloat = 1.5
    override var tickWidth: CGFloat {2}
    
    private let knobHeight: CGFloat = 12
    private let knobWidthOutsideBar: CGFloat = 1
    
    // ------------------------------------------------------------------------
    
    // MARK: Rendering
    
    // Force knobRect and barRect to NOT be flipped
    
    override func barRect(flipped: Bool) -> NSRect {
        super.barRect(flipped: false)
    }
    
    override internal func drawKnob(_ knobRect: NSRect) {
        
        let rectHeight = knobRect.height
        let bar = barRect(flipped: false)
        let yCenter = knobRect.minY + (rectHeight / 2)

        let knobWidth: CGFloat = bar.width + knobWidthOutsideBar * 2
        let knobMinY = yCenter - (knobHeight / 2)
        let rect = NSRect(x: bar.minX - ((knobWidth - bar.width) / 2), y: knobMinY, width: knobWidth, height: knobHeight)

        NSBezierPath.fillRoundedRect(rect, radius: knobRadius, withColor: knobColor)
        NSBezierPath.strokeRoundedRect(rect, radius: knobRadius, withColor: backgroundColor)
    }
    
    override internal func drawBar(inside drawRect: NSRect, flipped: Bool) {
        
        let knobFrame = unFlippedKnobRect
        let halfKnobWidth = knobFrame.width / 2
        
        let bottomRect = NSRect(x: drawRect.minX, y: drawRect.minY,
                                width: drawRect.width, height: knobFrame.centerY - drawRect.minY)
        
        print("Draw: \(drawRect), BottomRect: \(bottomRect)")
        
        // Top rect
        NSBezierPath.fillRoundedRect(drawRect, radius: barRadius, withColor: backgroundColor)
        
        // Bottom rect
        NSBezierPath.fillRoundedRect(bottomRect, radius: barRadius, withGradient: foregroundGradient, angle: .verticalGradientDegrees)
        
        // Draw one tick across the center of the bar (marking 0dB)
        let tickMinX = drawRect.minX + tickInset
        let tickMaxX = drawRect.maxX - tickInset
        
        let tickRect = rectOfTickMark(at: 0)
        let tickY = tickRect.centerY
        
        // Tick
        GraphicsUtils.drawLine(.white, pt1: NSMakePoint(tickMinX, tickY), pt2: NSMakePoint(tickMaxX, tickY),
                               width: tickWidth)
    }
    
    override func knobRect(flipped: Bool) -> NSRect {
        unFlippedKnobRect
    }
    
    override func drawTickMarks() {
        // Do nothing (ticks are drawn in drawBar)
    }
    
//    override func barRect(flipped: Bool) -> NSRect {
//        return NSRect(x: 2, y: 4, width: super.barRect(flipped: flipped).width, height: 4)
//    }
}
