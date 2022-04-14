//
//  TableViewController.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import Cocoa

class TableViewController: NSViewController, NSTableViewDelegate, ColorSchemeObserver {
    
    @IBOutlet weak var tableView: NSTableView!
    
    // Override this !
    var trackList: TrackListProtocol {TrackList()}
    
    var selectedRows: IndexSet {tableView.selectedRowIndexes}
    
    var selectedRowCount: Int {tableView.numberOfSelectedRows}
    
    var rowCount: Int {tableView.numberOfRows}
    
    var lastRow: Int {tableView.numberOfRows - 1}
    
    var atLeastTwoRowsAndNotAllSelected: Bool {
        
        let rowCount = self.rowCount
        return rowCount > 1 && (1..<rowCount).contains(selectedRowCount)
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        colorSchemesManager.registerObserver(self, forProperty: \.backgroundColor)
    }
    
    func colorChanged(to newColor: PlatformColor, forProperty property: KeyPath<ColorScheme, PlatformColor>) {
        tableView.setBackgroundColor(newColor)
    }
    
    // ---------------- NSTableViewDelegate --------------------
    
    var rowHeight: CGFloat {25}
    
    var numberOfTracks: Int {0}
    
    var isTrackListBeingModified: Bool {false}
    
    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {rowHeight}
    
    // Returns a view for a single row
    func tableView(_ tableView: NSTableView, rowViewForRow row: Int) -> NSTableRowView? {
        AuralTableRowView()
    }
    
    func track(forRow row: Int) -> Track? {
        trackList[row]
    }
    
    // Returns a view for a single column
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        guard let track = track(forRow: row), let columnId = tableColumn?.identifier else {return nil}
        
