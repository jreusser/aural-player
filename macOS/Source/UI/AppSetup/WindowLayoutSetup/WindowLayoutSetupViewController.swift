//
//  WindowLayoutSetupViewController.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import Cocoa

class WindowLayoutSetupViewController: NSViewController {
    
    override var nibName: String? {"WindowLayoutSetup"}
    
    @IBOutlet weak var lblName: NSTextField!
    @IBOutlet weak var lblDescription: NSTextField!
    @IBOutlet weak var btnLayout: NSPopUpButton!
    @IBOutlet weak var previewView: PresetLayoutPreviewView!
    
    override func viewDidLoad() {
        
        let defaultLayoutName = WindowLayoutPresets.defaultLayout.name
        
        lblName.stringValue = defaultLayoutName
        lblDescription.stringValue = WindowLayoutPresets.defaultLayout.description
        
        previewView.drawPreviewForPreset(.defaultLayout)
        btnLayout.selectItem(withTitle: defaultLayoutName)
    }
    
    @IBAction func layoutSelectionAction(_ sender: Any) {
        
        guard let selLayoutTitle = btnLayout.titleOfSelectedItem, 
                let preset = WindowLayoutPresets.fromDisplayName(selLayoutTitle) else {return}
        
        lblName.stringValue = selLayoutTitle
        lblDescription.stringValue = preset.description
        
        previewView.drawPreviewForPreset(preset)
        appSetup.windowLayout = preset
    }
}
