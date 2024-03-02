//
//  PlayQueueViewController.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import Cocoa

class PlayQueueViewController: TrackListTableViewController {
    
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
        
        colorSchemesManager.registerPropertyObserver(self, forProperty: \.activeControlColor, handler: activeControlColorChanged(_:))
        
        messenger.subscribeAsync(to: .PlayQueue.tracksAdded, handler: tracksAdded(_:))
        messenger.subscribeAsync(to: .Player.trackTransitioned, handler: trackTransitioned(_:))
        messenger.subscribe(to: .PlayQueue.refresh, handler: tableView.reloadData)
    }
    
    override func viewWillAppear() {
        
        super.viewWillAppear()
        
        if contextMenu != nil {
            
            contextMenu.delegate = self
            
            for item in contextMenu.items + favoriteMenu.items + playlistNamesMenu.items {
                item.target = self
            }
        }
    }
    
    override func tracksMovedByDragDrop(minReloadIndex: Int, maxReloadIndex: Int) {
        messenger.publish(.PlayQueue.updateSummary)
    }
    
    override func notifyReloadTable() {
        messenger.publish(.PlayQueue.refresh)
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
    
    func activeControlColorChanged(_ newColor: PlatformColor) {
        
        if let playingTrackIndex = playQueueDelegate.currentTrackIndex {
            tableView.reloadRows([playingTrackIndex])
        }
    }
    
    private func tracksAdded(_ notif: PlayQueueTracksAddedNotification) {
        tracksAdded(at: notif.trackIndices)
    }
    
    func trackTransitioned(_ notification: TrackTransitionNotification) {
    
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
        let autoplay: Bool = preferences.playbackPreferences.autoplayAfterAddingTracks.value       // Autoplay on add
        
        playQueueDelegate.loadTracks(from: files, atPosition: row, params: .init(clearQueue: clearQueue, autoplay: autoplay))
    }
    
    func tableViewSelectionDidChange(_ notification: Notification) {
        playQueueUIState.selectedRows = self.selectedRows
    }
    
    // MARK: Method overrides --------------------------------------------------------------------------------
    
    // Invokes the Open file dialog, to allow the user to add tracks/playlists to the app playlist
    override func importFilesAndFolders() {
        
        if fileOpenDialog.runModal() == .OK {
            playQueueDelegate.loadTracks(from: fileOpenDialog.urls, params: .init(autoplay: preferences.playbackPreferences.autoplayAfterAddingTracks.value))
        }
    }
    
    /**
        The Play Queue needs to update the summary in the case when tracks were reordered, because, if a track
        is playing, it may have moved.
     */
    
    @discardableResult override func moveTracksUp() -> Bool {

        if super.moveTracksUp() {
            
            updateSummary()
            return true
        }
        
        return false
    }

    @discardableResult override func moveTracksDown() -> Bool {

        if super.moveTracksDown() {
            
            updateSummary()
            return true
        }
        
        return false
    }

    @discardableResult override func moveTracksToTop() -> Bool {

        if super.moveTracksToTop() {
            
            updateSummary()
            return true
        }
        
        return false
    }

    @discardableResult override func moveTracksToBottom() -> Bool {

        if super.moveTracksToBottom() {
            
            updateSummary()
            return true
        }
        
        return false
    }
}
