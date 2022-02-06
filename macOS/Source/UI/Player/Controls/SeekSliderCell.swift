//
//  SeekSliderCell.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

// Defines the range (start and end points) used to render a track segment playback loop
struct PlaybackLoopRange {
    
    // Both are X co-ordinates
    
    var start: CGFloat
    var end: CGFloat?
}

// Cell for seek position slider
class SeekSliderCell: HorizontalSliderCell {
    
    override var barInsetY: CGFloat {SystemUtils.isBigSur ? -1 : 0.5}
    
    override var barRadius: CGFloat {3}
    
    override var knobRadius: CGFloat {1}
    override var knobWidth: CGFloat {10}
    override var knobHeightOutsideBar: CGFloat {2}
    
    private var foregroundColorKVO: NSKeyValueObservation?
    private var backgroundColorKVO: NSKeyValueObservation?
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        
        foregroundColorKVO = systemColorScheme.observe(\.activeControlColor, options: [.initial, .new]) {[weak self] _, _ in
            
            guard let strongSelf = self else {return}
            strongSelf.foregroundGradient = strongSelf.recomputeForegroundGradient()
        }
        
        backgroundColorKVO = systemColorScheme.observe(\.sliderBackgroundColor, options: [.initial, .new]) {[weak self] _, _ in
            
            guard let strongSelf = self else {return}
            strongSelf.backgroundGradient = strongSelf.recomputeBackgroundGradient()
        }
    }
    
    deinit {
        
        backgroundColorKVO?.invalidate()
        backgroundColorKVO = nil
        
        foregroundColorKVO?.invalidate()
        foregroundColorKVO = nil
    }
    
//    var loopColor: NSColor {Colors.Player.seekBarLoopColor}
    lazy var foregroundGradient: NSGradient = recomputeForegroundGradient()
    
    private func recomputeForegroundGradient() -> NSGradient {
        
        let start = systemColorScheme.activeControlColor
        let end = start.darkened(25)
        
        return .init(starting: start, ending: end)!
    }
    
    lazy var backgroundGradient: NSGradient = recomputeBackgroundGradient()
    
    private func recomputeBackgroundGradient() -> NSGradient {
        
        let start = systemColorScheme.sliderBackgroundColor
        let end = start.brightened(25)
        
        return .init(starting: start, ending: end)!
    }
    
    var loop: PlaybackLoopRange?
    
    // Returns the center of the current knob frame
    var knobCenter: CGFloat {
        return knobRect(flipped: false).centerX
    }
    
    // Marks the rendering start point for a segment playback loop. The start argument is the X co-ordinate of the center of the knob frame at the loop start point
    func markLoopStart(_ start: CGFloat) {
        self.loop = PlaybackLoopRange(start: start, end: nil)
    }
    
    // Marks the rendering end point for a segment playback loop. The end argument is the X co-ordinate of the center of the knob frame at the loop end point
    func markLoopEnd(_ end: CGFloat) {
        self.loop?.end = end
    }
    
    // Invalidates the track segment playback loop
    func removeLoop() {
        self.loop = nil
    }
    
    func drawLeftRect(inRect rect: NSRect, knobFrame: NSRect) {
        
        let halfKnobWidth = knobFrame.width / 2
        let leftRect = NSRect(x: rect.minX, y: rect.minY, width: max(halfKnobWidth, knobFrame.minX + halfKnobWidth), height: rect.height)
        
        NSBezierPath.fillRoundedRect(leftRect, radius: barRadius, withGradient: foregroundGradient, angle: gradientDegrees)
    }
    
    func drawRightRect(inRect rect: NSRect, knobFrame: NSRect) {
        
        let halfKnobWidth = knobFrame.width / 2
        let rightRect = NSRect(x: knobFrame.maxX - halfKnobWidth, y: rect.minY,
                               width: rect.width - (knobFrame.maxX - halfKnobWidth), height: rect.height)
        
        NSBezierPath.fillRoundedRect(rightRect, radius: barRadius, withGradient: backgroundGradient, angle: gradientDegrees)
    }
    
    override func drawBar(inside aRect: NSRect, flipped: Bool) {
        
        let knobFrame = knobRect(flipped: false)
        
        drawLeftRect(inRect: aRect, knobFrame: knobFrame)
        drawRightRect(inRect: aRect, knobFrame: knobFrame)
        
        // Render segment playback loop, if one is defined
        if let loop = self.loop {
            
            let halfKnobWidth = knobFrame.width / 2

            // Start and end points for the loop
            let startX = loop.start
            let endX = loop.end ?? max(startX + 1, knobFrame.minX + halfKnobWidth)
            
            // Loop bar
            
//            NSBezierPath.fillRoundedRect(NSRect(x: startX, y: aRect.minY, width: (endX - startX + 1), height: aRect.height),
//                                         radius: barRadius,
//                                         withColor: loopColor)
            
            let markerMinY = knobFrame.minY + knobHeightOutsideBar / 2
            let markerHeight: CGFloat = aRect.height + knobHeightOutsideBar
            
            // Loop start marker
            
//            NSBezierPath.fillRoundedRect(NSRect(x: startX - (knobWidth / 2), y: markerMinY, width: knobWidth, height: markerHeight),
//                                         radius: knobRadius,
//                                         withColor: loopColor)
            
            // Loop end marker
            if loop.end != nil {
                
//                NSBezierPath.fillRoundedRect(NSRect(x: endX - (knobWidth / 2), y: markerMinY, width: knobWidth, height: markerHeight),
//                                             radius: knobRadius,
//                                             withColor: loopColor)
            }
        }
    }
    
    override func knobRect(flipped: Bool) -> NSRect {
        
        let bar = barRect(flipped: flipped)
        let val = CGFloat(self.doubleValue)
        
        let startX = bar.minX + (val * bar.width / 100)
        let xOffset = -(val * knobWidth / 100)
        
        let newX = startX + xOffset
        let newY = bar.minY - knobHeightOutsideBar
        
        return NSRect(x: newX, y: newY, width: knobWidth, height: knobHeightOutsideBar * 2 + bar.height)
    }
    
    override func drawKnob(_ knobRect: NSRect) {
        
//        let bar = barRect(flipped: true)
//        let knobHeight: CGFloat = bar.height + knobHeightOutsideBar
//        let knobMinX = knobRect.minX
        
//        NSBezierPath.fillRoundedRect(NSRect(x: knobMinX, y: bar.minY - ((knobHeight - bar.height) / 2), width: knobWidth, height: knobHeight),
//                                     radius: knobRadius,
//                                     withColor: knobColor)
    }
}
