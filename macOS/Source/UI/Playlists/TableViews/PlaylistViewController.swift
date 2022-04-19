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
        messenger.subscribeAsync(to: .playlist_tracksAdded, handler: tracksAdded(_:))
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
    
    // MARK: Actions
    
    @IBAction func addFilesAction(_ sender: NSButton) {
        addTracks()
    }
    
    @IBAction func removeTracksAction(_ sender: NSButton) {
        removeTracks()
    }
    
    @IBAction func cropTracksAction(_ sender: NSButton) {
        cropSelection()
    }
    
    @IBAction func removeAllTracksAction(_ sender: NSButton) {
        removeAllTracks()
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
    
    // MARK: Notification handling
    
    private func tracksAdded(_ notif: PlaylistTracksAddedNotification) {
        tracksAdded(at: notif.trackIndices)
    }
}
