//
//  TableViewController+DataSource.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import AppKit

extension TrackListViewController: NSTableViewDataSource {
    
    // Returns the total number of playlist rows
    func numberOfRows(in tableView: NSTableView) -> Int {numberOfTracks}
    
    // MARK: Drag n drop
    
    // Writes source information to the pasteboard
    func tableView(_ tableView: NSTableView, writeRowsWith rowIndexes: IndexSet, to pasteboard: NSPasteboard) -> Bool {
        
        if isTrackListBeingModified {return false}
        pasteboard.sourceIndexes = rowIndexes
        
        return true
    }
    
    // Validates the proposed drag/drop operation
    func tableView(_ tableView: NSTableView, validateDrop info: NSDraggingInfo, proposedRow row: Int, proposedDropOperation dropOperation: NSTableView.DropOperation) -> NSDragOperation {
        
        if isTrackListBeingModified {return .invalidDragOperation}
        
        // If the source is the same tableView, that means tracks are being reordered.
        if let sourceTable = info.draggingSource as? NSTableView,
           sourceTable == self.tableView, let sourceIndexSet = info.sourceIndexes {
            
            // Reordering of tracks
            return validateReorderOperation(tableView, sourceIndexSet, row, dropOperation) ? .move : .invalidDragOperation
        }
        
        // TODO: What about items added from apps other than Finder ??? From VOX or other audio players ???
        
        // Otherwise, files are being dragged in from outside the table view
        // (e.g. tracks/playlists from Finder or drag/drop from another track list).
        return .copy
    }
    
    // Given source indexes, a destination index (dropRow), and the drop operation (on/above), determines if the drop is a valid reorder operation (depending on the bounds of the playlist, and the source and destination indexes)
    private func validateReorderOperation(_ tableView: NSTableView, _ sourceIndexSet: IndexSet, _ dropRow: Int, _ operation: NSTableView.DropOperation) -> Bool {
        
        // If all rows are selected, they cannot be moved, and dropRow cannot be one of the source rows
        return operation == .above && (sourceIndexSet.count < tableView.numberOfRows) && !sourceIndexSet.contains(dropRow)
    }
    
    // Performs the drop
    func tableView(_ tableView: NSTableView, acceptDrop info: NSDraggingInfo, row: Int, dropOperation: NSTableView.DropOperation) -> Bool {
        
        if isTrackListBeingModified {return false}
        
        if let sourceTable = info.draggingSource as? NSTableView, let sourceIndices = info.sourceIndexes {
            
            if sourceTable == self.tableView {
                
                // Move tracks within the same table.
                moveTracks(from: sourceIndices, to: row)
                return true
                
            } else {
                
                // Import tracks from another table.
                importTracks(from: sourceTable, sourceIndices: sourceIndices, to: row)
                return true
            }
            
        } else if let files = info.urls {
            
            // Files added from Finder, add them to the playlist as URLs
            trackList.loadTracks(from: files, atPosition: row)
            return true
        }
        
        return false
    }
    
    private func moveTracks(from sourceIndices: IndexSet, to destRow: Int) {
        
        let results = trackList.moveTracks(from: sourceIndices, to: destRow)
        
        let sortedMoves = results.filter({$0.movedDown}).sorted(by: >) +
            results.filter({$0.movedUp}).sorted(by: <)
        
        var allIndices: [Int] = []
        var destinationIndices: [Int] = []
        
        for move in sortedMoves {
            
            tableView.moveRow(at: move.sourceIndex, to: move.destinationIndex)
            
            // Collect source and destination indices for later
            allIndices += [move.sourceIndex, move.destinationIndex]
            destinationIndices.append(move.destinationIndex)
        }
        
        // Reload all source and destination rows, and all rows in between.
        if let minReloadIndex = allIndices.min(), let maxReloadIndex = allIndices.max() {
            tableView.reloadRows(minReloadIndex...maxReloadIndex)
        }
        
        // Select all the destination rows (the new locations of the moved tracks).
        tableView.selectRows(destinationIndices)
    }
    
    @objc func importTracks(from otherTable: NSTableView, sourceIndices: IndexSet, to destRow: Int) {
        // Overriden by subclasses
    }
}

extension NSUserInterfaceItemIdentifier {
    
    static let tableId_compactPlayQueue: NSUserInterfaceItemIdentifier = .init(rawValue: "tid_CompactPlayQueue")
    static let tableId_playlist: NSUserInterfaceItemIdentifier = .init(rawValue: "tid_Playlist")
    static let tableId_playlistNames: NSUserInterfaceItemIdentifier = .init(rawValue: "tid_PlaylistNames")
}
