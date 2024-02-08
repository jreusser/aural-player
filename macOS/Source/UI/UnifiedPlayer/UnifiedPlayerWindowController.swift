//
//  UnifiedPlayerWindowController.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
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
    
    lazy var buttonColorChangeReceivers: [ColorSchemePropertyChangeReceiver] = [btnQuit, btnMinimize, presentationModeMenuItem, settingsMenuIconItem]
    
    lazy var playerController: UnifiedPlayerViewController = UnifiedPlayerViewController()
    private lazy var effectsSheetViewController: EffectsSheetViewController = .init()
    
    private lazy var sidebarController: UnifiedPlayerSidebarViewController = UnifiedPlayerSidebarViewController()
    
    private lazy var playQueueController: PlayQueueContainerViewController = PlayQueueContainerViewController()
    
    private lazy var libraryTracksController: LibraryTracksViewController = LibraryTracksViewController()
    private lazy var libraryArtistsController: LibraryArtistsViewController = LibraryArtistsViewController()
    private lazy var libraryAlbumsController: LibraryAlbumsViewController = LibraryAlbumsViewController()
    private lazy var libraryGenresController: LibraryGenresViewController = LibraryGenresViewController()
    private lazy var libraryDecadesController: LibraryDecadesViewController = LibraryDecadesViewController()
    
    private lazy var tuneBrowserViewController: TuneBrowserViewController = TuneBrowserViewController()
    
    private lazy var playlistsViewController: PlaylistsViewController = PlaylistsViewController()
    
    lazy var messenger: Messenger = Messenger(for: self)
    
    var eventMonitor: EventMonitor! = EventMonitor()
    
    var gesturesPreferences: GesturesControlsPreferences {preferences.controlsPreferences.gestures}
    
    // One-time setup
    override func windowDidLoad() {
        
        // TODO: Clean this up
        theWindow.setIsVisible(false)
        initWindow()
        theWindow.setIsVisible(false)
        
        setUpEventHandling()
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
        
        colorSchemesManager.registerSchemeObserver(self)
        colorSchemesManager.registerPropertyObserver(self, forProperty: \.captionTextColor, changeReceiver: logoImage)
        colorSchemesManager.registerPropertyObserver(self, forProperty: \.backgroundColor, changeReceiver: rootContainerBox)
        colorSchemesManager.registerPropertyObserver(self, forProperty: \.buttonColor, changeReceivers: buttonColorChangeReceivers)
        
        applyTheme()
    }
    
    private func initSubscriptions() {
        
        messenger.subscribe(to: .applyTheme, handler: applyTheme)
        messenger.subscribe(to: .windowAppearance_changeCornerRadius, handler: changeWindowCornerRadius(_:))
    }
    
    override func destroy() {
        
        close()
        
        eventMonitor.stopMonitoring()
        eventMonitor = nil
        
        [playerController, sidebarController, playQueueController, libraryTracksController, libraryArtistsController, libraryAlbumsController, libraryGenresController, libraryDecadesController, tuneBrowserViewController, playlistsViewController].forEach {$0.destroy()}
        
        messenger.unsubscribeFromAll()
    }
    
    // MARK: Actions -----------------------------------------------------------
    
    // Quits the app
    @IBAction func quitAction(_ sender: AnyObject) {
        
        unifiedPlayerUIState.windowFrame = theWindow.frame
        NSApp.terminate(self)
    }
    
    // Minimizes the window (and any child windows)
    @IBAction func minimizeAction(_ sender: AnyObject) {
        theWindow.miniaturize(self)
    }
    
    @IBAction func modularModeAction(_ sender: AnyObject) {
        appModeManager.presentMode(.modular)
    }
    
    @IBAction func compactModeAction(_ sender: AnyObject) {
        appModeManager.presentMode(.compact)
    }
    
    @IBAction func menuBarModeAction(_ sender: AnyObject) {
        appModeManager.presentMode(.menuBar)
    }
    
    @IBAction func controlBarModeAction(_ sender: AnyObject) {
        appModeManager.presentMode(.controlBar)
    }
    
    @IBAction func showEffectsPanelAction(_ sender: AnyObject) {
        playerController.presentAsSheet(effectsSheetViewController)
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
                  let folder = item.tuneBrowserFolder, let tree = item.tuneBrowserTree {
                       
                   tuneBrowserViewController.showFolder(folder, inTree: tree, updateHistory: true)
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

extension UnifiedPlayerWindowController: ColorSchemeObserver {
    
    func colorSchemeChanged() {
        
        rootContainerBox.fillColor = systemColorScheme.backgroundColor
        
        buttonColorChangeReceivers.forEach {
            $0.colorChanged(systemColorScheme.buttonColor)
        }
    }
}
