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

class EQSlider: EffectsUnitSlider {
    
    override func setNeedsDisplay(_ invalidRect: NSRect) {
        super.setNeedsDisplay(bounds)
    }
}
//
//    // ------------------------------------------------------------------------
//
//    // MARK: Constants
//
//    private let barRadius: CGFloat = 0.75
//    private let barWidth: CGFloat = 7
//    private let barInsetY: CGFloat = 0
//
//    private let tickInset: CGFloat = 1.5
//    private let tickWidth: CGFloat = 2
//
//    private let knobHeight: CGFloat = 30
//    private let knobRadius: CGFloat = 1
//    private let knobWidthOutsideBar: CGFloat = 7
//
//    // ------------------------------------------------------------------------
//
//    // MARK: Properties
//    
//    override var isFlipped: Bool {false}
//
//    var foregroundGradient: NSGradient {
//
//        switch unitState {
//
//        case .active:   return Colors.Effects.activeSliderGradient
//
//        case .bypassed: return Colors.Effects.bypassedSliderGradient
//
//        case .suppressed:   return Colors.Effects.suppressedSliderGradient
//
//        }
//    }
//
//    var backgroundGradient: NSGradient {
//        Colors.Effects.sliderBackgroundGradient
//    }
//
//    var knobColor: NSColor {
//        Colors.Effects.sliderKnobColorForState(unitState)
//    }
//
//    override init(frame: NSRect) {
//
//        super.init(frame: frame)
//        postInit()
//    }
//
//    required init?(coder: NSCoder) {
//
//        super.init(coder: coder)
//        postInit()
//    }
//
//    private var theLayer: CALayer {layer!}
//
//    private func postInit() {
//        wantsLayer = true
//    }
//
//    var progress: CGFloat {
//        CGFloat((doubleValue - minValue) / (maxValue - minValue))
//    }
//
//    var knobTravelRange: CGFloat {
//        bounds.height - knobHeight
//    }
//
//    var knobRect: CGRect {
//
//        let knobInset = bounds.width / 2 - barWidth / 2 - knobWidthOutsideBar
//        let knobWidth = barWidth + 2 * knobWidthOutsideBar
//        let knobCenterY = bounds.minY + knobHeight / 2 + progress * knobTravelRange
//
//        return CGRect(x: knobInset, y: knobCenterY - knobHeight / 2, width: knobWidth, height: knobHeight)
//    }
//
//    var barRect: CGRect {
//        bounds.insetBy(dx: bounds.width / 2 - barWidth / 2, dy: 0)
//    }
//
//    func drawKnob(_ knobRect: CGRect) {
//
//        let rectHeight = knobRect.height
//        let bar = barRect
//        let yCenter = knobRect.minY + (rectHeight / 2)
//
//        let knobWidth: CGFloat = bar.width + knobWidthOutsideBar
//        let knobMinY = yCenter - (knobHeight / 2)
//        let rect = NSRect(x: bar.minX - ((knobWidth - bar.width) / 2), y: knobMinY, width: knobWidth, height: knobHeight)
//
//        let shape = CAShapeLayer(fillingRoundedRect: rect, radius: knobWidth / 2, withColor: .black)
//        theLayer.addSublayer(shape)
//
//        let shape2 = CAShapeLayer(fillingRoundedRect: rect.insetBy(dx: 2, dy: 2), radius: knobWidth / 2 - 1, withColor: .blue)
//        theLayer.addSublayer(shape2)
////        NSBezierPath.fillRoundedRect(rect, radius: knobRadius, withColor: knobColor)
//    }
//
//    func drawBar(inside drawRect: NSRect, flipped: Bool) {
//
//        let knobFrame = knobRect
//        let halfKnobWidth = knobFrame.width / 2
//
//        let bottomRect = NSRect(x: drawRect.minX, y: drawRect.minY,
//                             width: drawRect.width, height: knobFrame.minY + halfKnobWidth)
//
//        let topRect = NSRect(x: drawRect.minX, y: knobFrame.maxY - halfKnobWidth,
//                                width: drawRect.width, height: drawRect.height - knobFrame.maxY + halfKnobWidth)
//
//        let bottomShape = CAShapeLayer(fillingRoundedRect: bottomRect, radius: barWidth / 2, withColor: .blue)
//        theLayer.addSublayer(bottomShape)
//
//        // Bottom rect
////        NSBezierPath.fillRoundedRect(bottomRect, radius: barRadius, withGradient: foregroundGradient, angle: -.verticalGradientDegrees)
//
//        let topShape = CAShapeLayer(fillingRoundedRect: topRect, radius: barWidth / 2, withColor: .darkGray)
//        theLayer.addSublayer(topShape)
//
//        // Top rect
////        NSBezierPath.fillRoundedRect(topRect, radius: barRadius, withGradient: backgroundGradient, angle: -.verticalGradientDegrees)
//
//        // Draw one tick across the center of the bar (marking 0dB)
//        let tickMinX = drawRect.minX + tickInset
//        let tickMaxX = drawRect.maxX - tickInset
//
//        let tickRect = rectOfTickMark(at: 0)
//        let tickY = tickRect.centerY
//
//        // Tick
////        GraphicsUtils.drawLine(Colors.Effects.sliderTickColor, pt1: NSMakePoint(tickMinX, tickY), pt2: NSMakePoint(tickMaxX, tickY),
////                               width: tickWidth)
//    }
//
//    override func draw(_ dirtyRect: NSRect) {
//
//        theLayer.sublayers?.removeAll()
//
//        drawBar(inside: barRect, flipped: false)
//        drawKnob(knobRect)
//    }
//}
//
//extension CAShapeLayer {
//
//    ///
//    /// Convenience initializer to create a ``CAShapeLayer`` with a rectangle path and fill it with a solid color.
//    ///
//    convenience init(fillingRect rect: CGRect, withColor color: PlatformColor) {
//
//        self.init()
//
//        self.path = NSBezierPath(rect: rect).cgPath
//        self.fillColor = color.cgColor
//    }
//
//    ///
//    /// Convenience initializer to create a ``CAShapeLayer`` with a rounded rectangle path and fill it with a solid color.
//    ///
//    /// - Parameter radius:     Rounding radius for the rectangle.
//    ///
//    convenience init(fillingRoundedRect rect: CGRect, radius: CGFloat, withColor color: PlatformColor) {
//
//        self.init()
//
//        self.path = NSBezierPath(roundedRect: rect, cornerRadius: radius).cgPath
//        self.fillColor = color.cgColor
//    }
//}
//
//extension NSBezierPath {
//
//    ///
//    /// Convenience initializer to create an ``NSBezierPath`` with the given
//    /// rounded rectangle and corner radius.
//    ///
//    convenience init(roundedRect: NSRect, cornerRadius: CGFloat) {
//        self.init(roundedRect: roundedRect, xRadius: cornerRadius, yRadius: cornerRadius)
//    }
//
//    /// Converts this ``NSBezierPath`` to a ``CGPath`` (required by ``CALayer``).
//    var cgPath: CGPath {
//
//        let path = CGMutablePath()
//        var points = [CGPoint](repeating: .zero, count: 3)
//
//        for i in 0 ..< self.elementCount {
//            let type = self.element(at: i, associatedPoints: &points)
//
//            switch type {
//            case .moveTo: path.move(to: CGPoint(x: points[0].x, y: points[0].y) )
//            case .lineTo: path.addLine(to: CGPoint(x: points[0].x, y: points[0].y) )
//            case .curveTo: path.addCurve(      to: CGPoint(x: points[2].x, y: points[2].y),
//                                               control1: CGPoint(x: points[0].x, y: points[0].y),
//                                               control2: CGPoint(x: points[1].x, y: points[1].y) )
//            case .closePath: path.closeSubpath()
//
//            @unknown default:
//                NSLog("Encountered unknown CGPath element type:" + String(describing: type))
//            }
//        }
//        return path
//    }
//}
