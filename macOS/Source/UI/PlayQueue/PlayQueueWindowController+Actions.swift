//
//  PlayQueueWindowController+Actions.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import Cocoa

extension PlayQueueWindowController {
    
    // Switches the tab group to a particular tab
    @IBAction func tabViewAction(_ sender: PlayQueueTabButton) {
        doSelectTab(at: sender.tag)
    }
    
    func doSelectTab(at tabIndex: Int) {
        
        tabButtons.forEach {$0.unSelect()}
        tabButtons.first(where: {$0.tag == tabIndex})?.select()
        
        // Button tag is the tab index
        tabGroup.selectTabViewItem(at: tabIndex)
        playQueueUIState.currentView = PlayQueueView(rawValue: tabIndex)!
    }
    
    @IBAction func closeAction(_ sender: NSButton) {
        windowLayoutsManager.toggleWindow(withId: .playQueue)
    }
    
    @IBAction func importFilesAndFoldersAction(_ sender: NSButton) {
        importFilesAndFolders()
    }
    
    // Invokes the Open file dialog, to allow the user to add tracks/playlists to the app playlist
    func importFilesAndFolders() {
        
        if !playQueueDelegate.isBeingModified, fileOpenDialog.runModal() == .OK {
            playQueueDelegate.loadTracks(from: fileOpenDialog.urls)
        }
    }
    
    @IBAction func removeTracksAction(_ sender: Any) {
        removeTracks()
    }
    
    func removeTracks() {
        
        let selectedRows = currentViewController.selectedRows
        
        // Check for at least 1 row (and also get the minimum index).
        guard let firstRemovedRow = selectedRows.min() else {return}
        
        _ = playQueueDelegate.removeTracks(at: selectedRows)
        currentViewController.clearSelection()
        
        // Update all rows from the first (i.e. smallest index) removed row, down to the end of the track list.
        let lastRowAfterRemove = playQueueDelegate.size - 1
        
        controllers.forEach {
            
            // Tell the playlist view that the number of rows has changed (should result in removal of rows)
            $0.noteNumberOfRowsChanged()
            
            // This will be true unless a contiguous block of tracks was removed from the bottom of the track list.
            if firstRemovedRow <= lastRowAfterRemove {
                $0.reloadTableRows(firstRemovedRow...lastRowAfterRemove)
            }
        }
        
        updateSummary()
    }
    
    @IBAction func cropSelectionAction(_ sender: Any) {
        cropSelection()
    }
    
    func cropSelection() {
        
        let tracksToDelete: IndexSet = currentViewController.invertedSelection
        
        if tracksToDelete.isNonEmpty {
            
            _ = playQueueDelegate.removeTracks(at: tracksToDelete)
            
            controllers.forEach {
                $0.reloadTable()
            }
        }
        
        updateSummary()
    }
    
    @IBAction func removeAllTracksAction(_ sender: NSButton) {
        
        playQueueDelegate.removeAllTracks()
        controllers.forEach {$0.reloadTable()}
        updateSummary()
    }
    
    @IBAction func moveTracksUpAction(_ sender: Any) {
        moveTracksUp()
    }
    
    // Must have a non-empty playlist, and at least one selected row, but not all rows selected.
    func moveTracksUp() {

        guard currentViewController.atLeastTwoRowsAndNotAllSelected else {return}

        let selectedRows = currentViewController.selectedRows
        let results = playQueueDelegate.moveTracksUp(from: selectedRows)
        
        controllers.forEach {
            $0.moveAndReloadItems(results.sorted(by: <))
        }
        
        updateSummary()
        
        if let minRow = selectedRows.min() {
            currentViewController.scrollRowToVisible(minRow)
        }
    }
    
    @IBAction func moveTracksDownAction(_ sender: Any) {
        
//        moveTracksDown()
//        updateSummaryIfRequired()
    }
    
    @IBAction func moveTracksToTopAction(_ sender: Any) {
        
//        moveTracksToTop()
//        updateSummaryIfRequired()
    }
    
    @IBAction func moveTracksToBottomAction(_ sender: Any) {
        
//        moveTracksToBottom()
//        updateSummaryIfRequired()
    }
    
    @IBAction func clearSelectionAction(_ sender: NSButton) {
//        clearSelection()
    }
    
    @IBAction func invertSelectionAction(_ sender: NSButton) {
//        invertSelection()
    }
    
    @IBAction func exportToPlaylistFileAction(_ sender: NSButton) {
//        exportTrackList()
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
//        tableView.reloadData()
        updateSummary()
    }
    
    @IBAction func pageUpAction(_ sender: NSButton) {
//        pageUp()
    }
    
    @IBAction func pageDownAction(_ sender: NSButton) {
//        pageDown()
    }
    
    @IBAction func scrollToTopAction(_ sender: NSButton) {
//        scrollToTop()
    }
    
    @IBAction func scrollToBottomAction(_ sender: NSButton) {
//        scrollToBottom()
    }
}
