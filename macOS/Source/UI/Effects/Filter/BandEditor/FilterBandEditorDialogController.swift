//
//  FilterBandWindowController.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import Cocoa

class FilterBandEditorDialogController: NSWindowController {
    
    override var windowNibName: String? {"FilterBandEditorDialog"}
    
    @IBOutlet weak var lblWindowCaption: NSTextField! {
        didSet {
            print("\nCaption LBL did set")
        }
    }
    
    
    @IBOutlet weak var rootContainerBox: NSBox!
    @IBOutlet weak var bandView: FilterBandView!
    
    private var filterUnit: FilterUnitDelegateProtocol = audioGraphDelegate.filterUnit
    
    var bandIndex: Int! {
        
        didSet {
            print("\nBand index SET")
            bandView?.bandIndex = self.bandIndex
            lblWindowCaption?.stringValue = "Filter band# \(bandIndex + 1)"
        }
    }
    
    override func windowDidLoad() {
        
        print("\nWindow did load, index is: \(bandIndex + 1)")
        
        super.windowDidLoad()
        
        window?.isMovableByWindowBackground = true
        
        lblWindowCaption?.stringValue = "Filter band 1"
        bandView.initialize(band: filterUnit[bandIndex], at: bandIndex)
        
        fontSchemesManager.registerObserver(lblWindowCaption, forProperty: \.captionFont)
        
        colorSchemesManager.registerObserver(rootContainerBox, forProperty: \.backgroundColor)
        colorSchemesManager.registerObserver(lblWindowCaption, forProperty: \.captionTextColor)
    }
    
//    override func showWindow(_ sender: Any?) {
//
//        let band = filterUnit[bandIndex]
//
//
//        super.showWindow(sender)
//    }
    
    @IBAction func doneAction(_ sender: NSButton) {
        close()
    }
}
