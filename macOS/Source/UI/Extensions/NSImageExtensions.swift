//
//  NSImageExtensions.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

extension NSImage {
    
    convenience init(gradientColors: [NSColor], imageSize: NSSize) {
        
        let gradient = NSGradient(colors: gradientColors)!
        let rect = NSRect(origin: CGPoint.zero, size: imageSize)
        self.init(size: rect.size)
        
        let path = NSBezierPath(rect: rect)
        self.lockFocus()
        gradient.draw(in: path, angle: 90.0)
        self.unlockFocus()
    }
    
    func writeToFile(fileType: NSBitmapImageRep.FileType, file: URL) throws {
        
        if let bits = self.representations.first as? NSBitmapImageRep,
           let data = bits.representation(using: fileType, properties: [:]) {
            
            try data.write(to: file)
        }
    }
    
    // Returns a copy of this image filled with a given color. Used by several UI components for system color scheme conformance.
    func filledWithColor(_ color: NSColor) -> NSImage {

        let image = self.copy() as! NSImage
        image.lockFocus()

        color.set()

        let imageRect = NSRect(origin: NSZeroPoint, size: image.size)
        imageRect.fill(using: .sourceAtop)

        image.unlockFocus()
        
        return image
    }
    
    // Returns a copy of this image tinted with a given color. Used by several UI components for system color scheme conformance.
    func tintedWithColor(_ color: NSColor) -> NSImage {
        
        let image = self.copy() as! NSImage
        image.lockFocus()
        
        color.set()
        
        let imageRect = NSRect(origin: NSZeroPoint, size: image.size)
        imageRect.fill(using: .sourceAtop)
        
        image.unlockFocus()
        
        return image
    }
    
    func copy(ofSize size: NSSize) -> NSImage {
        
        let copy = self.copy() as! NSImage
        copy.size = size
        return copy
    }
    
    func imageCopy() -> NSImage {
        self.copy() as! NSImage
    }
}
