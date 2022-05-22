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
    
    private lazy var libraryTracksController: LibraryTracksViewController = LibraryTracksViewController()
    private lazy var libraryAlbumsController: LibraryAlbumsViewController = LibraryAlbumsViewController()
    
    private lazy var messenger: Messenger = Messenger(for: self)
    
    override func windowDidLoad() {
        
        super.windowDidLoad()
        
        let libraryTracksView: NSView = libraryTracksController.view
        tabGroup.tabViewItem(at: 0).view?.addSubview(libraryTracksView)
        libraryTracksView.anchorToSuperview()
        
        let libraryAlbumsView: NSView = libraryAlbumsController.view
        tabGroup.tabViewItem(at: 2).view?.addSubview(libraryAlbumsView)
        libraryAlbumsView.anchorToSuperview()
        
        let sidebarView: NSView = sidebarController.view
        splitView.arrangedSubviews[0].addSubview(sidebarView)
        sidebarView.anchorToSuperview()
        
        messenger.subscribe(to: .library_showBrowserTab, handler: showBrowserTab(_:))

        colorSchemesManager.registerObserver(rootContainer, forProperty: \.backgroundColor)
        colorSchemesManager.registerObserver(btnClose, forProperty: \.buttonColor)
        
        fontSchemesManager.registerObserver(lblCaption, forProperty: \.captionFont)
        colorSchemesManager.registerObserver(lblCaption, forProperty: \.captionTextColor)
    }
    
    @IBAction func closeAction(_ sender: Any) {
        windowLayoutsManager.toggleWindow(withId: .library)
    }
    
    private func showBrowserTab(_ tab: LibraryBrowserTab) {
        tabGroup.selectTabViewItem(at: tab.rawValue)
    }
}
