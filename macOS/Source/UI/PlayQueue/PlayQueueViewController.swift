//
//  PlayQueueViewController.swift
//  Aural
//
//  Copyright © 2023 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import Cocoa

class PlayQueueViewController: TrackListTableViewController, FontSchemeObserver, ColorSchemeObserver {
    
    /// Override this !!!
    var playQueueView: PlayQueueView {
        .simple
    }

    override var isTrackListBeingModified: Bool {playQueueDelegate.isBeingModified}
    
    override var trackList: TrackListProtocol! {playQueueDelegate}
    
    // MARK: Menu items (for menu delegate)
    
    @IBOutlet weak var playNowMenuItem: NSMenuItem!
    @IBOutlet weak var playNextMenuItem: NSMenuItem!
    
    @IBOutlet weak var viewChaptersListMenuItem: NSMenuItem!
    @IBOutlet weak var jumpToChapterMenuItem: NSMenuItem!
    @IBOutlet weak var chaptersMenu: NSMenu!
    
    @IBOutlet weak var favoriteMenu: NSMenu!
    @IBOutlet weak var favoriteMenuItem: NSMenuItem!
    
    @IBOutlet weak var favoriteTrackMenuItem: NSMenuItem!
    @IBOutlet weak var favoriteArtistMenuItem: NSMenuItem!
    @IBOutlet weak var favoriteAlbumMenuItem: NSMenuItem!
    @IBOutlet weak var favoriteGenreMenuItem: NSMenuItem!
    @IBOutlet weak var favoriteDecadeMenuItem: NSMenuItem!
    
    @IBOutlet weak var moveTracksUpMenuItem: NSMenuItem!
    @IBOutlet weak var moveTracksDownMenuItem: NSMenuItem!
    @IBOutlet weak var moveTracksToTopMenuItem: NSMenuItem!
    @IBOutlet weak var moveTracksToBottomMenuItem: NSMenuItem!
    
    @IBOutlet weak var contextMenu: NSMenu!
    @IBOutlet weak var infoMenuItem: NSMenuItem!
    
    @IBOutlet weak var playlistNamesMenu: NSMenu!
    
    // Popup view that displays a brief notification when a selected track is added/removed to/from the Favorites list
    lazy var infoPopup: InfoPopupViewController = .instance
    
    lazy var messenger: Messenger = .init(for: self)
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        tableView.menu = contextMenu
        
        fontSchemesManager.registerObserver(self)
        
        colorSchemesManager.registerSchemeObserver(self)
        colorSchemesManager.registerPropertyObserver(self, forProperty: \.backgroundColor, changeReceiver: tableView)
        colorSchemesManager.registerPropertyObserver(self, forProperty: \.activeControlColor, handler: activeControlColorChanged(_:))
        
        colorSchemesManager.registerPropertyObserver(self, forProperties: [\.primaryTextColor, \.secondaryTextColor, \.tertiaryTextColor,
                                                                            \.primarySelectedTextColor, \.secondarySelectedTextColor, \.tertiarySelectedTextColor],
                                                     handler: textColorChanged(_:))
        
        colorSchemesManager.registerPropertyObserver(self, forProperty: \.textSelectionColor,
                                                     handler: textSelectionColorChanged(_:))
        
        messenger.subscribeAsync(to: .playQueue_tracksAdded, handler: tracksAdded(_:))
        messenger.subscribeAsync(to: .player_trackTransitioned, handler: trackTransitioned(_:))
        messenger.subscribe(to: .playQueue_refresh, handler: tableView.reloadData)
    }
    
    override func viewWillAppear() {
        
        super.viewWillAppear()
        
        contextMenu.delegate = self
        
        for item in contextMenu.items + favoriteMenu.items + playlistNamesMenu.items {
            item.target = self
        }
    }
    
    override func tracksMovedByDragDrop(minReloadIndex: Int, maxReloadIndex: Int) {
        messenger.publish(.playQueue_updateSummary)
    }
    
    override func notifyReloadTable() {
        messenger.publish(.playQueue_refresh)
    }
    
    override func destroy() {
        
        super.destroy()
        messenger.unsubscribeFromAll()
    }
    
    // MARK: Commands --------------------------------------------------------------------------------------------------------
    
    @IBAction func playSelectedTrackAction(_ sender: Any) {
        playSelectedTrack()
    }
    
    func playSelectedTrack() {
        
        if let firstSelectedRow = selectedRows.min() {
            messenger.publish(TrackPlaybackCommandNotification(index: firstSelectedRow))
        }
    }
    
    func showPlayingTrack() {
        
        if let indexOfPlayingTrack = playQueueDelegate.currentTrackIndex {
            selectTrack(at: indexOfPlayingTrack)
        }
    }
    
    // MARK: Notification / command handling ----------------------------------------------------------------------------------------
    
    func fontSchemeChanged() {
        tableView.reloadDataMaintainingSelection()
    }
    
    func colorSchemeChanged() {
        tableView.colorSchemeChanged()
    }
    
    func activeControlColorChanged(_ newColor: PlatformColor) {
        
        if let playingTrackIndex = playQueueDelegate.currentTrackIndex {
            tableView.reloadRows([playingTrackIndex])
        }
    }
    
    func textColorChanged(_ newColor: PlatformColor) {
        tableView.reloadDataMaintainingSelection()
    }
    
    func textSelectionColorChanged(_ newColor: PlatformColor) {
        tableView.redoRowSelection()
    }
    
    private func tracksAdded(_ notif: PlayQueueTracksAddedNotification) {
        tracksAdded(at: notif.trackIndices)
    }
    
    private func trackTransitioned(_ notification: TrackTransitionNotification) {
    
        let refreshIndexes: [Int] = Set([notification.beginTrack, notification.endTrack]
                                            .compactMap {$0})
                                            .compactMap {playQueueDelegate.indexOfTrack($0)}

        // If this is not done async, the row view could get garbled.
        // (because of other potential simultaneous updates - e.g. PlayingTrackInfoUpdated)
        DispatchQueue.main.async {
            self.tableView.reloadRows(refreshIndexes)
        }
    }
    
    // MARK: Data source functions
    
    @objc override func loadFinderTracks(from files: [URL], atPosition row: Int) {
        
        // TODO: Load these 2 values from user preferences
        let clearQueue: Bool = false    // Append or replace ???
        let autoplay: Bool = true       // Autoplay on add
        
        playQueueDelegate.loadTracks(from: files, atPosition: row, clearQueue: clearQueue, autoplay: autoplay)
    }
    
    func tableViewSelectionDidChange(_ notification: Notification) {
        playQueueUIState.selectedRows = self.selectedRows
    }
}
