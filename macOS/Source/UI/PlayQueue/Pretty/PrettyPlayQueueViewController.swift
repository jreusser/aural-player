//
//  PrettyPlayQueueViewController.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import Cocoa

class PrettyPlayQueueViewController: TrackListViewController, ColorSchemeObserver {
    
    override var nibName: String? {"PrettyPlayQueue"}
    
    lazy var messenger: Messenger = Messenger(for: self)
    
    override var rowHeight: CGFloat {50}
    
    override var isTrackListBeingModified: Bool {playQueueDelegate.isBeingModified}
    
    override var trackList: TrackListProtocol! {playQueueDelegate}
    
    // MARK: Menu items (for menu delegate)
    
    @IBOutlet weak var playNowMenuItem: NSMenuItem!
    @IBOutlet weak var playNextMenuItem: NSMenuItem!
    
    @IBOutlet weak var favoritesMenuItem: NSMenuItem!
    @IBOutlet weak var infoMenuItem: NSMenuItem!
    
    @IBOutlet weak var playlistNamesMenu: NSMenu!
    
    @IBOutlet weak var sortOrderMenuItemView: SortOrderMenuItemView!
    
    // Popup view that displays a brief notification when a selected track is added/removed to/from the Favorites list
    lazy var infoPopup: InfoPopupViewController = .instance
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        colorSchemesManager.registerSchemeObserver(self, forProperties: [\.activeControlColor, \.primaryTextColor, \.secondaryTextColor, \.tertiaryTextColor,
                                                                        \.primarySelectedTextColor, \.secondarySelectedTextColor, \.tertiarySelectedTextColor, \.textSelectionColor])
        
        messenger.subscribeAsync(to: .playQueue_tracksAdded, handler: tracksAdded(_:))
        
        messenger.subscribeAsync(to: .player_trackTransitioned, handler: trackTransitioned(_:))
        
        messenger.subscribe(to: .playQueue_playSelectedTrack, handler: playSelectedTrack)
        
        messenger.subscribe(to: .playQueue_addTracks, handler: importFilesAndFolders)
        messenger.subscribe(to: .playQueue_removeTracks, handler: removeTracks)
        messenger.subscribe(to: .playQueue_cropSelection, handler: cropSelection)
        
        messenger.subscribe(to: .playQueue_refresh, handler: tableView.reloadDataMaintainingSelection)
        
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
        
        messenger.subscribe(to: .playQueue_showPlayingTrack, handler: showPlayingTrack)
        