        return view(forColumn: columnId, row: row, track: track)
            .buildCell(forTableView: tableView, forColumnWithId: columnId)
    }
    
    // Returns a view for a single column
    func view(forColumn column: NSUserInterfaceItemIdentifier, row: Int, track: Track) -> TableCellBuilder {
        TableCellBuilder()
    }
    
    // ---------------- NSTableViewDataSource --------------------
    
    func insertFiles(_ files: [URL], atRow destRow: Int? = nil) {}
    
    // --------------------- Responding to commands ------------------------------------------------
    
    // Invokes the Open file dialog, to allow the user to add tracks/playlists to the app playlist
    func addTracks() {
        
        guard !isTrackListBeingModified else {return}
        
        let fileOpenDialog = DialogsAndAlerts.openFilesAndFoldersDialog
        
        if fileOpenDialog.runModal() == .OK {
            insertFiles(fileOpenDialog.urls)
        }
    }
    
    func removeTracks() {
        
        if selectedRowCount > 0 {
            
            _ = trackList.removeTracks(at: selectedRows)
            tableView.clearSelection()
        }
    }
    
    func cropSelection() {
        
        let tracksToDelete: IndexSet = tableView.invertedSelection
        
        if tracksToDelete.count > 0 {
            
            _ = trackList.removeTracks(at: tracksToDelete)
            tableView.reloadData()
        }
    }
    
    // -------------------- Responding to notifications -------------------------------------------
    
    // Selects (and shows) a certain track within the playlist view
    func selectTrack(_ index: Int) {
        
        if index >= 0 && index < rowCount {
            
            tableView.selectRow(index)
            tableView.scrollRowToVisible(index)
        }
    }
    
    // Must have a non-empty playlist, and at least one selected row, but not all rows selected.
    func moveTracksUp() {

        guard atLeastTwoRowsAndNotAllSelected else {return}

        let results = trackList.moveTracksUp(from: selectedRows)
        
        moveAndReloadItems(results.sorted(by: TrackMoveResult.compareAscending))
        
        if let minRow = selectedRows.min() {
            tableView.scrollRowToVisible(minRow)
        }
    }

    // Must have a non-empty playlist, and at least one selected row, but not all rows selected.
    func moveTracksDown() {

        guard atLeastTwoRowsAndNotAllSelected else {return}

        let results = trackList.moveTracksDown(from: selectedRows)
        
        moveAndReloadItems(results.sorted(by: TrackMoveResult.compareDescending))
        
        if let minRow = selectedRows.min() {
            tableView.scrollRowToVisible(minRow)
        }
    }

    // Rearranges tracks within the view that have been reordered
    func moveAndReloadItems(_ results: [TrackMoveResult]) {

        for result in results {

            tableView.moveRow(at: result.sourceIndex, to: result.destinationIndex)
            tableView.reloadRows([result.sourceIndex, result.destinationIndex])
        }
    }

    // Must have a non-empty playlist, and at least one selected row, but not all rows selected.
    func moveTracksToTop() {

        let selectedRows = self.selectedRows
        let selectedRowCount = self.selectedRowCount
        
        guard atLeastTwoRowsAndNotAllSelected else {return}
        
        let results = trackList.moveTracksToTop(from: selectedRows)
        
        // Move the rows
        removeAndInsertItems(results.sorted(by: TrackMoveResult.compareAscending))
        
        // Refresh the relevant rows
        guard let maxSelectedRow = selectedRows.max() else {return}
        
        tableView.reloadRows(0...maxSelectedRow)
        
        // Select all the same rows but now at the top
        tableView.scrollToTop()
        tableView.selectRows(0..<selectedRowCount)
    }

    // Must have a non-empty playlist, and at least one selected row, but not all rows selected.
    func moveTracksToBottom() {

        let selectedRows = self.selectedRows
        let selectedRowCount = self.selectedRowCount
        
        guard atLeastTwoRowsAndNotAllSelected else {return}
        
        let results = trackList.moveTracksToBottom(from: selectedRows)
        
        // Move the rows
        removeAndInsertItems(results.sorted(by: TrackMoveResult.compareDescending))
        
        guard let minSelectedRow = selectedRows.min() else {return}
        
        let lastRow = self.lastRow
        
        // Refresh the relevant rows
        tableView.reloadRows(minSelectedRow...lastRow)
        
        // Select all the same items but now at the bottom
        let firstSelectedRow = lastRow - selectedRowCount + 1
        tableView.selectRows(firstSelectedRow...lastRow)
        tableView.scrollToBottom()
    }

    // Refreshes the playlist view by rearranging the items that were moved
    func removeAndInsertItems(_ results: [TrackMoveResult]) {

        for result in results {

            tableView.removeRows(at: IndexSet(integer: result.sourceIndex), withAnimation: result.movedUp ? .slideUp : .slideDown)
            tableView.insertRows(at: IndexSet(integer: result.destinationIndex), withAnimation: result.movedUp ? .slideDown : .slideUp)
        }
    }
    
    func trackAdded(_ notification: PlayQueueTrackAddedNotification) {
        tableView.insertRows(at: IndexSet(integer: notification.trackIndex), withAnimation: .slideDown)
    }
    
    func tracksAdded(at indices: ClosedRange<Int>) {
        
        tableView.noteNumberOfRowsChanged()
        tableView.reloadRows(indices.lowerBound..<rowCount)
    }
    
    func tracksRemoved(_ results: TrackRemovalResults) {
        
        let indices = results.indices
        guard !indices.isEmpty else {return}
        
        // Tell the playlist view that the number of rows has changed (should result in removal of rows)
        tableView.noteNumberOfRowsChanged()
        
        // Update all rows from the first (i.e. smallest index) removed row, down to the end of the playlist
        guard let firstRemovedRow = indices.min() else {return}
        
        let lastPlaylistRowAfterRemove = trackList.size - 1
        
        // This will be true unless a contiguous block of tracks was removed from the bottom of the playlist.
        if firstRemovedRow <= lastPlaylistRowAfterRemove {
            tableView.reloadRows(firstRemovedRow...lastPlaylistRowAfterRemove)
        }
    }
}
