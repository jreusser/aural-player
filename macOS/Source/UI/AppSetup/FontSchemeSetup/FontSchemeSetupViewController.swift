//
//  FontSchemeSetupViewController.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import Cocoa

class FontSchemeSetupViewController: NSViewController {
    
    override var nibName: String? {"FontSchemeSetup"}
    
    @IBOutlet weak var lblName: NSTextField!
    @IBOutlet weak var btnScheme: NSPopUpButton!
    @IBOutlet weak var previewView: AppSetupThemePreviewView!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        let schemeName = appSetup.fontSchemePreset.name
        
        lblName.stringValue = schemeName
        
        previewView.colorScheme = colorSchemesManager.systemDefinedObject(named: appSetup.colorSchemePreset.name)
        previewView.fontScheme = fontSchemesManager.systemDefinedObject(named: schemeName)
        
        btnScheme.selectItem(withTitle: schemeName)
    }
    
    override func viewWillAppear() {
        
        super.viewWillAppear()
        previewView.colorScheme = colorSchemesManager.systemDefinedObject(named: appSetup.colorSchemePreset.name)
    }
    
    @IBAction func schemeSelectionAction(_ sender: Any) {
        
        guard let selSchemeName = btnScheme.titleOfSelectedItem,
              let scheme = fontSchemesManager.systemDefinedObject(named: selSchemeName),
              let preset = FontSchemePreset.presetByName(selSchemeName) else {return}
        
        lblName.stringValue = selSchemeName
        previewView.fontScheme = scheme
        
        appSetup.fontSchemePreset = preset
        print("Set font scheme to: \(appSetup.fontSchemePreset.rawValue)")
    }
}
