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

    override var isTrackListBeingModified: Bool {playQueueDelegate.isBeingModified}
    
    override var trackList: TrackListProtocol! {playQueueDelegate}
    
    // MARK: Menu items (for menu delegate)
    
    @IBOutlet weak var playNowMenuItem: NSMenuItem!
    @IBOutlet weak var playNextMenuItem: NSMenuItem!
    
    @IBOutlet weak var favoriteTrackMenuItem: NSMenuItem!
    @IBOutlet weak var favoriteArtistMenuItem: NSMenuItem!
    @IBOutlet weak var favoriteAlbumMenuItem: NSMenuItem!
    
    @IBOutlet weak var infoMenuItem: NSMenuItem!
    
    @IBOutlet weak var playlistNamesMenu: NSMenu!
    
    // Popup view that displays a brief notification when a selected track is added/removed to/from the Favorites list
    lazy var infoPopup: InfoPopupViewController = .instance
    
    lazy var messenger: Messenger = .init(for: self)
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        fontSchemesManager.registerSchemeObserver(self, forProperties: [\.playQueuePrimaryFont, \.playQueueSecondaryFont, \.playQueueTertiaryFont])
        
        colorSchemesManager.registerSchemeObserver(self, forProperties: [\.activeControlColor, \.primaryTextColor, \.secondaryTextColor, \.tertiaryTextColor,
                                                                        \.primarySelectedTextColor, \.secondarySelectedTextColor, \.tertiarySelectedTextColor, \.textSelectionColor])
        
        messenger.subscribeAsync(to: .playQueue_tracksAdded, handler: tracksAdded(_:))
        
        messenger.subscribeAsync(to: .player_trackTransitioned, handler: trackTransitioned(_:))
        
        messenger.subscribe(to: .playQueue_playSelectedTrack, handler: playSelectedTrack)
        
        messenger.subscribe(to: .playQueue_refresh, handler: tableView.reloadData)
        
        messenger.subscribe(to: .playQueue_selectAllItems, handler: tableView.selectAllItems)
        messenger.subscribe(to: .playQueue_clearSelection, handler: tableView.clearSelection)
        messenger.subscribe(to: .playQueue_invertSelection, handler: tableView.invertSelection)
        
//        messenger.subscribe(to: .playQueue_moveTracksUp, handler: moveTracksUp)
//        messenger.subscribe(to: .playQueue_moveTracksDown, handler: moveTracksDown)
//        messenger.subscribe(to: .playQueue_moveTracksToTop, handler: moveTracksToTop)
//        messenger.subscribe(to: .playQueue_moveTracksToBottom, handler: moveTracksToBottom)
        
        messenger.subscribe(to: .playQueue_pageUp, handler: tableView.pageUp)
        messenger.subscribe(to: .playQueue_pageDown, handler: tableView.pageDown)
        messenger.subscribe(to: .playQueue_scrollToTop, handler: tableView.scrollToTop)
        messenger.subscribe(to: .playQueue_scrollToBottom, handler: tableView.scrollToBottom)
        
        messenger.subscribe(to: .playQueue_showPlayingTrack, handler: showPlayingTrack)
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
    
    private func showPlayingTrack() {
        
        if let indexOfPlayingTrack = playQueueDelegate.currentTrackIndex {
            selectTrack(at: indexOfPlayingTrack)
        }
    }
    
    // MARK: Notification / command handling ----------------------------------------------------------------------------------------
    
    func fontSchemeChanged() {
        tableView.reloadDataMaintainingSelection()
    }
    
    func fontChanged(to newFont: PlatformFont, forProperty property: KeyPath<FontScheme, PlatformFont>) {
        tableView.reloadDataMaintainingSelection()
    }
    
    func colorChanged(to newColor: PlatformColor, forProperty property: KeyPath<ColorScheme, PlatformColor>) {
        
        switch property {
            
        case \.activeControlColor:
            
            if let playingTrackIndex = playQueueDelegate.currentTrackIndex {
                tableView.reloadRows([playingTrackIndex])
            }
            
        case \.primaryTextColor, \.secondaryTextColor, \.tertiaryTextColor,
             \.primarySelectedTextColor, \.secondarySelectedTextColor, \.tertiarySelectedTextColor:
            
            tableView.reloadDataMaintainingSelection()
            
        case \.textSelectionColor:
            
            tableView.redoRowSelection()
            
        default:
            
            return
        }
    }
    
    func colorSchemeChanged() {
        tableView.reloadDataMaintainingSelection()
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
}
