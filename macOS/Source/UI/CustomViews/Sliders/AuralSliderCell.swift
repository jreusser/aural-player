//
//  AuralSliderCell.swift
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
class AuralSliderCell: NSSliderCell {
    
    lazy var valueRange: Double = maxValue - minValue
    
    var knobPhysicalTravelRange: CGFloat {0}
    
    var gradientDegrees: CGFloat {.horizontalGradientDegrees}
//    var gradientDegrees: CGFloat {.verticalGradientDegrees}
    
    // ----------------------------------------------------
    
    // MARK: Bar

    var barRadius: CGFloat {1}
    
    // ----------------------------------------------------
    
    // MARK: Knob
    
    var knobWidth: CGFloat {12}
    var knobRadius: CGFloat {1.5}
    
    // ----------------------------------------------------
    
    // MARK: Ticks
    
    var tickWidth: CGFloat {2}
    var tickColor: NSColor {.sliderNotchColor}
    
    // ----------------------------------------------------
    
    // MARK: Colors
    
    var backgroundColor: NSColor {systemColorScheme.sliderBackgroundColor}
    
    var foregroundGradient: NSGradient {
        systemColorScheme.activeControlGradient
    }
    
    var controlStateColor: NSColor {
        systemColorScheme.activeControlColor
    }
    
    // ----------------------------------------------------
    
    // MARK: Init
    
    var kvoTokens: [NSKeyValueObservation] = []
    
    required init(coder: NSCoder) {
        
        super.init(coder: coder)
        setUpKVO()
    }
    
    func setUpKVO() {
        
        kvoTokens.append(systemColorScheme.observe(\.activeControlGradientColor, options: [.initial, .new]) {[weak self] _, _ in
            self?.controlView?.redraw()
        })
        
        kvoTokens.append(systemColorScheme.observe(\.sliderBackgroundColor, options: [.initial, .new]) {[weak self] _, _ in
            self?.controlView?.redraw()
        })
    }
    
    deinit {
        
        kvoTokens.forEach {
            $0.invalidate()
        }
        
        kvoTokens.removeAll()
    }
    
    var originalKnobRect: NSRect {
        super.knobRect(flipped: false)
    }
    
    var originalBarRect: NSRect {
        super.barRect(flipped: false)
    }
    
    var progress: CGFloat {CGFloat((doubleValue - minValue) / valueRange)}
    
    override func drawBar(inside aRect: NSRect, flipped: Bool) {
        
        drawBackground(inRect: aRect)
        
        let progressRect = progressRect(forBarRect: aRect, andKnobRect: knobRect(flipped: false))
        drawProgress(inRect: progressRect)
        
        drawTicks(aRect)
    }
    
    /// OVERRIDE THIS !
    func progressRect(forBarRect barRect: NSRect, andKnobRect knobRect: NSRect) -> NSRect {
        .zero
    }
    
    func drawProgress(inRect rect: NSRect) {
        NSBezierPath.fillRoundedRect(rect, radius: barRadius, withGradient: foregroundGradient, angle: gradientDegrees)
    }
    
    func drawBackground(inRect rect: NSRect) {

        let startPoint = NSMakePoint(rect.minX, rect.centerY)
        let endPoint = NSMakePoint(rect.maxX, rect.centerY)
        GraphicsUtils.drawLine(.white30Percent, pt1: startPoint, pt2: endPoint, width: 1)
    }
    
    func drawTicks(_ aRect: NSRect) {
        
        // Draw ticks (as notches, within the bar)
        switch numberOfTickMarks {
            
        case 3..<Int.max:
            
            for i in 1...numberOfTickMarks - 2 {
                drawTick(i, aRect)
            }
            
        case 1:
            drawTick(0, aRect)
            
        default:
            return
        }
    }
    
    func drawTick(_ index: Int, _ barRect: NSRect) {}
}
