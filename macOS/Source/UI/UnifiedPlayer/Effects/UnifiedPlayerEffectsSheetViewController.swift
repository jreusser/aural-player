//
//  UnifiedPlayerEffectsSheetViewController.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import AppKit

class UnifiedPlayerEffectsSheetViewController: NSViewController {
    
    override var nibName: NSNib.Name? {"UnifiedPlayerEffects"}
    
    @IBOutlet weak var btnClose: TintedImageButton!
    @IBOutlet weak var effectsViewController: EffectsContainerViewController!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        view.addSubview(effectsViewController.view)
        
        btnClose.bringToFront()
        
        colorSchemesManager.registerSchemeObserver(self)
        colorSchemesManager.registerPropertyObserver(self, forProperty: \.buttonColor, changeReceiver: btnClose)
    }
    
    @IBAction func closeAction(_ sender: NSButton) {
        self.dismiss(self)
    }
}

extension UnifiedPlayerEffectsSheetViewController: ColorSchemeObserver {
    
    func colorSchemeChanged() {
        btnClose.contentTintColor = systemColorScheme.buttonColor
    }
}
