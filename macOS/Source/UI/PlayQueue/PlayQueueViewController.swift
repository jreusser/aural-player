//
//  PlayQueueViewController.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import Cocoa

class PlayQueueViewController: TrackListTableViewController, FontSchemeObserver, ColorSchemeObserver {

    lazy var messenger: Messenger = Messenger(for: self)
    
    override var isTrackListBeingModified: Bool {playQueueDelegate.isBeingModified}
    
    override var trackList: TrackListProtocol! {playQueueDelegate}
    
    // MARK: Menu items (for menu delegate)
    
    @IBOutlet weak var playNowMenuItem: NSMenuItem!
    @IBOutlet weak var playNextMenuItem: NSMenuItem!
    
    @IBOutlet weak var favoritesMenuItem: NSMenuItem!
    @IBOutlet weak var infoMenuItem: NSMenuItem!
    
    @IBOutlet weak var playlistNamesMenu: NSMenu!
    
    // Popup view that displays a brief notification when a selected track is added/removed to/from the Favorites list
    lazy var infoPopup: InfoPopupViewController = .instance
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        fontSchemesManager.registerSchemeObserver(self, forProperties: [\.playQueuePrimaryFont, \.playQueueSecondaryFont, \.playQueueTertiaryFont])
        
        colorSchemesManager.registerSchemeObserver(self, forProperties: [\.activeControlColor, \.primaryTextColor, \.secondaryTextColor, \.tertiaryTextColor,
                                                                        \.primarySelectedTextColor, \.secondarySelectedTextColor, \.tertiarySelectedTextColor, \.textSelectionColor])
        
        messenger.subscribeAsync(to: .playQueue_tracksAdded, handler: tracksAdded(_:))
        
        messenger.subscribeAsync(to: .player_trackTransitioned, handler: trackTransitioned(_:))
        
        messenger.subscribe(to: .playQueue_playSelectedTrack, handler: playSelectedTrack)
        
        messenger.subscribe(to: .playQueue_refresh, handler: tableView.reloadDataMaintainingSelection)
        
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
        
        messenger.subscribe(to: .playQueue_enqueueAndPlayNow, handler: enqueueAndPlayNow(_:))
        messenger.subscribe(to: .playQueue_enqueueAndPlayNext, handler: enqueueAndPlayNext(_:))
        messenger.subscribe(to: .playQueue_enqueueAndPlayLater, handler: enqueueAndPlayLater(_:))
        
        messenger.subscribe(to: .playQueue_showPlayingTrack, handler: showPlayingTrack)
    }
    
    override func tracksMovedByDragDrop(minReloadIndex: Int, maxReloadIndex: Int) {
        messenger.publish(.playQueue_updateSummary)
    }
    
    // Drag / drop
    override func importTracks(from otherTable: NSTableView, sourceIndices: IndexSet, to destRow: Int) {
        
        guard let otherTableId = otherTable.identifier else {return}
        
        switch otherTableId {
            
        case .tableId_playlist:
            
            importTracksFromPlaylist(sourceIndices: sourceIndices, to: destRow)
            
        case .tableId_playlistNames:
            
            importEntirePlaylist(sourceIndices: sourceIndices, to: destRow)
            
        default:
            
            return
        }
    }
    
    // Import selected tracks from a single playlist.
    private func importTracksFromPlaylist(sourceIndices: IndexSet, to destRow: Int) {
        
        guard let displayedPlaylist = playlistsUIState.displayedPlaylist else {return}
        
        let tracks: [Track] = sourceIndices.compactMap {displayedPlaylist[$0]}
        _ = trackList.insertTracks(tracks, at: destRow)
    }
    
    // Import entire (selected) playlists.
    private func importEntirePlaylist(sourceIndices: IndexSet, to destRow: Int) {
        
        let draggedPlaylists = sourceIndices.map {playlistsManager.userDefinedObjects[$0]}
        let tracks: [Track] = draggedPlaylists.flatMap {$0.tracks}
        
        _ = trackList.insertTracks(tracks, at: destRow)
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
    
    // TODO: what to do with tracks already in the PQ ???
    private func enqueueAndPlayNow(_ command: EnqueueAndPlayNowCommand) {
        
        if command.clearPlayQueue {
            playQueueDelegate.removeAllTracks()
        }
        
        let indices = playQueueDelegate.addTracks(command.tracks)
        
        if indices != -1...(-1) {
            tableView.noteNumberOfRowsChanged()
        }
        
        if let firstTrack = command.tracks.first {
            messenger.publish(TrackPlaybackCommandNotification(track: firstTrack))
        }
    }
    
    // TODO:
    private func enqueueAndPlayNext(_ tracks: [Track]) {
        
//        let indices = playQueueDelegate.enqueueTracksToPlayNext(tracks)
        
    }
    
    // TODO:
    private func enqueueAndPlayLater(_ tracks: [Track]) {
        
//        let indices = playQueueDelegate.enqueueTracks(tracks, clearQueue: false)
    }
}
