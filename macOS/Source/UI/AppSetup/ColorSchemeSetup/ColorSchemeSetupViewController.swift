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
    @IBOutlet weak var previewView: ColorSchemePreviewView!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        let defaultSchemeName = ColorSchemePreset.defaultScheme.name
        
        lblName.stringValue = defaultSchemeName
        
//        previewView.scheme = ColorSchemePreset.defaultScheme
        btnScheme.selectItem(withTitle: defaultSchemeName)
    }
    
    @IBAction func schemeSelectionAction(_ sender: Any) {
        
        guard let selSchemeName = btnScheme.titleOfSelectedItem,
              let preset = ColorSchemePreset.presetByName(selSchemeName) else {return}
        
        lblName.stringValue = selSchemeName
        
        appSetup.colorScheme = preset
    }
}

