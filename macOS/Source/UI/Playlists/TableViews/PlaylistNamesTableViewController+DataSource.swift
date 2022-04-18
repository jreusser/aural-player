//
//  PlaylistNamesTableViewController+DataSource.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import Cocoa

extension PlaylistNamesTableViewController {
    
    // Drag and drop.
    
    // Signifies an invalid drag/drop operation
    private static let invalidDragOperation: NSDragOperation = []
    
    // Returns the total number of playlist rows
    func numberOfRows(in tableView: NSTableView) -> Int {
        numberOfPlaylists
    }
    
    // MARK: Drag n drop
    
    // Writes source information to the pasteboard
    func tableView(_ tableView: NSTableView, writeRowsWith rowIndexes: IndexSet, to pasteboard: NSPasteboard) -> Bool {

        pasteboard.sourceIndexes = rowIndexes
        return true
    }
    
    // Validates the proposed drag/drop operation
    func tableView(_ tableView: NSTableView, validateDrop info: NSDraggingInfo, proposedRow row: Int, proposedDropOperation dropOperation: NSTableView.DropOperation) -> NSDragOperation {
        
//        // If the source is the same tableView, that means tracks are being reordered.
//        if let sourceTable = info.draggingSource as? NSTableView,
//           sourceTable == self.tableView, let sourceIndexSet = info.sourceIndexes {
//
//            // Reordering of tracks
//            return validateReorderOperation(tableView, sourceIndexSet, row, dropOperation) ? .move : Self.invalidDragOperation
//        }
        
        // TODO: What about items added from apps other than Finder ??? From VOX or other audio players ???
        
        // Otherwise, files are being dragged in from outside the table view
        // (e.g. tracks/playlists from Finder or drag/drop from another track list).
        return .copy
    }
    
//    // Performs the drop
//    func tableView(_ tableView: NSTableView, acceptDrop info: NSDraggingInfo, row: Int, dropOperation: NSTableView.DropOperation) -> Bool {
//
//        if let sourceTable = info.draggingSource as? NSTableView, let sourceIndices = info.sourceIndexes {
//
//            if sourceTable == self.tableView {
//
//                // Move tracks within the same table.
//                moveTracks(from: sourceIndices, to: row)
//                return true
//
//            } else {
//
//                // Import tracks from another table.
//                print("\nImporting tracks ...")
//                importTracks(from: sourceTable, sourceIndices: sourceIndices, to: row)
//                return true
//            }
//
//        } else if let files = info.urls {
//
//            // Files added from Finder, add them to the playlist as URLs
//            trackList.loadTracks(from: files, atPosition: row)
//            return true
//        }
//
//        return false
//    }
}
