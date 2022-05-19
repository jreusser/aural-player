//
//  LibraryWindowController.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import Cocoa

class LibraryWindowController: NSWindowController {
    
    override var windowNibName: String? {"LibraryWindow"}
    
    @IBOutlet weak var rootContainer: NSBox!
    @IBOutlet weak var controlsBox: NSBox!

    @IBOutlet weak var btnClose: TintedImageButton!
    @IBOutlet weak var lblCaption: NSTextField!
    
    @IBOutlet weak var splitView: NSSplitView!
    
    // The tab group that switches between the 4 playlist views
    @IBOutlet weak var tabGroup: NSTabView!
    
    // Spinner that shows progress when tracks are being added to any of the playlists.
    @IBOutlet weak var progressSpinner: NSProgressIndicator!
    
    private lazy var sidebarController: LibrarySidebarViewController = LibrarySidebarViewController()
    
//    private lazy var messenger: Messenger = Messenger(for: self)
    
    override func windowDidLoad() {
        
        super.windowDidLoad()
        
        let sidebarView: NSView = sidebarController.view
        splitView.arrangedSubviews[0].addSubview(sidebarView)
        sidebarView.anchorToSuperview()

        colorSchemesManager.registerObserver(rootContainer, forProperty: \.backgroundColor)
        colorSchemesManager.registerObserver(btnClose, forProperty: \.buttonColor)
        
        fontSchemesManager.registerObserver(lblCaption, forProperty: \.captionFont)
        colorSchemesManager.registerObserver(lblCaption, forProperty: \.captionTextColor)
    }
    
    @IBAction func closeAction(_ sender: Any) {
        windowLayoutsManager.toggleWindow(withId: .library)
    }
}
