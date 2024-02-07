//
//  FuseBoxPopupMenuCell.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import AppKit

class FuseBoxPopupMenuCell: NSPopUpButtonCell {
    
    var cellInsetY: CGFloat {1}
    var rectRadius: CGFloat {2}
    var arrowXMargin: CGFloat {10}
    var arrowYMargin: CGFloat {7}
    
    var tintColor: PlatformColor = systemColorScheme.buttonColor {
        
        didSet {
            redraw()
        }
    }
    
    var arrowWidth: CGFloat {5}
    var arrowHeight: CGFloat {7}
    var arrowLineWidth: CGFloat {2}
    
    var titleFont: NSFont {systemFontScheme.normalFont}
//    var titleColor: NSColor {Colors.buttonMenuTextColor}
    
    override func drawTitle(_ title: NSAttributedString, withFrame: NSRect, in inView: NSView) -> NSRect {
        
        title.string.drawCentered(in: withFrame,
                                  withFont: titleFont, andColor: tintColor, yOffset: 1)
        
        return withFrame
    }
    
    override internal func drawBorderAndBackground(withFrame cellFrame: NSRect, in controlView: NSView) {
        
        let drawRect = cellFrame.insetBy(dx: 0, dy: -5)
        NSBezierPath.strokeRoundedRect(drawRect.insetBy(dx: 0.5, dy: 0.5), radius: rectRadius, withColor: tintColor)
        
        // Draw arrow
        let x = drawRect.maxX - arrowXMargin - arrowWidth, y = drawRect.maxY - ((drawRect.height - arrowHeight) / 2) + 1
        GraphicsUtils.drawArrow(tintColor, origin: NSMakePoint(x, y), dx: arrowWidth, dy: arrowHeight, lineWidth: arrowLineWidth)
    }
    
    override func titleRect(forBounds cellFrame: NSRect) -> NSRect {cellFrame}
}
