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
        
        messenger.subscribe(to: .playQueue_addTracks, handler: addTracks)
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
    
    // MARK: Commands --------------------------------------------------------------------------------------------------------
    
    private func playSelectedTrack() {
        
        if let firstSelectedRow = selectedRows.min() {
            messenger.publish(TrackPlaybackCommandNotification(index: firstSelectedRow))
        }
    }
    
    @IBAction func tableDoubleClickAction(_ sender: NSTableView) {
        
        guard let trackIndex = selectedRows.first else {return}
        player.play(trackIndex, .defaultParams())
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
