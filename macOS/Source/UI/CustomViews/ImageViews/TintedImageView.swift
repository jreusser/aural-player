//
//  TintedImageView.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

@IBDesignable
class TintedImageView: NSImageView, Tintable {
    
    override var image: NSImage? {
        
        didSet {
            image?.isTemplate = true
        }
    }
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        image?.isTemplate = true
    }
}
