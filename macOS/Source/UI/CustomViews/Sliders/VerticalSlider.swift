//
//  VerticalSlider.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import AppKit

class VerticalSlider: EffectsUnitSlider {
    
    // MARK: Constants / state
    
    // Change these values to customize the appearance of the slider.
    
    /// Total width of the slider bar.
    private var barWidth: CGFloat {4}
    
    /// Spacing distance between the bar and the ticks.
    private static let tickSpacingFromBar: CGFloat = 5
    
    /// Height (thickness) of each tick.
    private static let tickHeight: CGFloat = 1
    
    ///
    /// We don't want a flipped co-ordinate system (Y axis).
    ///
    override var isFlipped: Bool {false}
    
    override var doubleValue: Double {
        
        get {super.doubleValue}
        
        set {
            super.doubleValue = newValue
            print("Set doubleValue to: \(newValue)")
        }
    }
    
    var range: Float = 0
    
    // --------------------------------------------------------------------------------
    
    // MARK: Initializers
    
    ///
    /// This slider will do all its drawing on CALayers, so
    /// make sure it has a base layer when initialized.
    ///
    required init?(coder: NSCoder) {
        
        super.init(coder: coder)
        wantsLayer = true
        self.range = Float(maxValue - minValue)
    }
    
    // --------------------------------------------------------------------------------
    
    // MARK: View rendering
    
    ///
    /// Custom drawing for the slider.
    ///
    public override func draw(_ dirtyRect: NSRect) {
        
        // Remove previously drawn layers.
        layer?.sublayers?.removeAll()
        
        drawBackground()
        drawProgress()
    }
    
    ///
    /// Draws the background portion of the slider bar / track.
    ///
    func drawBackground() {
        
        let backgroundRect = bounds.insetBy(dx: (bounds.width - barWidth) / 2, dy: 0)
        layer?.addSublayer(CAShapeLayer(fillingRoundedRect: backgroundRect, radius: 1, withColor: systemColorScheme.sliderBackgroundColor))
    }
    
    ///
    /// A fractional number between 0 and 1 indicating the current travel of the slider's knob between
    /// its minValue and maxValue, based on its floatValue.
    ///
    /// Example:   If the slider has a minValue of 0, and a maxValue of 360, a floatValue of 90 would indicate
    ///         25% progress, i.e. 0.25.
    ///
    var progress: CGFloat {
        
        let dbl = self.floatValue
        let minus = dbl - Float(minValue)
        let prog = CGFloat((floatValue - Float(minValue)) / range)
        
        print("\nDrawing ... dbl=\(dbl), minus=\(minus), prog=\(prog)")
        return prog
    }
    
    ///
    /// Draws the progress portion of the slider bar / track, i.e. the portion
    /// between the minValue and floatValue (i.e. current value) of the
    /// slider.
    ///
    func drawProgress() {
        
        let insetRect = bounds.insetBy(dx: (bounds.width - barWidth) / 2, dy: 0)
        
        let highlightPosition = insetRect.minY + (progress * insetRect.height)
        let progressRect = CGRect(x: insetRect.minX, y: 0,
                                  width: insetRect.width,
                                  height: highlightPosition - insetRect.minY)
        
        let gradientRect = CGRect(x: 0, y: 0, width: progressRect.width, height: progressRect.height)
        
        let maskLayer = CAShapeLayer()
        maskLayer.path = NSBezierPath(roundedRect: gradientRect, cornerRadius: 1).cgPath
        maskLayer.anchorPoint = .zero
        maskLayer.masksToBounds = true
        maskLayer.bounds = gradientRect
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [systemColorScheme.activeControlColor, systemColorScheme.activeControlColor.darkened(50)].map {$0.cgColor}
        gradientLayer.type = .axial
        gradientLayer.startPoint = CGPoint(x: 0, y: 1)
        gradientLayer.endPoint = CGPoint(x: 0, y: 0)
        gradientLayer.frame = progressRect
        gradientLayer.mask = maskLayer
        
        layer?.addSublayer(gradientLayer)
    }
}
