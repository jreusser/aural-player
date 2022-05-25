//
//  TrackListTableViewController.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import Cocoa

class TrackListTableViewController: NSViewController, NSTableViewDelegate {
    
    @IBOutlet weak var tableView: NSTableView!
    
    // Override this !
    var trackList: TrackListProtocol! {nil}
    
    lazy var hasIndexColumn: Bool = {
        tableView.tableColumns[0].identifier == .cid_index
    }()
    
    var selectedRows: IndexSet {tableView.selectedRowIndexes}
    
    var invertedSelection: IndexSet {tableView.invertedSelection}
    
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
    
    lazy var fileOpenDialog = DialogsAndAlerts.openFilesAndFoldersDialog
    lazy var saveDialog = DialogsAndAlerts.savePlaylistDialog
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        tableView.enableDragDrop()
        colorSchemesManager.registerObserver(tableView, forProperty: \.backgroundColor)
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
            .buildCell(forTableView: tableView, forColumnWithId: columnId, inRow: row)
        
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
    
    @IBAction func importFilesAndFoldersAction(_ sender: NSButton) {
        importFilesAndFolders()
    }
    
    // Invokes the Open file dialog, to allow the user to add tracks/playlists to the app playlist
    func importFilesAndFolders() {
        
        if !trackList.isBeingModified, fileOpenDialog.runModal() == .OK {
            trackList.loadTracks(from: fileOpenDialog.urls)
        }
    }
    
    // Invokes the Open file dialog, to allow the user to add tracks/playlists to the app playlist
    func addChosenTracks(_ files: [URL]) {
        trackList.loadTracks(from: files)
    }
    
    @IBAction func removeTracksAction(_ sender: NSButton) {
        removeTracks()
    }
    
    func removeTracks() {
        _ = trackList.removeTracks(at: selectedRows)
    }
    
    func noteNumberOfRowsChanged() {
        tableView.noteNumberOfRowsChanged()
    }
    
    func reloadTableRows(_ rows: ClosedRange<Int>) {
        tableView.reloadRows(rows)
    }
    
    @IBAction func cropSelectionAction(_ sender: Any) {
        cropSelection()
    }
    
    func cropSelection() {
        
        trackList.cropTracks(at: selectedRows)
        reloadTable()
    }
    
    @IBAction func removeAllTracksAction(_ sender: NSButton) {
        removeAllTracks()
    }
    
    func removeAllTracks() {
        
        trackList.removeAllTracks()
        reloadTable()
    }
    
    @inlinable
    @inline(__always)
    func reloadTable() {
        tableView.reloadData()
    }
    
    // MARK: Table view selection manipulation
    
    @IBAction func clearSelectionAction(_ sender: NSButton) {
        clearSelection()
    }
    
    @inlinable
    @inline(__always)
    func clearSelection() {
        tableView.clearSelection()
    }
    
    @IBAction func invertSelectionAction(_ sender: NSButton) {
        invertSelection()
    }
    
    @inlinable
    @inline(__always)
    func invertSelection() {
        tableView.invertSelection()
    }
    
    @IBAction func exportToPlaylistAction(_ sender: NSButton) {
        exportTrackList()
    }
    
    // Invokes the Save file dialog, to allow the user to save all playlist items to a playlist file
    func exportTrackList() {
        
        // Make sure there is at least one track to save.
        guard trackList.size > 0, !checkIfTrackListIsBeingModified() else {return}

        if saveDialog.runModal() == .OK, let playlistFile = saveDialog.url {
            trackList.exportToFile(playlistFile)
        }
    }
    
    private func checkIfTrackListIsBeingModified() -> Bool {
        
        let trackListBeingModified = trackList.isBeingModified

        if trackListBeingModified {

            NSAlert.showError(withTitle: "\(trackList.displayName) was not modified",
                              andText: "\(trackList.displayName) cannot be modified while tracks are being added. Please wait ...")
        }

        return trackListBeingModified
    }
    
    // -------------------- Responding to notifications -------------------------------------------
    
    // Selects (and shows) a certain track within the playlist view
    func selectTrack(at index: Int) {
        
        guard index >= 0 && index < rowCount else {return}
        
        tableView.selectRow(index)
        tableView.scrollRowToVisible(index)
    }
    
    func selectRows(_ rows: Range<Int>) {
        tableView.selectRows(rows)
    }
    
    func selectRows(_ rows: ClosedRange<Int>) {
        tableView.selectRows(rows)
    }
    
    func selectRows(_ rows: [Int]) {
        tableView.selectRows(rows)
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
    
    func scrollRowToVisible(_ row: Int) {
        tableView.scrollRowToVisible(row)
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
    
    func tracksAdded(at indices: IndexSet) {
        
        guard indices.isNonEmpty else {return}
        
        tableView.noteNumberOfRowsChanged()
        tableView.reloadRows(indices.min()!..<numberOfTracks)
    }
    
    func tracksRemoved(at indices: IndexSet) {
        
        tableView.removeRows(at: indices, withAnimation: .slideUp)
        
        guard hasIndexColumn, let firstRemovedRow = indices.min() else {return}
        
        // Update all rows from the first (i.e. smallest index) removed row, down to the end of the track list.
        let lastRowAfterRemove = trackList.size - 1
        
        // This will be true unless a contiguous block of tracks was removed from the bottom of the track list.
        if firstRemovedRow <= lastRowAfterRemove {
            tableView.reloadRows(firstRemovedRow...lastRowAfterRemove, columns: [0])
        }
    }
}
