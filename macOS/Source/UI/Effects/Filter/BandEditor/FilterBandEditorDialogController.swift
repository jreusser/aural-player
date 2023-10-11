//
//  FilterBandWindowController.swift
//  Aural
//
//  Copyright © 2023 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import Cocoa

class FilterBandEditorDialogController: NSWindowController {
    
    override var windowNibName: String? {"FilterBandEditorDialog"}
    
    @IBOutlet weak var lblWindowCaption: NSTextField!
    @IBOutlet weak var btnClose: NSButton!
    @IBOutlet weak var btnDone: NSButton!
    @IBOutlet weak var rootContainerBox: NSBox!
    @IBOutlet weak var bandView: FilterBandView!
    
    private var filterUnit: FilterUnitDelegateProtocol = audioGraphDelegate.filterUnit
    
    var bandIndex: Int! {
        
        didSet {
            bandView?.bandIndex = self.bandIndex
            lblWindowCaption?.stringValue = "Filter Band# \(bandIndex + 1)"
        }
    }
    
    override func windowDidLoad() {
        
        super.windowDidLoad()
        window?.isMovableByWindowBackground = true
        
        lblWindowCaption.stringValue = "Filter Band# \(bandIndex + 1)"
        bandView.initialize(band: filterUnit[bandIndex], at: bandIndex)
        
        fontSchemesManager.registerObserver(lblWindowCaption, forProperty: \.captionFont)
        fontSchemesManager.registerObservers([btnClose, btnDone], forProperty: \.effectsSecondaryFont)
        
        colorSchemesManager.registerObserver(rootContainerBox, forProperty: \.backgroundColor)
        colorSchemesManager.registerObserver(btnClose, forProperty: \.buttonColor)
        colorSchemesManager.registerSchemeObserver(btnDone, forProperties: [\.buttonColor, \.primaryTextColor])
        colorSchemesManager.registerObserver(lblWindowCaption, forProperty: \.captionTextColor)
    }
    
    @IBAction func doneAction(_ sender: NSButton) {
        close()
    }
}
