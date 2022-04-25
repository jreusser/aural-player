//
//  AuralSlider.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import Cocoa

class AuralSlider: NSSlider {
    
    private static let x0y1Point: CGPoint = CGPoint(x: 0, y: 1)
    private static let x1y0Point: CGPoint = CGPoint(x: 1, y: 0)
    
    ///
    /// We don't want a flipped co-ordinate system (Y axis).
    ///
//    override var isFlipped: Bool {false}
    
    lazy var valueRange: Double = maxValue - minValue
    
    lazy var centerX = bounds.centerX
    lazy var centerY = bounds.centerY
    
    var knobPhysicalTravelRange: CGFloat {0}
    
    // ----------------------------------------------------
    
    // MARK: Bar

    var barRadius: CGFloat {2}
    var barRect: NSRect {.zero}
    
    // ----------------------------------------------------
    
    // MARK: Knob
    
    var knobRadius: CGFloat {1}
    var knobRect: NSRect {.zero}
    
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
    
    var backgroundColor: NSColor {systemColorScheme.inactiveControlColor}
    
    var foregroundColor: NSColor {systemColorScheme.activeControlColor}
    var foregroundGradientColor: NSColor {systemColorScheme.activeControlGradientColor}
    
    // ----------------------------------------------------
    
    // MARK: Init
    
    var kvoTokens: [NSKeyValueObservation] = []
    
    ///
    /// This slider will do all its drawing on CALayers, so
    /// make sure it has a base layer when initialized.
    ///
    override init(frame frameRect: NSRect) {

        super.init(frame: frameRect)
        wantsLayer = true
        setUpKVO()
    }

    ///
    /// This slider will do all its drawing on CALayers, so
    /// make sure it has a base layer when initialized.
    ///
    required init?(coder: NSCoder) {

        super.init(coder: coder)
        wantsLayer = true
        setUpKVO()
    }
    
    func setUpKVO() {
        
        kvoTokens.append(systemColorScheme.observe(\.activeControlGradientColor, options: [.initial, .new]) {[weak self] _, _ in
            self?.needsDisplay = true
        })
    }
    
    deinit {
        
        kvoTokens.forEach {
            $0.invalidate()
        }
        
        kvoTokens.removeAll()
    }
    
    // ----------------------------------------------------
    
    // MARK: Mouse
    
//    override func mouseDown(with event: NSEvent) {
//
//        let con = convert(event.locationInWindow, from: nil)
//
//        if self.isVertical {
//
//            let deltaY = con.y - barRect.minY
//            doubleValue = minValue + (deltaY * valueRange / barRect.height)
//
//        } else {
//            
//            let deltaX = max(0, con.x - barRect.minX - knobRect.width)
//            doubleValue = minValue + (deltaX * valueRange / knobPhysicalTravelRange)
//            print("\nDBL-1 = \(doubleValue)")
//        }
//
////        perform(self.action, with: self.target)
////        super.mouseDown(with: event)
//        print("DBL-2 = \(doubleValue)")
//        target?.perform(self.action, with: target)
//    }
    
    // ----------------------------------------------------
    
    // MARK: Drawing
    
    ///
    /// Custom drawing for the slider.
    ///
//    public override func draw(_ dirtyRect: NSRect) {
//
//        // Remove previously drawn layers.
//        layer?.sublayers?.removeAll()
//
//        drawBackground()
//        drawProgress()
//        drawKnob()
//        drawTick()
//    }
    
    ///
    /// Draws the background portion of the slider bar / track.
    ///
    func drawBackground() {
        layer?.addSublayer(CAShapeLayer(fillingRoundedRect: barRect, radius: barRadius, withColor: backgroundColor))
    }
    
    ///
    /// Draws the progress portion of the slider bar / track, i.e. the portion
    /// between the minValue and floatValue (i.e. current value) of the
    /// slider.
    ///
    func drawProgress() {
        
        let progressLayerRect = CGRect(x: 0, y: 0, width: progressRect.width, height: progressRect.height)
        
        let maskLayer = CAShapeLayer()
        maskLayer.path = NSBezierPath(roundedRect: progressLayerRect, cornerRadius: barRadius).cgPath
        maskLayer.anchorPoint = .zero
        maskLayer.masksToBounds = true
        maskLayer.bounds = progressLayerRect
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [foregroundColor, foregroundGradientColor].map {$0.cgColor}
        gradientLayer.type = .axial
        gradientLayer.startPoint = self.isVertical ? Self.x0y1Point : Self.x1y0Point
        gradientLayer.endPoint = .zero
        gradientLayer.frame = progressRect
        gradientLayer.mask = maskLayer
        
        layer?.addSublayer(gradientLayer)
    }
    
    ///
    /// Draws the knob / thumb of the slider.
    ///
    func drawKnob() {
        
        let shape = CAShapeLayer(fillingRoundedRect: knobRect, radius: knobRadius, withColor: foregroundColor)
        shape.strokeColor = backgroundColor.cgColor
        shape.lineWidth = 1
        
        layer?.addSublayer(shape)
    }
    
    ///
    /// Draws tick marks at the halfway travel point of the knob's travel range, i.e.
    /// the 0db marker.
    ///
    func drawTick() {
        
//        let bounds = bounds.insetBy(dx: (bounds.width - barWidth) / 2, dy: 0)
//
//        let centerY = bounds.minY + (bounds.height / 2)
//        let tickWidth = ((bounds.width - bounds.width) / 2) - tickSpacingFromBar
//
//        let tickRect = NSRect(x: bounds.minX, y: centerY - 0.5, width: tickWidth, height: tickHeight)
//        let tickRect2 = NSRect(x: bounds.maxX - tickWidth, y: centerY - (tickHeight / 2), width: tickWidth, height: tickHeight)
//
//        layer?.addSublayer(CAShapeLayer(fillingRect: tickRect, withColor: .sliderTicksColor))
//        layer?.addSublayer(CAShapeLayer(fillingRect: tickRect2, withColor: .sliderTicksColor))
    }
}
