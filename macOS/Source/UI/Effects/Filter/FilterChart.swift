//
//  FilterChart.swift
//  Aural
//
//  Copyright © 2023 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

class FilterChart: NSView, ColorSchemeObserver {

    var bandsDataFunction: (() -> [FilterBand]) = {[]}
    var filterUnit: FilterUnitDelegateProtocol = audioGraphDelegate.filterUnit
    
    var textFont: NSFont {
        systemFontScheme.effectsPrimaryFont
    }
    
    private let offset: CGFloat = 0
    private let bottomMargin: CGFloat = 0
    private let lineWidth: CGFloat = 2
    
//    private let xMarks: [CGFloat] = [31, 63, 125, 250, 500, 1000, 2000, 4000, 8000, 16000]
    
    private lazy var messenger: Messenger = Messenger(for: self)
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        
//        colorSchemesManager.registerSchemeObserver(self, forProperties: [\.activeControlColor, \.inactiveControlColor])
        
        messenger.subscribe(to: .filterUnit_bandUpdated, handler: redraw)
        messenger.subscribe(to: .filterUnit_bandBypassStateUpdated, handler: redraw)
    }
    
    func colorChanged(to newColor: PlatformColor, forProperty property: ColorSchemeProperty) {
        redraw()
    }
    
    func colorSchemeChanged() {
        redraw()
    }
    
    override func draw(_ dirtyRect: NSRect) {
        
        let unitState: EffectsUnitState = filterUnit.state
        
        let width = self.width - 2 * offset
        let height = self.height
        let scale: CGFloat = width / 3

        let frameRect: NSRect = NSRect(x: offset, y: 0, width: width, height: height)

        var drawPath = NSBezierPath(rect: frameRect)
        drawPath.stroke(withColor: systemColorScheme.inactiveControlColor, lineWidth: 1)
        
        guard unitState == .active else {return}

        // Draw bands
        let bands = bandsDataFunction()
        let sortedBands = bands.sorted(by: {b1, b2 in
            
            if b2.type.equalsOneOf(.lowPass, .highPass), b1.type.equalsOneOf(.bandPass, .bandStop) {
                return true
            }
            
            if b1.type.equalsOneOf(.lowPass, .highPass), b2.type.equalsOneOf(.bandPass, .bandStop) {
                return false
            }
            
            return true
        })

        for band in sortedBands {
            
            guard !band.bypass else {continue}

            switch band.type {

            case .bandPass, .bandStop:

                guard let min = band.minFreq, let max = band.maxFreq else {continue}

                let x1 = log10(min/2) - 1
                let x2 = log10(max/2) - 1

                let rx1 = offset + CGFloat(x1) * scale
                let rx2 = offset + CGFloat(x2) * scale

                let color = unitState == .active ? (band.type == .bandStop ? systemColorScheme.inactiveControlColor : systemColorScheme.activeControlColor) : systemColorScheme.inactiveControlColor

                let brect = NSRect(x: rx1, y: bottomMargin, width: rx2 - rx1, height: height)
                drawPath = NSBezierPath(rect: brect)

                drawPath.fill(withColor: color)

            case .lowPass, .highPass:
                
                let freq = band.type == .lowPass ? band.maxFreq : band.minFreq
                guard let f = freq else {continue}

                let x = log10(f/2) - 1
                let rx = min(offset + CGFloat(x) * scale, frameRect.maxX - lineWidth / 2)

                GraphicsUtils.drawLine(systemColorScheme.activeControlColor, pt1: NSPoint(x: rx, y: bottomMargin), pt2: NSPoint(x: rx, y: bottomMargin + height), width: lineWidth)
            }
        }
//
//        // Draw X-axis markings
//
//        for y in xMarks {
//
//            let x = log10(y/2) - 1
//            let sx = offset + x * scale
//
//            let intY: Int = Int(y)
//
//            let text: String
//            if intY % 1000 == 0 {
//                text = String(format: "%dk", intY / 1000)
//            } else {
//                text = String(describing: intY)
//            }
//
//            let tw = text.size(withFont: textFont).width
//            let tx = offset + (x * scale) - (tw / 2)
//
//            let trect = NSRect(x: tx, y: bottomMargin + height / 2 + 2, width: tw + 10, height: 15)
//            text.draw(in: trect, withFont: textFont, andColor: textColor)
//
//            if (sx != offset && sx != offset + width) {
//
//                GraphicsUtils.drawLine(.gray, pt1: NSPoint(x: sx, y: bottomMargin + height / 2), pt2:
//                                        NSPoint(x: sx, y: bottomMargin + height / 2 + 5), width: 1.5)
//            }
//        }
    }
}
