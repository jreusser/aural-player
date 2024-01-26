//
//  LibraryTracksViewController.swift
//  Aural
//
//  Copyright © 2023 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import Cocoa

class LibraryTracksViewController: TrackListTableViewController, ColorSchemePropertyObserver {
    
    override var nibName: String? {"LibraryTracks"}
    
    @IBOutlet weak var rootContainer: NSBox!
    @IBOutlet weak var lblCaption: NSTextField!
    
    @IBOutlet weak var lblTracksSummary: NSTextField!
    @IBOutlet weak var lblDurationSummary: NSTextField!
    
    // Spinner that shows progress when tracks are being added to the play queue.
    @IBOutlet weak var progressSpinner: NSProgressIndicator!
    
    override var rowHeight: CGFloat {30}
    
    override var trackList: TrackListProtocol! {
        libraryDelegate
    }
    
    private lazy var messenger: Messenger = .init(for: self)
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        updateSummary()
        
//        colorSchemesManager.registerObserver(rootContainer, forProperty: \.backgroundColor)
//        
//        fontSchemesManager.registerObserver(lblCaption, forProperty: \.captionFont)
//        colorSchemesManager.registerObserver(lblCaption, forProperty: \.captionTextColor)
//        
//        fontSchemesManager.registerObservers([lblTracksSummary, lblDurationSummary], forProperty: \.playQueueSecondaryFont)
//        colorSchemesManager.registerObservers([lblTracksSummary, lblDurationSummary], forProperty: \.secondaryTextColor)
//        
//        colorSchemesManager.registerObserver(self, forProperties: [\.primaryTextColor, \.secondaryTextColor, \.tertiaryTextColor,
//                                                                    \.primarySelectedTextColor, \.secondarySelectedTextColor, \.tertiarySelectedTextColor, \.textSelectionColor])
        
        messenger.subscribeAsync(to: .library_tracksAdded, handler: tracksAdded(_:))
        messenger.subscribeAsync(to: .library_tracksRemoved, handler: tracksRemoved(_:))
        messenger.subscribe(to: .library_updateSummary, handler: updateSummary)
        messenger.subscribe(to: .library_reloadTable, handler: reloadTable)
        
        messenger.subscribeAsync(to: .library_doneAddingTracks, handler: doneAddingTracks)
        
//        messenger.subscribe(to: .library_addChosenFiles, handler: addChosenTracks(_:))
//
//        messenger.subscribe(to: .library_copyTracks, handler: copyTracks(_:))
    }
    
    override func view(forColumn column: NSUserInterfaceItemIdentifier, row: Int, track: Track) -> TableCellBuilder {
        
        let builder = TableCellBuilder()
        
        switch column {
            
        case .cid_index:
            
            return builder.withText(text: "\(row + 1)",
                                                   inFont: systemFontScheme.playlist.trackTextFont, andColor: systemColorScheme.tertiaryTextColor,
                                                   selectedTextColor: systemColorScheme.tertiarySelectedTextColor)

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
    
    override func notifyReloadTable() {
        messenger.publish(.library_reloadTable)
    }
    
    override func destroy() {
        
        super.destroy()
        messenger.unsubscribeFromAll()
    }
    
    // ---------------------------------------------------------------------------------------------------------
    
    // MARK: Actions (context menu)
    
    @IBAction func playNowAction(_ sender: AnyObject) {
        messenger.publish(EnqueueAndPlayNowCommand(tracks: selectedTracks, clearPlayQueue: false))
    }
    
    @IBAction func playNowClearingPlayQueueAction(_ sender: NSMenuItem) {
//        messenger.publish(EnqueueAndPlayNowCommand(tracks: playlist[selectedRows], clearPlayQueue: true))
    }
    
    @IBAction func playNextAction(_ sender: NSMenuItem) {
//        messenger.publish(.playQueue_enqueueAndPlayNext, payload: playlist[selectedRows])
    }
    
    @IBAction func playLaterAction(_ sender: NSMenuItem) {
//        messenger.publish(.playQueue_enqueueAndPlayLater, payload: playlist[selectedRows])
    }
    
    // ---------------------------------------------------------------------------------------------------------
    
    // MARK: Notification handling
    
    func colorChanged(to newColor: PlatformColor, forProperty property: ColorSchemeProperty) {
        
        switch property {
            
        case \.primaryTextColor, \.secondaryTextColor, \.tertiaryTextColor,
             \.primarySelectedTextColor, \.secondarySelectedTextColor, \.tertiarySelectedTextColor:
            
            let selection = selectedRows
            tableView.reloadData()
            tableView.selectRows(selection)
            
        case \.textSelectionColor:
            
            tableView.reloadRows(selectedRows)
            tableView.redoRowSelection()
            
        default:
            
            return
        }
    }
    
    private func tracksAdded(_ notif: LibraryTracksAddedNotification) {
        
//        tracksAdded(at: notif.trackIndices)
//        updateSummary()
    }
    
    private func tracksRemoved(_ notif: LibraryTracksRemovedNotification) {
        
        tracksRemoved(at: notif.trackIndices)
        updateSummary()
    }
    
    func doneAddingTracks() {
        
        tableView.reloadData()
        updateSummary()
    }
    
    override func updateSummary() {
        
        let numTracks = library.size
        lblTracksSummary.stringValue = "\(numTracks) \(numTracks == 1 ? "track" : "tracks")"
        lblDurationSummary.stringValue = ValueFormatter.formatSecondsToHMS(library.duration)
    }
    
    private func copyTracks(_ notif: CopyTracksToPlaylistCommand) {
        
        guard let destinationPlaylist = playlistsManager.userDefinedObject(named: notif.destinationPlaylistName) else {return}
        
        destinationPlaylist.addTracks(notif.tracks)
        
        // If tracks were added to the displayed playlist, update the table view.
//        if destinationPlaylist == playlist {
//            tableView.noteNumberOfRowsChanged()
//        }
    }
}

