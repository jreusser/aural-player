//
//  EffectsFontSchemeViewController.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

class EffectsFontSchemeViewController: NSViewController, FontSchemesViewProtocol {
    
    @IBOutlet weak var scrollView: NSScrollView!
    
    @IBOutlet weak var unitCaptionStepper: FontSizeStepper!
    @IBOutlet weak var unitFunctionStepper: FontSizeStepper!
    @IBOutlet weak var masterUnitFunctionStepper: FontSizeStepper!
    @IBOutlet weak var filterChartStepper: FontSizeStepper!
    
    @IBOutlet weak var auTableRowYOffsetStepper: NSStepper!
    @IBOutlet weak var txtAUTableRowYOffset: NSTextField!
    
    override var nibName: NSNib.Name? {"EffectsFontScheme"}
    
    func resetFields(_ fontScheme: FontScheme) {
        
        scrollView.scrollToTop()
        loadFontScheme(fontScheme)
    }
        
    func loadFontScheme(_ fontScheme: FontScheme) {
        
        let scheme = fontScheme.effects
        
        unitCaptionStepper.fontSize = fontScheme.captionFont.pointSize
        unitFunctionStepper.fontSize = scheme.unitFunctionFont.pointSize
        masterUnitFunctionStepper.fontSize = scheme.masterUnitFunctionFont.pointSize
        filterChartStepper.fontSize = scheme.filterChartFont.pointSize
        
        auTableRowYOffsetStepper.integerValue = scheme.auRowTextYOffset.roundedInt
        txtAUTableRowYOffset.stringValue = String(format: "%d px", auTableRowYOffsetStepper.integerValue)
    }
    
    @IBAction func auTableRowYOffsetStepperAction(_ sender: NSStepper) {
        txtAUTableRowYOffset.stringValue = String(format: "%d px", auTableRowYOffsetStepper.integerValue)
    }
    
    func applyFontScheme(_ context: FontSchemeChangeContext, to fontScheme: FontScheme) {
        
        let textFontName = context.textFontName
        let headingFontName = context.headingFontName
        
        fontScheme.captionFont = NSFont(name: headingFontName, size: unitCaptionStepper.fontSize)!
        fontScheme.effects.unitFunctionFont = NSFont(name: textFontName, size: unitFunctionStepper.fontSize)!
        fontScheme.effects.masterUnitFunctionFont = NSFont(name: headingFontName, size: masterUnitFunctionStepper.fontSize)!
        fontScheme.effects.filterChartFont = NSFont(name: textFontName, size: filterChartStepper.fontSize)!
        fontScheme.effects.auRowTextYOffset = CGFloat(auTableRowYOffsetStepper.integerValue)
    }
}
