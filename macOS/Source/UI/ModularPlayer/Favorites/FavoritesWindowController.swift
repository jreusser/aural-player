//
//  FavoritesWindowController.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import AppKit

class FavoritesWindowController: NSWindowController {
    
    override var windowNibName: String? {"FavoritesWindow"}
    
    @IBOutlet weak var btnClose: NSButton!
    
    lazy var favoritesManagerViewController: FavoritesManagerViewController = .init()
    
    override func windowDidLoad() {
        
        super.windowDidLoad()
        
        window?.contentView?.addSubview(favoritesManagerViewController.view)
        favoritesManagerViewController.view.anchorToSuperview()
        btnClose.bringToFront()
        
//        colorSchemesManager.registerObserver(btnClose, forProperties: [\.buttonColor])
    }
    
    @IBAction func closeWindowAction(_ sender: NSButton) {
        self.close()
    }
}
