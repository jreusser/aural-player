////
////  EQSlider.swift
////  Aural
////
////  Copyright © 2021 Kartik Venugopal. All rights reserved.
////
////  This software is licensed under the MIT software license.
////  See the file "LICENSE" in the project root directory for license terms.
////

import Cocoa

///
/// A custom vertical slider for the Equalizer view.
///
class EQSlider: EffectsUnitSlider {
    
    // MARK: State / constants
    
    // Change these values to customize the appearance of the slider.
    
    var knobHeight: CGFloat {12}
    var knobWidth: CGFloat {6}
    
    var barWidth: CGFloat {4}
    
    var tickSpacingFromBar: CGFloat {5}
    var tickHeight: CGFloat {1}
    
    ///
    /// We don't want a flipped co-ordinate system (Y axis).
    ///
    public override var isFlipped: Bool {false}
    
    lazy var range = maxValue - minValue
    
    // --------------------------------------------------------------------------------
    
    // MARK: Initializers
    
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
    
    private var kvoToken: NSKeyValueObservation? = nil
    
    private func setUpKVO() {
        
        kvoToken = systemColorScheme.observe(\.activeControlGradient, options: [.initial, .new]) {[weak self] _, _ in
            self?.needsDisplay = true
        }
    }
    
    deinit {
        
        kvoToken?.invalidate()
        kvoToken = nil
    }
    
    // --------------------------------------------------------------------------------
    
    // MARK: View rendering
    
    ///
    /// Custom drawing for the slider.
    ///
    public override func draw(_ dirtyRect: NSRect) {
        
        // Remove previously drawn layers.
        layer?.sublayers?.removeAll()
        
        drawTick()
        drawBackground()
        drawProgress()
        drawKnob()
    }
    
    ///
    /// Draws the background portion of the slider bar / track.
    ///
    private func drawBackground() {
        
        let backgroundRect = bounds.insetBy(dx: (bounds.width - barWidth) / 2, dy: 0)
        layer?.addSublayer(CAShapeLayer(fillingRoundedRect: backgroundRect, radius: 2, withColor: systemColorScheme.sliderBackgroundColor))
    }
    
    ///
    /// A fractional number between 0 and 1 indicating the current travel of the slider's knob between
    /// its minValue and maxValue, based on its floatValue.
    ///
    /// Example:   If the slider has a minValue of -20, and a maxValue of 20, a floatValue of 10 would indicate
    ///         75% progress, i.e. 0.75.
    ///
    private var progress: CGFloat {
        CGFloat((doubleValue - minValue) / range)
    }
    
    ///
    /// Draws the progress portion of the slider bar / track, i.e. the portion
    /// between the minValue and floatValue (i.e. current value) of the
    /// slider.
    ///
    private func drawProgress() {
        
        let insetRect = bounds.insetBy(dx: (bounds.width - barWidth) / 2, dy: 0)
        
        let halfKnobHeight = knobHeight / 2
        let knobTravelRange = bounds.height - knobHeight
        
        let progressRectHeight = halfKnobHeight + (progress * knobTravelRange)
        let progressRect = NSRect(x: insetRect.minX, y: insetRect.minY, width: insetRect.width, height: progressRectHeight)
        
//        layer?.addSublayer(CAShapeLayer(fillingRoundedRect: progressRect, radius: 2, withColor: systemColorScheme.activeControlColor))
        
        let maskLayer = CAShapeLayer()
        maskLayer.path = NSBezierPath(roundedRect: CGRect(x: 0, y: 0, width: progressRect.width, height: progressRect.height), cornerRadius: 1).cgPath
        maskLayer.anchorPoint = .zero
        maskLayer.masksToBounds = true
        maskLayer.bounds = CGRect(x: 0, y: 0, width: progressRect.width, height: progressRect.height)
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [systemColorScheme.activeControlColor, systemColorScheme.activeControlColor.darkened(50)].map {$0.cgColor}
        gradientLayer.type = .axial
        gradientLayer.startPoint = CGPoint(x: 0, y: 1)
        gradientLayer.endPoint = CGPoint(x: 0, y: 0)
        gradientLayer.frame = progressRect
        gradientLayer.mask = maskLayer
        
        layer?.addSublayer(gradientLayer)
    }
    
    ///
    /// Draws the knob / thumb of the slider.
    ///
    private func drawKnob() {
        
        let centerX = bounds.minX + (bounds.width / 2)
        
        let knobTravelRange = bounds.height - knobHeight
        let knobY = bounds.minY + (progress * knobTravelRange)
        
        let knobRect = NSRect(x: centerX - (knobWidth / 2), y: knobY, width: knobWidth, height: knobHeight)
        
        let shape = CAShapeLayer(fillingRoundedRect: knobRect, radius: 1.5, withColor: systemColorScheme.activeControlColor)
        shape.strokeColor = systemColorScheme.sliderBackgroundColor.cgColor
        shape.lineWidth = 1
        
        layer?.addSublayer(shape)
    }
    
    ///
    /// Draws tick marks at the halfway travel point of the knob's travel range, i.e.
    /// the 0db marker.
    ///
    private func drawTick() {
        
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
