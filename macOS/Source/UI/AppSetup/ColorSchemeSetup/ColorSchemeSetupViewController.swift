//
//  ColorSchemeSetupViewController.swift
//  Aural
//
//  Copyright © 2023 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import Cocoa

class ColorSchemeSetupViewController: NSViewController {
    
    override var nibName: String? {"ColorSchemeSetup"}
    
    @IBOutlet weak var lblName: NSTextField!
    @IBOutlet weak var btnScheme: NSPopUpButton!
    @IBOutlet weak var previewView: AppSetupThemePreviewView!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        let schemeName = appSetup.colorSchemePreset.name
        
        lblName.stringValue = schemeName
        
        previewView.colorScheme = colorSchemesManager.systemDefinedObject(named: schemeName)
        previewView.fontScheme = fontSchemesManager.systemDefinedObject(named: appSetup.fontSchemePreset.name)
        
        btnScheme.selectItem(withTitle: schemeName)
    }
    
    override func viewWillAppear() {
        
        super.viewWillAppear()
        previewView.fontScheme = fontSchemesManager.systemDefinedObject(named: appSetup.fontSchemePreset.name)
    }
    
    @IBAction func schemeSelectionAction(_ sender: Any) {
        
        guard let selSchemeName = btnScheme.titleOfSelectedItem,
              let scheme = colorSchemesManager.systemDefinedObject(named: selSchemeName),
        let colorSchemePreset = ColorSchemePreset.presetByName(selSchemeName) else {return}
        
        lblName.stringValue = selSchemeName
        previewView.colorScheme = scheme
        
        appSetup.colorSchemePreset = colorSchemePreset
        print("Set color scheme to: \(appSetup.colorSchemePreset.rawValue)")
    }
}
