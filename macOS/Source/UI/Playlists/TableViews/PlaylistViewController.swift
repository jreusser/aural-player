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
        
        messenger.subscribe(to: .playlist_addChosenFiles, handler: addChosenTracks(_:))
        
        messenger.subscribe(to: .playlist_copyTracks, handler: copyTracks(_:))
    }
    
    override func view(forColumn column: NSUserInterfaceItemIdentifier, row: Int, track: Track) -> TableCellBuilder {
        
        let builder = TableCellBuilder()
        
        switch column {
            
        case .cid_index:
            
            if track == playQueueDelegate.currentTrack {
                return builder.withImage(image: Images.imgPlayFilled, inColor: systemColorScheme.activeControlColor)
                
            } else {
                return builder.withText(text: "\(row + 1)",
                                                   inFont: systemFontScheme.playlist.trackTextFont, andColor: systemColorScheme.tertiaryTextColor,
                                                   selectedTextColor: systemColorScheme.tertiarySelectedTextColor)
            }
            
        case .cid_trackName:
            
            let titleAndArtist = track.titleAndArtist
            
            if let artist = titleAndArtist.artist {
                
                return builder.withAttributedText(strings: [(text: artist + "  ", font: systemFontScheme.playlist.trackTextFont, color: systemColorScheme.secondaryTextColor),
                                                                       (text: titleAndArtist.title, font: systemFontScheme.playlist.trackTextFont, color: systemColorScheme.primaryTextColor)],
                                                             selectedTextColors: [systemColorScheme.secondarySelectedTextColor, systemColorScheme.primarySelectedTextColor])
            } else {
                
                return builder.withAttributedText(strings: [(text: titleAndArtist.title,
                                                                        font: systemFontScheme.playlist.trackTextFont,
                                                                        color: systemColorScheme.primaryTextColor)], selectedTextColors: [systemColorScheme.primarySelectedTextColor])
            }
            
        case .cid_duration:
            
            return builder.withText(text: ValueFormatter.formatSecondsToHMS(track.duration),
                                               inFont: systemFontScheme.playlist.trackTextFont, andColor: systemColorScheme.tertiaryTextColor,
                                               selectedTextColor: systemColorScheme.tertiarySelectedTextColor)
            
        default:
            
            return builder
        }
    }
    
    // Drag / drop
    override func importTracks(from otherTable: NSTableView, sourceIndices: IndexSet, to destRow: Int) {
        
        // Cannot import tracks into a playlist already being modified.
        guard let otherTableId = otherTable.identifier else {return}
        
        switch otherTableId {

        case .tableId_playlistNames:
            
            // Import entire playlists into this playlist.
            
            // Don't import this playlist into itself (will have no effect).
            let draggedPlaylists: [Playlist] = sourceIndices.map {playlistsManager.userDefinedObjects[$0]}.filter {$0 != playlist}
            guard draggedPlaylists.isNonEmpty else {return}
            
            importEntirePlaylists(draggedPlaylists, to: destRow)
            
        case .tableId_compactPlayQueue:

            // Import selected tracks from the Play Queue into this playlist.
            importTracksFromPlayQueue(sourceIndices: sourceIndices, to: destRow)
            
        default:
            
            return
        }
    }
    
    private func importEntirePlaylists(_ sourcePlaylists: [Playlist], to destRow: Int) {
        importTracks(sourcePlaylists.flatMap {$0.tracks}, to: destRow)
    }
    
    private func importTracksFromPlayQueue(sourceIndices: IndexSet, to destRow: Int) {
        importTracks(sourceIndices.compactMap {playQueueDelegate[$0]}, to: destRow)
    }
    
    private func importTracks(_ tracks: [Track], to destRow: Int) {
        
        let newTrackIndices = playlist.insertTracks(tracks, at: destRow)
        guard let minTrackIndex = newTrackIndices.min() else {return}
        
        tableView.noteNumberOfRowsChanged()
        tableView.reloadRows(minTrackIndex...lastRow)
        
        messenger.publish(.playlists_updateSummary)
    }
    
    // ---------------------------------------------------------------------------------------------------------
    
    // MARK: Actions (control buttons)
    
    @IBAction func importFilesAndFoldersAction(_ sender: NSButton) {
        importFilesAndFolders()
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
            
            messenger.publish(EnqueueAndPlayNowCommand(tracks: [selTrack], clearPlayQueue: false))
        }
    }
    
    // ---------------------------------------------------------------------------------------------------------
    
    // MARK: Actions (context menu)
    
    @IBAction func playNowAction(_ sender: NSMenuItem) {
        messenger.publish(EnqueueAndPlayNowCommand(tracks: playlist[selectedRows], clearPlayQueue: false))
    }
    
    @IBAction func playNowClearingPlayQueueAction(_ sender: NSMenuItem) {
        messenger.publish(EnqueueAndPlayNowCommand(tracks: playlist[selectedRows], clearPlayQueue: true))
    }
    
    @IBAction func playNextAction(_ sender: NSMenuItem) {
        messenger.publish(.playQueue_enqueueAndPlayNext, payload: playlist[selectedRows])
    }
    
    @IBAction func playLaterAction(_ sender: NSMenuItem) {
        messenger.publish(.playQueue_enqueueAndPlayLater, payload: playlist[selectedRows])
    }
    
    // ---------------------------------------------------------------------------------------------------------
    
    // MARK: Notification handling
    
    private func tracksAdded(_ notif: PlaylistTracksAddedNotification) {
        
        tracksAdded(at: notif.trackIndices)
        messenger.publish(.playlists_updateSummary)
    }
    
    private func copyTracks(_ notif: CopyTracksToPlaylistCommand) {
        
        guard let destinationPlaylist = playlistsManager.userDefinedObject(named: notif.destinationPlaylistName) else {return}
        
        destinationPlaylist.addTracks(notif.tracks)
        
        // If tracks were added to the displayed playlist, update the table view.
        if destinationPlaylist == playlist {
            tableView.noteNumberOfRowsChanged()
        }
    }
}
