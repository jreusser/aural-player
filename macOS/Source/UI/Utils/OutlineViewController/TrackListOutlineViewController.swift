//
//  TrackListOutlineViewController.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import Cocoa

class TrackListOutlineViewController: NSViewController, NSOutlineViewDelegate, NSOutlineViewDataSource {
    
    @IBOutlet weak var outlineView: NSOutlineView!
    
    // Override this !
    var trackList: TrackListProtocol! {nil}
    
    var selectedRows: IndexSet {outlineView.selectedRowIndexes}
    
    var invertedSelection: IndexSet {outlineView.invertedSelection}
    
    var selectedRowCount: Int {outlineView.numberOfSelectedRows}
    
    var selectedRowView: NSView? {
        return outlineView.rowView(atRow: outlineView.selectedRow, makeIfNecessary: false)
    }
    
    var rowCount: Int {outlineView.numberOfRows}
    
    var lastRow: Int {outlineView.numberOfRows - 1}
    
    var atLeastTwoRowsAndNotAllSelected: Bool {
        
        let rowCount = self.rowCount
        return rowCount > 1 && (1..<rowCount).contains(selectedRowCount)
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        outlineView.enableDragDrop()
        colorSchemesManager.registerObserver(outlineView, forProperty: \.backgroundColor)
    }
    
    func colorChanged(to newColor: PlatformColor, forProperty property: KeyPath<ColorScheme, PlatformColor>) {
        
        if property == \.backgroundColor {
            outlineView.setBackgroundColor(newColor)
        }
    }
    
    // MARK: NSOutlineViewDelegate
    
    // Returns a view for a single row
    func outlineView(_ outlineView: NSOutlineView, rowViewForItem item: Any) -> NSTableRowView? {
        AuralTableRowView()
    }
    
    // Determines the height of a single row
    func outlineView(_ outlineView: NSOutlineView, heightOfRowByItem item: Any) -> CGFloat {
        item is Group ? 100 : 30
    }
    
    // Enables type selection, allowing the user to conveniently and efficiently find a playlist track by typing its display name, which results in the track, if found, being selected within the playlist
    func outlineView(_ outlineView: NSOutlineView, typeSelectStringFor tableColumn: NSTableColumn?, item: Any) -> String? {
        
        // Only the track name column is used for type selection
        guard tableColumn?.identifier == .cid_trackName, let displayName = (item as? Track)?.displayName ?? (item as? Group)?.name else {return nil}
        
        if !(displayName.starts(with: "<") || displayName.starts(with: ">")) {
            return displayName
        }
        
        return nil
    }
    
    @inlinable
    @inline(__always)
    func reloadTable() {
        
        outlineView.reloadData()
        updateSummary()
    }
    
    /// Override this !
    func updateSummary() {}
}
