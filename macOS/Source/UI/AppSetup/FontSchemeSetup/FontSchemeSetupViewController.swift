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
    @IBOutlet weak var previewView: FontSchemePreviewView!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        let defaultSchemeName = appSetup.fontScheme.name
        
        lblName.stringValue = defaultSchemeName
        
//        previewView.scheme = ColorSchemePreset.defaultScheme.sc
        btnScheme.selectItem(withTitle: defaultSchemeName)
    }
    
    @IBAction func schemeSelectionAction(_ sender: Any) {
        
        guard let selSchemeName = btnScheme.titleOfSelectedItem,
              let preset = FontSchemePreset.presetByName(selSchemeName) else {return}
        
        lblName.stringValue = selSchemeName
        
        appSetup.fontScheme = preset
        print("Set font scheme to: \(appSetup.fontScheme.rawValue)")
    }
}
