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

class PlaylistNamesTableViewController: NSViewController, NSTableViewDelegate, NSTableViewDataSource, NSTextFieldDelegate, ColorSchemeObserver {
    
    @IBOutlet weak var tableView: NSTableView!
    @IBOutlet weak var playlistViewController: PlaylistViewController!
    
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
        
        let cell = builder.buildCell(forTableView: tableView, forColumnWithId: columnId)
        cell?.textField?.delegate = self
        
        return cell
    }
    
    func tableViewSelectionDidChange(_ notification: Notification) {
        
        let shouldShowPlaylist: Bool = selectedRowCount == 1
        playlistViewController.showViewIf(shouldShowPlaylist)
        
        if shouldShowPlaylist, let row = selectedRows.first {
            
            let playlist = playlistsManager.userDefinedObjects[row]
            playlistViewController.setPlaylist(playlist)
        }
    }
    
    // -------------------- Responding to notifications -------------------------------------------
    
    // Selects (and shows) a certain track within the playlist view
    func selectPlaylist(at index: Int) {
        
        if index >= 0 && index < rowCount {
            
            tableView.selectRow(index)
            tableView.scrollRowToVisible(index)
        }
    }
    
    func playlistsRemoved(from indices: IndexSet) {
        
        guard !indices.isEmpty else {return}
        
        // Tell the playlist view that the number of rows has changed (should result in removal of rows)
        tableView.noteNumberOfRowsChanged()
        
        // Update all rows from the first (i.e. smallest index) removed row, down to the end of the playlist
        guard let firstRemovedRow = indices.min() else {return}
        
        let lastRowAfterRemove = numberOfPlaylists - 1
        
        // This will be true unless a contiguous block of tracks was removed from the bottom of the playlist.
        if firstRemovedRow <= lastRowAfterRemove {
            tableView.reloadRows(firstRemovedRow...lastRowAfterRemove)
        }
    }
    
    // MARK: Actions
    
    @IBAction func createEmptyPlaylistAction(_ sender: NSMenuItem) {
        
        var newPlaylistName: String = "New Playlist"
        var ctr: Int = 1
        
        while playlistsManager.objectExists(named: newPlaylistName) {
            
            ctr.increment()
            newPlaylistName = "New Playlist \(ctr)"
        }
        
        _ = playlistsManager.createNewPlaylist(named: newPlaylistName)
        tableView.noteNumberOfRowsChanged()
        
        let rowIndex = lastRow
        tableView.selectRow(rowIndex)
        editTextField(inRow: rowIndex)
    }
    
    private func editTextField(inRow row: Int) {
        
        let rowView = tableView.rowView(atRow: row, makeIfNecessary: true)
        
        if let editedTextField = (rowView?.view(atColumn: 0) as? NSTableCellView)?.textField {
            view.window?.makeFirstResponder(editedTextField)
        }
    }
    
    @IBAction func deleteSelectedPlaylistsAction(_ sender: NSButton) {
        
        let selectedRows = self.selectedRows
        guard !selectedRows.isEmpty else {return}
        
        for row in selectedRows.sortedDescending() {
            _ = playlistsManager.deleteObject(atIndex: row)
        }
        
        playlistViewController.showViewIf(false)
        tableView.reloadData()
    }
    
    @IBAction func renameSelectedPlaylistAction(_ sender: NSButton) {
        
        let selectedRows = self.selectedRows
        guard selectedRows.count == 1, let selectedRow = selectedRows.first else {return}
        
        editTextField(inRow: selectedRow)
    }
    
    // MARK: Text field delegate functions
    
    func controlTextDidEndEditing(_ obj: Notification) {
        
        guard let editedTextField = obj.object as? NSTextField else {return}
        
        let rowIndex = tableView.selectedRow
        let playlist = playlistsManager.userDefinedObjects[rowIndex]
        
        let oldPlaylistName = playlist.name
        let newPlaylistName = editedTextField.stringValue
        
        // No change in playlist name. Nothing to be done.
        if newPlaylistName == oldPlaylistName {return}
        
        editedTextField.textColor = .defaultSelectedLightTextColor
        
        // If new name is empty or a playlist with the new name exists, revert to old value.
        if newPlaylistName.isEmptyAfterTrimming {
            
            editedTextField.stringValue = playlist.name
            
            _ = DialogsAndAlerts.genericErrorAlert("Can't rename playlist", "Playlist name must have at least one non-whitespace character.", "Please type a valid name.").showModal()
            
        } else if playlistsManager.objectExists(named: newPlaylistName) {
            
            editedTextField.stringValue = playlist.name
            
            _ = DialogsAndAlerts.genericErrorAlert("Can't rename playlist", "Another playlist with that name already exists.", "Please type a unique name.").showModal()
            
        } else {
            
            playlistsManager.renameObject(named: oldPlaylistName, to: newPlaylistName)
            playlistViewController.setPlaylist(playlist)
        }
    }
}

extension NSUserInterfaceItemIdentifier {
    
    static let cid_playlistName: NSUserInterfaceItemIdentifier = NSUserInterfaceItemIdentifier("cid_PlaylistName")
}
