//
//  CompactPlayQueueViewController.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import Cocoa

class CompactPlayQueueViewController: TrackListViewController {
    
    override var nibName: String? {"CompactPlayQueue"}
    
    // Delegate that retrieves current playback info
    private let player: PlaybackDelegateProtocol = playbackDelegate
    
    private lazy var messenger: Messenger = Messenger(for: self)
    
    override var rowHeight: CGFloat {30}
    
    override var isTrackListBeingModified: Bool {playQueueDelegate.isBeingModified}
    
    override var trackList: TrackListProtocol! {playQueueDelegate}
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        messenger.subscribeAsync(to: .playQueue_tracksAdded, handler: tracksAdded(_:))
        
        messenger.subscribe(to: .playQueue_playSelectedTrack, handler: playSelectedTrack)
        
        messenger.subscribe(to: .playQueue_addTracks, handler: importFilesAndFolders)
        messenger.subscribe(to: .playQueue_removeTracks, handler: removeTracks)
        messenger.subscribe(to: .playQueue_cropSelection, handler: cropSelection)
        
        messenger.subscribe(to: .playQueue_refresh, handler: tableView.reloadData)
        
        messenger.subscribe(to: .playQueue_clearSelection, handler: tableView.clearSelection)
        messenger.subscribe(to: .playQueue_invertSelection, handler: tableView.invertSelection)
        
        messenger.subscribe(to: .playQueue_moveTracksUp, handler: moveTracksUp)
        messenger.subscribe(to: .playQueue_moveTracksDown, handler: moveTracksDown)
        messenger.subscribe(to: .playQueue_moveTracksToTop, handler: moveTracksToTop)
        messenger.subscribe(to: .playQueue_moveTracksToBottom, handler: moveTracksToBottom)
        
        messenger.subscribe(to: .playQueue_pageUp, handler: tableView.pageUp)
        messenger.subscribe(to: .playQueue_pageDown, handler: tableView.pageDown)
        messenger.subscribe(to: .playQueue_scrollToTop, handler: tableView.scrollToTop)
        messenger.subscribe(to: .playQueue_scrollToBottom, handler: tableView.scrollToBottom)
        
        messenger.subscribe(to: .playQueue_enqueueAndPlayNow, handler: enqueueAndPlayNow(_:))
        messenger.subscribe(to: .playQueue_enqueueAndPlayNext, handler: enqueueAndPlayNext(_:))
        messenger.subscribe(to: .playQueue_enqueueAndPlayLater, handler: enqueueAndPlayLater(_:))
    }
    
    // MARK: Table view delegate / data source --------------------------------------------------------------------------------------------------------
    
    override func view(forColumn column: NSUserInterfaceItemIdentifier, row: Int, track: Track) -> TableCellBuilder {
        
        switch column {
            
        case .cid_index:
            
            if track == player.playingTrack {
                return TableCellBuilder().withImage(image: Images.imgPlayingTrack, inColor: .blue)
                
            } else {
                return TableCellBuilder().withText(text: "\(row + 1)",
                                                   inFont: systemFontScheme.playlist.trackTextFont, andColor: .white50Percent)
            }
            
        case .cid_trackName:
            
            return TableCellBuilder().withText(text: track.displayName,
                                               inFont: systemFontScheme.playlist.trackTextFont, andColor: .white80Percent)
            
        case .cid_duration:
            
            return TableCellBuilder().withText(text: ValueFormatter.formatSecondsToHMS(track.duration),
                                               inFont: systemFontScheme.playlist.trackTextFont, andColor: .white50Percent)
            
        default:
            
            return .noCell
        }
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
    
    // MARK: Actions --------------------------------------------------------------------------------------------------------
    
    @IBAction func tableDoubleClickAction(_ sender: NSTableView) {
        
        guard let trackIndex = selectedRows.first else {return}
        player.play(trackIndex, .defaultParams())
    }
    
    @IBAction func importFilesAndFoldersAction(_ sender: NSButton) {
        importFilesAndFolders()
    }
    
    @IBAction func removeTracksAction(_ sender: NSButton) {
        removeTracks()
    }
    
    override func removeTracks() {
        
        super.removeTracks()
        messenger.publish(.playQueue_updateSummary)
    }
    
    @IBAction func cropSelectionAction(_ sender: NSButton) {
        cropSelection()
    }
    
    override func cropSelection() {
        
        super.cropSelection()
        messenger.publish(.playQueue_updateSummary)
    }
    
    @IBAction func removeAllTracksAction(_ sender: NSButton) {
        removeAllTracks()
    }
    
    override func removeAllTracks() {
        
        super.removeAllTracks()
        messenger.publish(.playQueue_updateSummary)
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
    
    @IBAction func exportToPlaylistFileAction(_ sender: NSButton) {
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
    
    // MARK: Commands --------------------------------------------------------------------------------------------------------
    
    private func playSelectedTrack() {
        
        if let firstSelectedRow = selectedRows.min() {
            messenger.publish(TrackPlaybackCommandNotification(index: firstSelectedRow))
        }
    }
    
    // MARK: Notification / command handling ----------------------------------------------------------------------------------------
    
    private func tracksAdded(_ notif: PlayQueueTracksAddedNotification) {
        tracksAdded(at: notif.trackIndices)
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
