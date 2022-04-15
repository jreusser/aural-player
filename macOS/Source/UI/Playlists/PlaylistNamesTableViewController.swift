//
//  PlaylistNamesTableViewController.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import Foundation
import AppKit

class PlaylistNamesTableViewController: NSViewController, NSTableViewDelegate, NSTableViewDataSource, ColorSchemeObserver {
    
    @IBOutlet weak var tableView: NSTableView!
    
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

    // ---------------- NSTableViewDataSource --------------------
    
    // Returns the total number of playlist rows
    func numberOfRows(in tableView: NSTableView) -> Int {
        numberOfPlaylists
    }
    
    // ---------------- NSTableViewDelegate --------------------
    
    var rowHeight: CGFloat {25}
    
    var numberOfPlaylists: Int {
        playlistsManager.numberOfUserDefinedObjects
    }
    
    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {rowHeight}
    
    // Returns a view for a single row
    func tableView(_ tableView: NSTableView, rowViewForRow row: Int) -> NSTableRowView? {
        AuralTableRowView()
    }
    
    func playlist(forRow row: Int) -> Playlist? {
        playlistsManager.userDefinedObjects[row]
    }
    
    // Returns a view for a single column
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        guard let playlist = playlist(forRow: row), let columnId = tableColumn?.identifier,
              columnId == .cid_playlistName else {return nil}
        
        let builder = TableCellBuilder().withText(text: playlist.name,
                                                  inFont: systemFontScheme.playlist.trackTextFont,
                                                  andColor: systemColorScheme.primaryTextColor)
        
        return builder.buildCell(forTableView: tableView, forColumnWithId: columnId)
    }
    
    // -------------------- Responding to notifications -------------------------------------------
    
    // Selects (and shows) a certain track within the playlist view
    func selectPlaylist(at index: Int) {
        
        if index >= 0 && index < rowCount {
            
            tableView.selectRow(index)
            tableView.scrollRowToVisible(index)
        }
    }

    func playlistAdded(atIndex index: Int) {
        tableView.insertRows(at: IndexSet(integer: index), withAnimation: .slideDown)
    }
    
    func playlistsRemoved(from indices: IndexSet) {
        
        guard !indices.isEmpty else {return}
        
        // Tell the playlist view that the number of rows has changed (should result in removal of rows)
        tableView.noteNumberOfRowsChanged()
        
        // Update all rows from the first (i.e. smallest index) removed row, down to the end of the playlist
        guard let firstRemovedRow = indices.min() else {return}
        
        let lastPlaylistRowAfterRemove = numberOfPlaylists - 1
        
        // This will be true unless a contiguous block of tracks was removed from the bottom of the playlist.
        if firstRemovedRow <= lastPlaylistRowAfterRemove {
            tableView.reloadRows(firstRemovedRow...lastPlaylistRowAfterRemove)
        }
    }
}

extension NSUserInterfaceItemIdentifier {
    
    static let cid_playlistName: NSUserInterfaceItemIdentifier = NSUserInterfaceItemIdentifier("cid_PlaylistName")
}
