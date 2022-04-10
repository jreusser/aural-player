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
    let playbackInfo: PlaybackInfoDelegateProtocol = objectGraph.playbackInfoDelegate
    let playQueue: PlayQueueDelegateProtocol = objectGraph.playQueueDelegate
    
    private lazy var messenger: Messenger = Messenger(for: self)
    
    override var rowHeight: CGFloat {30}
    
    override var isTrackListBeingModified: Bool {playQueue.isBeingModified}
    
    override var numberOfTracks: Int {playQueue.size}
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        tableView.enableDragDrop()
        
        messenger.subscribeAsync(to: .playQueue_tracksAdded, handler: tracksAdded)
    }
    
    override func track(forRow row: Int) -> Track? {
        playQueue[row]
    }
    
    override func view(forColumn column: NSUserInterfaceItemIdentifier, row: Int, track: Track) -> TableCellBuilder {
        
        switch column {
            
        case .cid_index:
            
            if track == playbackInfo.playingTrack {
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
    
    override func dropTracks(fromIndices sourceIndices: IndexSet, toRow destRow: Int) -> [TrackMoveResult] {
        playQueue.dropTracks(sourceIndices, destRow)
    }
    
    override func insertFiles(_ files: [URL], atRow destRow: Int) {
        playQueue.addTracks(from: files, atPosition: destRow)
    }
    
    private func tracksAdded() {
        tableView.noteNumberOfRowsChanged()
    }
}
