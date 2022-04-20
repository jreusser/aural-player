//
//  PlaylistViewController.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import Cocoa

class PlaylistViewController: TrackListViewController {
    
    override var nibName: String? {"Playlist"}
    
    override var rowHeight: CGFloat {30}
    
    unowned var playlist: Playlist! = nil {
        
        didSet {
            
            if playlist != nil {
                tableView.reloadData()
            }
        }
    }
    
    override var trackList: TrackListProtocol! {
        playlist
    }
    
    private lazy var messenger: Messenger = Messenger(for: self)
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        messenger.subscribeAsync(to: .playlist_tracksAdded, handler: tracksAdded(_:),
                                 filter: {notif in playlistsUIState.displayedPlaylist?.name == notif.playlistName})
        
        messenger.subscribe(to: .playlist_addChosenTracks, handler: addChosenTracks(_:))
    }
    
    override func view(forColumn column: NSUserInterfaceItemIdentifier, row: Int, track: Track) -> TableCellBuilder {
        
        let builder = TableCellBuilder()
        
        switch column {
            
        case .cid_index:
            
            return builder.withText(text: "\(row + 1)", inFont: systemFontScheme.playlist.trackTextFont, andColor: systemColorScheme.secondaryTextColor)
            
        case .cid_trackName:
            
            return builder.withText(text: track.displayName, inFont: systemFontScheme.playlist.trackTextFont, andColor: systemColorScheme.primaryTextColor)
            
        case .cid_duration:
            
            return builder.withText(text: ValueFormatter.formatSecondsToHMS(track.duration),
                                    inFont: systemFontScheme.playlist.trackTextFont, andColor: systemColorScheme.secondaryTextColor)
            
        default:
            
            return builder
        }
    }
    
    // ---------------------------------------------------------------------------------------------------------
    
    // MARK: Actions (control buttons)
    
    @IBAction func addFilesAction(_ sender: NSButton) {
        addTracks()
    }
    
    @IBAction func removeTracksAction(_ sender: NSButton) {
        removeTracks()
    }
    
    override func removeTracks() {
        
        super.removeTracks()
        messenger.publish(.playlists_updateSummary)
    }
    
    @IBAction func cropTracksAction(_ sender: NSButton) {
        cropSelection()
    }
    
    override func cropSelection() {
        
        super.cropSelection()
        messenger.publish(.playlists_updateSummary)
    }
    
    @IBAction func removeAllTracksAction(_ sender: NSButton) {
        removeAllTracks()
    }
    
    override func removeAllTracks() {
        
        super.removeAllTracks()
        messenger.publish(.playlists_updateSummary)
    }
    
    @IBAction func moveTracksUpAction(_ sender: NSButton) {
        moveTracksUp()
    }
    
    @IBAction func moveTracksDownAction(_ sender: NSButton) {
        moveTracksDown()
    }
    
    @IBAction func moveTracksToTopAction(_ sender: NSButton) {
        moveTracksToTop()
    }
    
    @IBAction func moveTracksToBottomAction(_ sender: NSButton) {
        moveTracksToBottom()
    }
    
    @IBAction func clearSelectionAction(_ sender: NSButton) {
        clearSelection()
    }
    
    @IBAction func invertSelectionAction(_ sender: NSButton) {
        invertSelection()
    }
    
    @IBAction func exportToPlaylistAction(_ sender: NSButton) {
        exportTrackList()
    }
    
    @IBAction func pageUpAction(_ sender: NSButton) {
        pageUp()
    }
    
    @IBAction func pageDownAction(_ sender: NSButton) {
        pageDown()
    }
    
    @IBAction func scrollToTopAction(_ sender: NSButton) {
        scrollToTop()
    }
    
    @IBAction func scrollToBottomAction(_ sender: NSButton) {
        scrollToBottom()
    }
    
    @IBAction func doubleClickAction(_ sender: NSTableView) {
        
        if let selRow: Int = selectedRows.first,
            let selTrack = playlist[selRow] {
            
            messenger.publish(EnqueueAndPlayCommand(tracks: [selTrack], clearPlayQueue: false))
        }
    }
    
    // ---------------------------------------------------------------------------------------------------------
    
    // MARK: Actions (context menu)
    
    @IBAction func playNowAction(_ sender: NSMenuItem) {
        messenger.publish(EnqueueAndPlayCommand(tracks: playlist[selectedRows], clearPlayQueue: false))
    }
    
    @IBAction func playNowClearingPlayQueueAction(_ sender: NSMenuItem) {
        messenger.publish(EnqueueAndPlayCommand(tracks: playlist[selectedRows], clearPlayQueue: true))
    }
    
    @IBAction func playNextAction(_ sender: NSMenuItem) {
        
    }
    
    @IBAction func playLaterAction(_ sender: NSMenuItem) {
        
    }
    
    // ---------------------------------------------------------------------------------------------------------
    
    // MARK: Notification handling
    
    private func tracksAdded(_ notif: PlaylistTracksAddedNotification) {
        
        tracksAdded(at: notif.trackIndices)
        messenger.publish(.playlists_updateSummary)
    }
}
