//
//  LibraryWindowController.swift
//  Aural
//
//  Copyright © 2023 Kartik Venugopal. All rights reserved.
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
    
    @IBOutlet weak var buildProgressView: NSBox!
    @IBOutlet weak var buildIndeterminateSpinner: NSImageView!
    @IBOutlet weak var buildProgressSpinner: ProgressArc!
    @IBOutlet weak var lblBuildStats: NSTextField!
    
    private lazy var sidebarController: LibrarySidebarViewController = LibrarySidebarViewController()
    
    private lazy var libraryTracksController: LibraryTracksViewController = LibraryTracksViewController()
    private lazy var libraryArtistsController: LibraryArtistsViewController = LibraryArtistsViewController()
    private lazy var libraryAlbumsController: LibraryAlbumsViewController = LibraryAlbumsViewController()
    private lazy var libraryGenresController: LibraryGenresViewController = LibraryGenresViewController()
    private lazy var libraryDecadesController: LibraryDecadesViewController = LibraryDecadesViewController()
    private lazy var libraryImportedPlaylistsController: LibraryImportedPlaylistsViewController = .init()
    
    private lazy var tuneBrowserViewController: TuneBrowserViewController = TuneBrowserViewController()
    
    private lazy var playlistsViewController: PlaylistsViewController = PlaylistsViewController()
    
    private lazy var messenger: Messenger = Messenger(for: self)
    
    private lazy var buildProgressUpdateTask: RepeatingTaskExecutor = .init(intervalMillis: 500, task: {[weak self] in self?.updateBuildProgress()}, queue: .main)
    
    override func windowDidLoad() {
        
        super.windowDidLoad()
        
        let sidebarView: NSView = sidebarController.view
        splitView.arrangedSubviews[0].addSubview(sidebarView)
        sidebarView.anchorToSuperview()
        
        let libraryTracksView: NSView = libraryTracksController.view
        tabGroup.tabViewItem(at: 0).view?.addSubview(libraryTracksView)
        libraryTracksView.anchorToSuperview()
        
        let libraryArtistsView: NSView = libraryArtistsController.view
        tabGroup.tabViewItem(at: 1).view?.addSubview(libraryArtistsView)
        libraryArtistsView.anchorToSuperview()
        
        let libraryAlbumsView: NSView = libraryAlbumsController.view
        tabGroup.tabViewItem(at: 2).view?.addSubview(libraryAlbumsView)
        libraryAlbumsView.anchorToSuperview()

        let libraryGenresView: NSView = libraryGenresController.view
        tabGroup.tabViewItem(at: 3).view?.addSubview(libraryGenresView)
        libraryGenresView.anchorToSuperview()

        let libraryDecadesView: NSView = libraryDecadesController.view
        tabGroup.tabViewItem(at: 4).view?.addSubview(libraryDecadesView)
        libraryDecadesView.anchorToSuperview()
        
        let libraryImportedPlaylistsView: NSView = libraryImportedPlaylistsController.view
        tabGroup.tabViewItem(at: 5).view?.addSubview(libraryImportedPlaylistsView)
        libraryImportedPlaylistsView.anchorToSuperview()
        
        let tuneBrowserView: NSView = tuneBrowserViewController.view
        tabGroup.tabViewItem(at: 6).view?.addSubview(tuneBrowserView)
        tuneBrowserView.anchorToSuperview()
        
        let playlistsView: NSView = playlistsViewController.view
        tabGroup.tabViewItem(at: 7).view?.addSubview(playlistsView)
        playlistsView.anchorToSuperview()
        
        let windowShownFilter = {[weak self] in self?.theWindow.isVisible ?? false}
        messenger.subscribeAsync(to: .library_startedReadingFileSystem, handler: startedReadingFileSystem, filter: windowShownFilter)
        messenger.subscribeAsync(to: .library_startedAddingTracks, handler: startedAddingTracks, filter: windowShownFilter)
        messenger.subscribeAsync(to: .library_doneAddingTracks, handler: doneAddingTracks, filter: windowShownFilter)
        
        messenger.subscribe(to: .library_showBrowserTabForItem, handler: showBrowserTab(forItem:))
        messenger.subscribe(to: .windowAppearance_changeCornerRadius, handler: changeWindowCornerRadius(_:))

        colorSchemesManager.registerObserver(rootContainer, forProperty: \.backgroundColor)
        colorSchemesManager.registerObserver(btnClose, forProperty: \.buttonColor)
        
        fontSchemesManager.registerObserver(lblCaption, forProperty: \.captionFont)
        colorSchemesManager.registerObserver(lblCaption, forProperty: \.captionTextColor)
        
        applyTheme()
        
        // TODO: Temporary, remove this !!!
        tabGroup.selectTabViewItem(at: 0)
        
        displayBuildProgress()
    }
    
    override func destroy() {
        
        close()
        buildProgressUpdateTask.pause()
        messenger.unsubscribeFromAll()
    }
    
    override func showWindow(_ sender: Any?) {
        
        super.showWindow(sender)
        displayBuildProgress()
    }
    
    private func displayBuildProgress() {
        
        let buildProgress = libraryDelegate.buildProgress
        guard buildProgress.isBeingModified else {
            
            if buildProgressView.isShown {

                buildProgressView.hide()
                buildIndeterminateSpinner.animates = false
                buildProgressUpdateTask.stop()
            }
            
            sidebarController.sidebarView.enable()
            
            return
        }
        
        if buildProgressView.isHidden {
            buildProgressView.show()
        }
        
        sidebarController.sidebarView.disable()
        // TODO: Disable the rest of the window (mouse hover response and clicking on the right side details panel)
        
        if buildProgress.startedReadingFiles, let stats = buildProgress.buildStats {
            
            lblBuildStats.stringValue = "Reading \(stats.filesToRead) tracks and \(stats.playlistsToRead) playlists ..."
            
            buildIndeterminateSpinner.hide()
            buildIndeterminateSpinner.animates = false
            
            buildProgressSpinner.show()
            buildProgressUpdateTask.startOrResume()
            
        } else {
            
            lblBuildStats.stringValue = "Reading source folders: '\(library.sourceFolders.map {$0.path})' ..."
            
            buildIndeterminateSpinner.animates = true
            buildIndeterminateSpinner.show()
            
            buildProgressSpinner.hide()
        }
    }
    
    private func updateBuildProgress() {
        
        if let progressPercentage = libraryDelegate.buildProgress.buildStats?.progressPercentage {
            buildProgressSpinner.percentage = progressPercentage
        }
    }
    
    @IBAction func closeAction(_ sender: Any) {
        
        windowLayoutsManager.toggleWindow(withId: .library)
        buildProgressUpdateTask.pause()
    }
    
    private func showBrowserTab(forItem item: LibrarySidebarItem) {
        
        let tab = item.browserTab

        if tab == .fileSystem,
                  let folderURL = item.tuneBrowserURL {
                
            tuneBrowserViewController.showURL(folderURL)
        }
        
        tabGroup.selectTabViewItem(at: tab.rawValue)
    }
    
    private func showBrowserTab(forCategory category: LibrarySidebarCategory) {

        let tab = category.browserTab
        tabGroup.selectTabViewItem(at: tab.rawValue)
//
//        if tab == .playlists {
//
//        }
    }
    
    // MARK: Message handling -----------------------------------------------------------
    
    private func startedReadingFileSystem() {
        displayBuildProgress()
    }
    
    private func startedAddingTracks() {
        displayBuildProgress()
    }
    
    private func doneAddingTracks() {
        
        buildProgressUpdateTask.stop()
        buildProgressView.hide()
        
        sidebarController.sidebarView.enable()
    }
    
    private func applyTheme() {
        changeWindowCornerRadius(windowAppearanceState.cornerRadius)
    }
    
    private func changeWindowCornerRadius(_ radius: CGFloat) {
        rootContainer.cornerRadius = radius
    }
}
