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
    
    override var barInsetY: CGFloat {0}
    override var barRadius: CGFloat {1}
    
    private var foregroundColorKVO: NSKeyValueObservation?
    private var backgroundColorKVO: NSKeyValueObservation?
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        
        foregroundColorKVO = systemColorScheme.observe(\.activeControlColor, options: [.initial, .new]) {[weak self] _, _ in
            
            guard let strongSelf = self else {return}
            
            let start = systemColorScheme.activeControlColor
            let end = start.darkened(50)
            strongSelf._foregroundGradient = .init(starting: start, ending: end)!
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
    
    private var _foregroundGradient: NSGradient!
    
//    var loopColor: NSColor {Colors.Player.seekBarLoopColor}
    
    override var foregroundGradient: NSGradient {
        _foregroundGradient
    }
    
    lazy var backgroundGradient: NSGradient = recomputeBackgroundGradient()
    
    private func recomputeBackgroundGradient() -> NSGradient {
        
        let start = systemColorScheme.sliderBackgroundColor
        let end = start.darkened(25)
        
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
    
    override func drawBar(inside aRect: NSRect, flipped: Bool) {
        
        super.drawBar(inside: aRect, flipped: flipped)
        
//        drawLeftRect(inRect: aRect)
//        drawRightRect(inRect: aRect)
        
        // Render segment playback loop, if one is defined
//        if let loop = self.loop {
//
//            let halfKnobWidth = knobFrame.width / 2
//
//            // Start and end points for the loop
//            let startX = loop.start
//            let endX = loop.end ?? max(startX + 1, knobFrame.minX + halfKnobWidth)
//
//            // Loop bar
//
////            NSBezierPath.fillRoundedRect(NSRect(x: startX, y: aRect.minY, width: (endX - startX + 1), height: aRect.height),
////                                         radius: barRadius,
////                                         withColor: loopColor)
//
//            let markerMinY = knobFrame.minY + knobHeightOutsideBar / 2
//            let markerHeight: CGFloat = aRect.height + knobHeightOutsideBar
//
//            // Loop start marker
//
////            NSBezierPath.fillRoundedRect(NSRect(x: startX - (knobWidth / 2), y: markerMinY, width: knobWidth, height: markerHeight),
////                                         radius: knobRadius,
////                                         withColor: loopColor)
//
//            // Loop end marker
//            if loop.end != nil {
//
////                NSBezierPath.fillRoundedRect(NSRect(x: endX - (knobWidth / 2), y: markerMinY, width: knobWidth, height: markerHeight),
////                                             radius: knobRadius,
////                                             withColor: loopColor)
//            }
//        }
    }
}
