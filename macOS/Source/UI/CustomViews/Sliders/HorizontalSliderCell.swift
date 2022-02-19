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
    
    lazy var valueRange: Double = maxValue - minValue
    
    lazy var halfKnobWidth = knobWidth / 2
    
    var knobPhysicalTravelRange: CGFloat {0}
    
    var gradientDegrees: CGFloat {.horizontalGradientDegrees}
//    var gradientDegrees: CGFloat {.verticalGradientDegrees}
    
    // ----------------------------------------------------
    
    // MARK: Bar

    var barInsetY: CGFloat {0}
    var barRadius: CGFloat {1}
    
    // ----------------------------------------------------
    
    // MARK: Knob
    
    var knobWidth: CGFloat {12}
    var knobHeightOutsideBar: CGFloat {2.5}
    var knobRadius: CGFloat {1.5}
    
    // ----------------------------------------------------
    
    // MARK: Progress
    
    var progressRect: NSRect {.zero}
    
    ///
    /// A fractional number between 0 and 1 indicating the current travel of the slider's knob between
    /// its minValue and maxValue, based on its floatValue.
    ///
    /// Example:   If the slider has a minValue of 0, and a maxValue of 360, a floatValue of 90 would indicate
    ///         25% progress, i.e. 0.25.
    ///
    var progress: CGFloat {
        CGFloat((doubleValue - minValue) / valueRange)
    }
    
    // ----------------------------------------------------
    
    // MARK: Colors
    
    var backgroundColor: NSColor {systemColorScheme.sliderBackgroundColor}
    var foregroundGradient: NSGradient {systemColorScheme.activeControlGradient}
    
    var knobColor: NSColor {
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
    
    override func drawBar(inside aRect: NSRect, flipped: Bool) {
        
        let knobFrame = knobRect(flipped: false)
        
        drawBackground(inRect: aRect, knobFrame: knobFrame)
        drawProgress(inRect: aRect, knobFrame: knobFrame)
    }
    
    func drawProgress(inRect rect: NSRect, knobFrame: NSRect) {
        
        let halfKnobWidth = knobFrame.width / 2
        let leftRect = NSRect(x: rect.minX, y: rect.minY, width: max(halfKnobWidth, knobFrame.minX + halfKnobWidth), height: rect.height)
        
        NSBezierPath.fillRoundedRect(leftRect, radius: barRadius, withGradient: foregroundGradient, angle: gradientDegrees)
    }
    
    func drawBackground(inRect rect: NSRect, knobFrame: NSRect) {
        NSBezierPath.fillRoundedRect(rect, radius: barRadius, withColor: backgroundColor)
    }
    
    var unFlippedKnobRect: NSRect {
        super.knobRect(flipped: false)
    }
    
    override func knobRect(flipped: Bool) -> NSRect {
        
        let bar = barRect(flipped: flipped)
        let val = CGFloat(doubleValue)
        
        let startX = bar.minX + (val * bar.width / valueRange)
        let xOffset = -(val * knobWidth / valueRange)
        
        let newX = startX + xOffset
        let newY = bar.minY - knobHeightOutsideBar
        
        return NSRect(x: newX, y: newY, width: knobWidth, height: knobHeightOutsideBar * 2 + bar.height)
    }
    
    override func drawKnob(_ knobRect: NSRect) {

        let bar = barRect(flipped: true)
        let knobHeight: CGFloat = bar.height + knobHeightOutsideBar
        let knobMinX = knobRect.minX
        
        let knobRect = NSRect(x: knobMinX, y: bar.minY - ((knobHeight - bar.height) / 2), width: knobWidth, height: knobHeight)

        NSBezierPath.fillRoundedRect(knobRect,radius: knobRadius, withColor: knobColor)
        NSBezierPath.strokeRoundedRect(knobRect, radius: knobRadius, withColor: backgroundColor)
    }
}
