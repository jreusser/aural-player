//
//  PlayerFontSchemeViewController.swift
//  Aural
//
//  Copyright © 2023 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

class PlayerFontSchemeViewController: NSViewController, FontSchemesViewProtocol {
    
    @IBOutlet weak var primaryStepper: FontSizeStepper!
    @IBOutlet weak var secondaryStepper: FontSizeStepper!
    @IBOutlet weak var tertiaryStepper: FontSizeStepper!
    
    override var nibName: NSNib.Name? {"PlayerFontScheme"}
    
    func resetFields(_ fontScheme: FontScheme) {
        loadFontScheme(fontScheme)
    }
    
    func loadFontScheme(_ fontScheme: FontScheme) {
        
        primaryStepper.fontSize = fontScheme.prominentFont.pointSize
        secondaryStepper.fontSize = fontScheme.normalFont.pointSize
        tertiaryStepper.fontSize = fontScheme.smallFont.pointSize
    }
    
    func applyFontScheme(_ context: FontSchemeChangeContext, to fontScheme: FontScheme) {
        
        let fontName = context.textFontName
        
        fontScheme.prominentFont = NSFont(name: fontName, size: primaryStepper.fontSize)!
        fontScheme.normalFont = NSFont(name: fontName, size: secondaryStepper.fontSize)!
        fontScheme.smallFont = NSFont(name: fontName, size: tertiaryStepper.fontSize)!
    }
}
