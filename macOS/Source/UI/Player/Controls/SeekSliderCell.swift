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
    
    var isComplete: Bool {end != nil}
}

// Cell for seek position slider
class SeekSliderCell: HorizontalSliderCell {
    
    override var knobHeightOutsideBar: CGFloat {4}
    
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
        
        guard let loop = self.loop else {
            
            super.drawBar(inside: aRect, flipped: flipped)
            return
        }
        
        drawBackground(inRect: aRect)
        
        // Render segment playback loop, if one is defined
        
        let knobFrame = knobRect(flipped: false)
        
        // Start and end points for the loop
        let startX = loop.start
        let endX = loop.end ?? max(startX + 1, knobFrame.minX + halfKnobWidth)
        
        // Loop
        
        NSBezierPath.fillRoundedRect(NSRect(x: startX, y: aRect.minY, width: (endX - startX + 1), height: aRect.height),
                                     radius: barRadius,
                                     withGradient: foregroundGradient,
                                     angle: gradientDegrees)
    }
}
