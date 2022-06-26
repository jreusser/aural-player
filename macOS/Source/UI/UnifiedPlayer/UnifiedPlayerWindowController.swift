//
//  UnifiedPlayerWindowController.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import Cocoa

class UnifiedPlayerWindowController: NSWindowController {
    
    override var windowNibName: String? {"UnifiedPlayerWindow"}
    
    @IBOutlet weak var logoImage: TintedImageView!
    @IBOutlet weak var rootContainerBox: NSBox!
    
    @IBOutlet weak var btnQuit: TintedImageButton!
    @IBOutlet weak var btnMinimize: TintedImageButton!
    @IBOutlet weak var presentationModeMenuItem: TintedIconMenuItem!
    @IBOutlet weak var settingsMenuIconItem: TintedIconMenuItem!
    
    @IBOutlet weak var rootSplitView: NSSplitView!
    @IBOutlet weak var browserSplitView: NSSplitView!
    
    // The tab group that switches between the 4 playlist views
    @IBOutlet weak var tabGroup: NSTabView!
    
//    private lazy var nowPlayingController: NowPlayingViewController = NowPlayingViewController()
    private lazy var playerController: UnifiedPlayerViewController = UnifiedPlayerViewController()
    
    private lazy var sidebarController: UnifiedPlayerSidebarViewController = UnifiedPlayerSidebarViewController()
    
    private lazy var playQueueController: UnifiedPlayQueueViewController = UnifiedPlayQueueViewController()
    
    private lazy var libraryTracksController: LibraryTracksViewController = LibraryTracksViewController()
    private lazy var libraryArtistsController: LibraryArtistsViewController = LibraryArtistsViewController()
    private lazy var libraryAlbumsController: LibraryAlbumsViewController = LibraryAlbumsViewController()
    private lazy var libraryGenresController: LibraryGenresViewController = LibraryGenresViewController()
    private lazy var libraryDecadesController: LibraryDecadesViewController = LibraryDecadesViewController()
    
    private lazy var tuneBrowserViewController: TuneBrowserViewController = TuneBrowserViewController()
    
    private lazy var playlistsViewController: PlaylistsViewController = PlaylistsViewController()
    
    private lazy var messenger: Messenger = Messenger(for: self)
    
    // One-time setup
    override func windowDidLoad() {
        
        // TODO: Clean this up
        theWindow.setIsVisible(false)
        initWindow()
        theWindow.setIsVisible(false)
        
//        setUpEventHandling()
        initSubscriptions()
        
        super.windowDidLoad()
        
        playerController.forceLoadingOfView()
        
        rootSplitView.addAndAnchorSubView(playerController.view, underArrangedSubviewAt: 0)
        browserSplitView.addAndAnchorSubView(sidebarController.view, underArrangedSubviewAt: 0)
        
        tabGroup.addAndAnchorSubView(forController: playQueueController)
        
        tabGroup.addAndAnchorSubView(forController: libraryTracksController)
        tabGroup.addAndAnchorSubView(forController: libraryArtistsController)
        tabGroup.addAndAnchorSubView(forController: libraryAlbumsController)
        tabGroup.addAndAnchorSubView(forController: libraryGenresController)
        tabGroup.addAndAnchorSubView(forController: libraryDecadesController)
        
        tabGroup.addAndAnchorSubView(forController: tuneBrowserViewController)
        
        tabGroup.addAndAnchorSubView(forController: playlistsViewController)
        
        tabGroup.selectTabViewItem(at: 0)
        
        messenger.subscribe(to: .unifiedPlayer_showBrowserTabForItem, handler: showBrowserTab(forItem:))
        messenger.subscribe(to: .unifiedPlayer_showBrowserTabForCategory, handler: showBrowserTab(forCategory:))
    }
    
    // Set window properties
    private func initWindow() {
        
        theWindow.makeKeyAndOrderFront(self)
        
//        containerBox.addSubview(playerViewController.view)

        colorSchemesManager.registerObserver(rootContainerBox, forProperty: \.backgroundColor)
        colorSchemesManager.registerObserver(logoImage, forProperty: \.captionTextColor)
        
        colorSchemesManager.registerObservers([btnQuit, btnMinimize, presentationModeMenuItem, settingsMenuIconItem],
                                              forProperty: \.buttonColor)
        
        applyTheme()
    }
    
    private func initSubscriptions() {
        
        messenger.subscribe(to: .applyTheme, handler: applyTheme)
        messenger.subscribe(to: .windowAppearance_changeCornerRadius, handler: changeWindowCornerRadius(_:))
    }
    
    override func destroy() {
        
        close()
//        viewController.destroy()
        messenger.unsubscribeFromAll()
    }
    
    // MARK: Actions -----------------------------------------------------------
    
    // Quits the app
    @IBAction func quitAction(_ sender: AnyObject) {
        NSApp.terminate(self)
    }
    
    // Minimizes the window (and any child windows)
    @IBAction func minimizeAction(_ sender: AnyObject) {
        theWindow.miniaturize(self)
    }
    
    @IBAction func modularModeAction(_ sender: AnyObject) {
        messenger.publish(.application_switchMode, payload: AppMode.modular)
    }
    
    @IBAction func menuBarModeAction(_ sender: AnyObject) {
        messenger.publish(.application_switchMode, payload: AppMode.menuBar)
    }
    
    @IBAction func controlBarModeAction(_ sender: AnyObject) {
        messenger.publish(.application_switchMode, payload: AppMode.controlBar)
    }
    
    // MARK: Message handling -----------------------------------------------------------
    
    private func applyTheme() {
        changeWindowCornerRadius(windowAppearanceState.cornerRadius)
    }
    
    func changeWindowCornerRadius(_ radius: CGFloat) {
        rootContainerBox.cornerRadius = radius
    }
    
    private func showBrowserTab(forItem item: UnifiedPlayerSidebarItem) {
        
        let tab = item.browserTab

        if tab == .playlists {
            messenger.publish(.playlists_showPlaylist, payload: item.displayName)
            
        } else if tab == .fileSystem,
                  let folderURL = item.tuneBrowserURL {
                
            tuneBrowserViewController.showURL(folderURL)
        }
        
        tabGroup.selectTabViewItem(at: tab.rawValue)
    }
    
    private func showBrowserTab(forCategory category: UnifiedPlayerSidebarCategory) {

        let tab = category.browserTab
        tabGroup.selectTabViewItem(at: tab.rawValue)
//
//        if tab == .playlists {
//
//        }
    }
}

extension NSTabView {
    
    func addAndAnchorSubView(forController controller: NSViewController) {
        
        addTabViewItem(NSTabViewItem(viewController: controller))
        controller.view.anchorToSuperview()
    }
}

extension NSSplitView {
    
    func addAndAnchorSubView(_ subView: NSView, underArrangedSubviewAt index: Int) {
        
        arrangedSubviews[index].addSubview(subView)
        subView.anchorToSuperview()
    }
}

class UnifiedPlayerSplitView: NSSplitView {
    
    override func resetCursorRects() {
        // Do nothing
    }
}
