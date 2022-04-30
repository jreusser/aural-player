//
//  TrackListViewController.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import Cocoa

class TrackListViewController: NSViewController, NSTableViewDelegate, ColorSchemePropertyObserver {
    
    @IBOutlet weak var tableView: NSTableView!
    
    // Override this !
    var trackList: TrackListProtocol! {nil}
    
    var selectedRows: IndexSet {tableView.selectedRowIndexes}
    
    var selectedTracks: [Track] {trackList[tableView.selectedRowIndexes]}
    
    var selectedRowCount: Int {tableView.numberOfSelectedRows}
    
    var selectedRowView: NSView? {
        return tableView.rowView(atRow: tableView.selectedRow, makeIfNecessary: false)
    }
    
    var rowCount: Int {tableView.numberOfRows}
    
    var lastRow: Int {tableView.numberOfRows - 1}
    
    var atLeastTwoRowsAndNotAllSelected: Bool {
        
        let rowCount = self.rowCount
        return rowCount > 1 && (1..<rowCount).contains(selectedRowCount)
    }
    
    private lazy var fileOpenDialog = DialogsAndAlerts.openFilesAndFoldersDialog
    
    private lazy var alertDialog: AlertWindowController = .instance
    
    private lazy var saveDialog = DialogsAndAlerts.savePlaylistDialog
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        tableView.enableDragDrop()
        colorSchemesManager.registerObserver(self, forProperty: \.backgroundColor)
    }
    
    func colorChanged(to newColor: PlatformColor, forProperty property: KeyPath<ColorScheme, PlatformColor>) {
        
        if property == \.backgroundColor {
            tableView.setBackgroundColor(newColor)
        }
    }
    
    // ---------------- NSTableViewDelegate --------------------
    
    var rowHeight: CGFloat {25}
    
    var numberOfTracks: Int {
        trackList?.size ?? 0
    }
    
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
        
        let cell = view(forColumn: columnId, row: row, track: track)
            .buildCell(forTableView: tableView, forColumnWithId: columnId)
        
        cell?.rowSelectionStateFunction = {[weak tableView] in
            tableView?.selectedRowIndexes.contains(row) ?? false
        }
        
        return cell
    }
    
    // Returns a view for a single column
    func view(forColumn column: NSUserInterfaceItemIdentifier, row: Int, track: Track) -> TableCellBuilder {
        TableCellBuilder()
    }
    
    // --------------------- Responding to commands ------------------------------------------------
    
    // Invokes the Open file dialog, to allow the user to add tracks/playlists to the app playlist
    func importFilesAndFolders() {
        
        guard !isTrackListBeingModified else {return}
        
        if fileOpenDialog.runModal() == .OK {
            trackList.loadTracks(from: fileOpenDialog.urls)
        }
    }
    
    // Invokes the Open file dialog, to allow the user to add tracks/playlists to the app playlist
    func addChosenTracks(_ files: [URL]) {
        trackList.loadTracks(from: files)
    }
    
    func removeTracks() {
        
        let selectedRows = self.selectedRows
        
        // Check for at least 1 row (and also get the minimum index).
        guard let firstRemovedRow = selectedRows.min() else {return}
        
        _ = trackList.removeTracks(at: selectedRows)
        tableView.clearSelection()
        
        // Tell the playlist view that the number of rows has changed (should result in removal of rows)
        tableView.noteNumberOfRowsChanged()
        
        // Update all rows from the first (i.e. smallest index) removed row, down to the end of the track list.
        let lastRowAfterRemove = trackList.size - 1
        
        // This will be true unless a contiguous block of tracks was removed from the bottom of the track list.
        if firstRemovedRow <= lastRowAfterRemove {
            tableView.reloadRows(firstRemovedRow...lastRowAfterRemove)
        }
    }
    
    func removeAllTracks() {
        
        trackList.removeAllTracks()
        tableView.reloadData()
    }
    
    func cropSelection() {
        
        let tracksToDelete: IndexSet = tableView.invertedSelection
        
        if tracksToDelete.isNonEmpty {
            
            _ = trackList.removeTracks(at: tracksToDelete)
            tableView.reloadData()
        }
    }
    
    // MARK: Table view selection manipulation
    
    func clearSelection() {
        tableView.clearSelection()
    }
    
    func invertSelection() {
        tableView.invertSelection()
    }
    
    // Invokes the Save file dialog, to allow the user to save all playlist items to a playlist file
    func exportTrackList() {
        
        // Make sure there is at least one track to save.
        guard trackList.size > 0, !checkIfTrackListIsBeingModified() else {return}
        
        if saveDialog.runModal() == .OK,
           let playlistFile = saveDialog.url {
            
            trackList.exportToFile(playlistFile)
        }
    }
    
    // TODO: Can this func be put somewhere common / shared ???
    private func checkIfTrackListIsBeingModified() -> Bool {
        
        let playlistBeingModified = trackList.isBeingModified
        
        if playlistBeingModified {
            
            alertDialog.showAlert(.error, "Playlist not modified",
                                  "The playlist cannot be modified while tracks are being added",
                                  "Please wait till the playlist is done adding tracks ...")
        }
        
        return playlistBeingModified
    }
    
    // -------------------- Responding to notifications -------------------------------------------
    
    // Selects (and shows) a certain track within the playlist view
    func selectTrack(at index: Int) {
        
        guard index >= 0 && index < rowCount else {return}
        
        tableView.selectRow(index)
        tableView.scrollRowToVisible(index)
    }
    
    // Must have a non-empty playlist, and at least one selected row, but not all rows selected.
    func moveTracksUp() {

        guard atLeastTwoRowsAndNotAllSelected else {return}

        let results = trackList.moveTracksUp(from: selectedRows)
        
        moveAndReloadItems(results.sorted(by: <))
        
        if let minRow = selectedRows.min() {
            tableView.scrollRowToVisible(minRow)
        }
    }

    // Must have a non-empty playlist, and at least one selected row, but not all rows selected.
    func moveTracksDown() {

        guard atLeastTwoRowsAndNotAllSelected else {return}

        let results = trackList.moveTracksDown(from: selectedRows)
        
        moveAndReloadItems(results.sorted(by: >))
        
        if let minRow = selectedRows.min() {
            tableView.scrollRowToVisible(minRow)
        }
    }

    // Rearranges tracks within the view that have been reordered
    private func moveAndReloadItems(_ results: [TrackMoveResult]) {

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
        removeAndInsertItems(results.sorted(by: <))
        
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
        removeAndInsertItems(results.sorted(by: >))
        
        guard let minSelectedRow = selectedRows.min() else {return}
        
        let lastRow = self.lastRow
        
        // Refresh the relevant rows
        tableView.reloadRows(minSelectedRow...lastRow)
        
        // Select all the same items but now at the bottom
        let firstSelectedRow = lastRow - selectedRowCount + 1
        tableView.selectRows(firstSelectedRow...lastRow)
        tableView.scrollToBottom()
    }
    
    func pageUp() {
        tableView.pageUp()
    }
    
    func pageDown() {
        tableView.pageDown()
    }
    
    func scrollToTop() {
        tableView.scrollToTop()
    }
    
    func scrollToBottom() {
        tableView.scrollToBottom()
    }

    // Refreshes the playlist view by rearranging the items that were moved
    func removeAndInsertItems(_ results: [TrackMoveResult]) {

        for result in results {

            tableView.removeRows(at: IndexSet(integer: result.sourceIndex), withAnimation: result.movedUp ? .slideUp : .slideDown)
            tableView.insertRows(at: IndexSet(integer: result.destinationIndex), withAnimation: result.movedUp ? .slideDown : .slideUp)
        }
    }
    
    func tracksAdded(at indices: ClosedRange<Int>) {
        
        tableView.noteNumberOfRowsChanged()
        tableView.reloadRows(indices.lowerBound..<numberOfTracks)
    }
}
