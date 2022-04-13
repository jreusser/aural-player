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

class CompactPlayQueueViewController: TableViewController {
    
    override var nibName: String? {"CompactPlayQueue"}
    
    // Delegate that retrieves current playback info
    private let player: PlaybackDelegateProtocol = objectGraph.playbackDelegate
    private let playQueue: PlayQueueDelegateProtocol = objectGraph.playQueueDelegate
    
    private lazy var messenger: Messenger = Messenger(for: self)
    
    override var rowHeight: CGFloat {30}
    
    override var isTrackListBeingModified: Bool {playQueue.isBeingModified}
    
    override var numberOfTracks: Int {playQueue.size}
    
    override var trackList: TrackListProtocol {playQueue}
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        tableView.enableDragDrop()
        
        messenger.subscribeAsync(to: .playQueue_trackAdded, handler: trackAdded(_:))
        messenger.subscribeAsync(to: .playQueue_tracksAdded, handler: tracksAdded(_:))
        messenger.subscribeAsync(to: .playQueue_tracksRemoved, handler: tracksRemoved(_:))
        
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
    }
    
    // MARK: Table view delegate / data source --------------------------------------------------------------------------------------------------------
    
    override func view(forColumn column: NSUserInterfaceItemIdentifier, row: Int, track: Track) -> TableCellBuilder {
        
        switch column {
            
        case .cid_index:
            
            if track == player.playingTrack {
                return TableCellBuilder().withImage(image: Images.imgPlayingTrack, inColor: .blue)
                
            } else {
                return TableCellBuilder().withText(text: "\(row + 1)",
                                                   inFont: fontSchemesManager.systemScheme.playlist.trackTextFont, andColor: .white50Percent)
            }
            
        case .cid_trackName:
            
            return TableCellBuilder().withText(text: track.displayName,
                                               inFont: fontSchemesManager.systemScheme.playlist.trackTextFont, andColor: .white80Percent)
            
        case .cid_duration:
            
            return TableCellBuilder().withText(text: ValueFormatter.formatSecondsToHMS(track.duration),
                                               inFont: fontSchemesManager.systemScheme.playlist.trackTextFont, andColor: .white50Percent)
            
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
    
    override func insertFiles(_ files: [URL], atRow destRow: Int? = nil) {
        playQueue.addTracks(from: files, atPosition: destRow)
    }
    
    @IBAction func tableDoubleClickAction(_ sender: NSTableView) {
        
        guard let trackIndex = selectedRows.first else {return}
        player.play(trackIndex, .defaultParams())
    }
    
    private func tracksAdded(_ notif: PlayQueueTracksAddedNotification) {
        tracksAdded(at: notif.trackIndices)
    }
}
