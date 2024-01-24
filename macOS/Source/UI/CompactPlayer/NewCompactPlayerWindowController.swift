//
//  NewCompactPlayerWindowController.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import AppKit
import SwiftUI

class NewCompactPlayerWindowController: NSWindowController {
    
    override var windowNibName: NSNib.Name? {"NewCompactPlayer"}
    
    @IBOutlet weak var rootContainerBox: NSBox!
    var playerView: NSHostingView<CompactPlayerView>!
    
    override func windowDidLoad() {
        
        window?.isMovableByWindowBackground = true
        window?.center()
        
        playerView = NSHostingView(rootView: CompactPlayerView())
        playerView.setFrameSize(NSSize(width: 300, height: 430))
        
        rootContainerBox.addSubview(playerView)
        
//        if #available(macOS 13.0, *) {
//            playerView.sizingOptions = .maxSize
//        } else {
//            // Fallback on earlier versions
//        }
    }
}
