//
//  PlayQueueWindowController.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import Cocoa

class PlayQueueWindowController: NSWindowController {
    
    override var windowNibName: String? {"PlayQueueWindow"}
    
    // The tab group that switches between the 4 playlist views
    @IBOutlet weak var tabGroup: AuralTabView!
    
    private var compactViewController: CompactPlayQueueViewController = .init()
    
    override func windowDidLoad() {
        
        super.windowDidLoad()
        
        let compactView = compactViewController.view
        tabGroup.addViewsForTabs([compactView])
        compactView.anchorToSuperview()
    }
    
    override func destroy() {
        // TODO: 
    }
}