        messenger.subscribe(to: .applyFontScheme, handler: applyFontScheme(_:))
    }
    
    // MARK: Table view delegate / data source --------------------------------------------------------------------------------------------------------
    
    override func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        guard let track = track(forRow: row), let columnId = tableColumn?.identifier else {return nil}
        
        switch columnId {
            
        case .cid_art:
            
//            if track == playQueueDelegate.currentTrack {
//
//
//            } else {
//
//            }
            return createArtCell(tableView: tableView, track: track)
            
        case .cid_trackName:
            
            return createTrackNameCell(tableView: tableView, track: track, row: row)
            
        case .cid_duration:
            
            return createDurationCell(tableView: tableView, track: track, row: row)
            
        default:
            
            return nil
        }
    }
    
    private func createArtCell(tableView: NSTableView, track: Track) -> NSTableCellView? {
        
        guard let cell = tableView.makeView(withIdentifier: .cid_art, owner: nil) as? NSTableCellView else {return nil}
        cell.image = track.art?.image
        
        return cell
    }
    
    private func createTrackNameCell(tableView: NSTableView, track: Track, row: Int) -> PrettyPlayQueueTrackNameCell? {
        
        guard let cell = tableView.makeView(withIdentifier: .cid_trackName, owner: nil) as? PrettyPlayQueueTrackNameCell else {return nil}
        cell.updateForTrack(track)
        
        return cell
    }
    
    private func createDurationCell(tableView: NSTableView, track: Track, row: Int) -> AuralTableCellView? {
        
        return TableCellBuilder().withText(text: ValueFormatter.formatSecondsToHMS(track.duration),
                                           inFont: systemFontScheme.playlist.trackTextFont, andColor: systemColorScheme.tertiaryTextColor,
                                           selectedTextColor: systemColorScheme.tertiarySelectedTextColor)
            .buildCell(forTableView: tableView, forColumnWithId: .cid_duration, inRow: row)
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
    
    // MARK: Actions --------------------------------------------------------------------------------------------------------
    
    @IBAction func playNowAction(_ sender: Any) {
        playSelectedTrack()
    }
    
    @IBAction func importFilesAndFoldersAction(_ sender: NSButton) {
        importFilesAndFolders()
    }
    
    @IBAction func removeTracksAction(_ sender: Any) {
        removeTracks()
    }
    
    override func removeTracks() {
        
        super.removeTracks()
        messenger.publish(.playQueue_updateSummary)
    }
    
    @IBAction func cropSelectionAction(_ sender: Any) {
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
    
    private func updateSummaryIfRequired() {
        
        if let playingTrackIndex = playQueueDelegate.currentTrackIndex, selectedRows.contains(playingTrackIndex) {
            messenger.publish(.playQueue_updateSummary)
        }
    }
    
    @IBAction func moveTracksUpAction(_ sender: Any) {
        
        moveTracksUp()
        updateSummaryIfRequired()
    }
    
    @IBAction func moveTracksDownAction(_ sender: Any) {
        
        moveTracksDown()
        updateSummaryIfRequired()
    }
    
    @IBAction func moveTracksToTopAction(_ sender: Any) {
        
        moveTracksToTop()
        updateSummaryIfRequired()
    }
    
    @IBAction func moveTracksToBottomAction(_ sender: Any) {
        
        moveTracksToBottom()
        updateSummaryIfRequired()
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
    
    @IBAction func sortByTrackNameAction(_ sender: NSMenuItem) {
        doSort(by: [.name])
    }
    
    @IBAction func sortByArtistAlbumDiscTrackNumberAction(_ sender: NSMenuItem) {
        doSort(by: [.artist, .album, .discNumberAndTrackNumber])
    }
    
    @IBAction func sortByArtistAlbumTrackNameAction(_ sender: NSMenuItem) {
        doSort(by: [.artist, .album, .name])
    }
    
    @IBAction func sortByArtistTrackNameAction(_ sender: NSMenuItem) {
        doSort(by: [.artist, .name])
    }
    
    @IBAction func sortByAlbumDiscTrackNumberAction(_ sender: NSMenuItem) {
        doSort(by: [.album, .discNumberAndTrackNumber])
    }
    
    @IBAction func sortByAlbumTrackNameAction(_ sender: NSMenuItem) {
        doSort(by: [.album, .name])
    }
    
    @IBAction func sortByDurationAction(_ sender: NSMenuItem) {
        doSort(by: [.duration])
    }
    
    private func doSort(by fields: [SortField]) {
        
        playQueueDelegate.sort(TrackListSort(fields: fields, order: sortOrderMenuItemView.sortOrder))
        tableView.reloadData()
        updateSummaryIfRequired()
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
    
    private func applyFontScheme(_ scheme: FontScheme) {
        tableView.reloadDataMaintainingSelection()
    }
    
    override func colorChanged(to newColor: PlatformColor, forProperty property: KeyPath<ColorScheme, PlatformColor>) {
        
        super.colorChanged(to: newColor, forProperty: property)
        
        switch property {
            
        case \.activeControlColor:
            
            if let playingTrackIndex = playQueueDelegate.currentTrackIndex {
                tableView.reloadRows([playingTrackIndex])
            }
            
        case \.primaryTextColor, \.secondaryTextColor, \.tertiaryTextColor,
             \.primarySelectedTextColor, \.secondarySelectedTextColor, \.tertiarySelectedTextColor:
            
            tableView.reloadDataMaintainingSelection()
            
        case \.textSelectionColor:
            
//            tableView.reloadRows(selectedRows)
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

class PrettyPlayQueueTrackNameCell: NSTableCellView {
    
    @IBOutlet weak var lblTitle: NSTextField!
    @IBOutlet weak var lblArtistAlbum: NSTextField!
    @IBOutlet weak var lblDefaultDisplayName: NSTextField!
    
    // Used to determine whether or not this cell is selected.
    var rowSelectionStateFunction: () -> Bool = {false}
    
    func updateForTrack(_ track: Track) {
        
        if let title = track.title {
            
            if let artist = track.artist {
                
                if let album = track.album {
                    showTitleAndArtistAlbum(title: title, artistAlbumString: "\(artist) -- \(album)")
                } else {
                    showTitleAndArtistAlbum(title: title, artistAlbumString: artist)
                }
                
            } else {
                
                if let album = track.album {
                    showTitleAndArtistAlbum(title: title, artistAlbumString: album)
                    
                } else {
                    showDefaultDisplayName(title)
                }
            }
            
        } else {
            showDefaultDisplayName(track.defaultDisplayName)
        }
    }
    
    private func showTitleAndArtistAlbum(title: String, artistAlbumString: String) {
        
        lblTitle.stringValue = title
        lblArtistAlbum.stringValue = artistAlbumString
        
        [lblTitle, lblArtistAlbum].forEach {
            $0?.show()
        }
        
        lblDefaultDisplayName.hide()
    }
    
    private func showDefaultDisplayName(_ displayName: String) {
        
        lblDefaultDisplayName.stringValue = displayName
        lblDefaultDisplayName.show()
        
        [lblTitle, lblArtistAlbum].forEach {
            $0?.hide()
        }
    }
    
    var rowIsSelected: Bool {rowSelectionStateFunction()}
    
    override var backgroundStyle: NSView.BackgroundStyle {
        didSet {backgroundStyleChanged()}
    }

    // Check if this row is selected, change font and color accordingly
    func backgroundStyleChanged() {
        
        if rowIsSelected {

            if lblTitle.isShown {
                
                lblTitle.textColor = systemColorScheme.primaryTextColor
                lblArtistAlbum.textColor = systemColorScheme.secondaryTextColor
                
            } else {
                lblDefaultDisplayName.textColor = systemColorScheme.primaryTextColor
            }
            
        } else {
            
            if lblTitle.isShown {
                
                lblTitle.textColor = systemColorScheme.primarySelectedTextColor
                lblArtistAlbum.textColor = systemColorScheme.secondarySelectedTextColor
                
            } else {
                lblDefaultDisplayName.textColor = systemColorScheme.primarySelectedTextColor
            }
        }
    }
}
