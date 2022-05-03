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
    
    @IBOutlet weak var bandView: FilterBandView!
    
    private var filterUnit: FilterUnitDelegateProtocol = audioGraphDelegate.filterUnit
    
    var bandIndex: Int! {
        
        didSet {
            bandView?.bandIndex = self.bandIndex
            window?.title = "Edit Filter band# \(bandIndex + 1)"
        }
    }
    
    override func windowDidLoad() {
        
        super.windowDidLoad()
        bandView.initialize(band: filterUnit[bandIndex], at: bandIndex)
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
