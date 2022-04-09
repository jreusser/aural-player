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
    
    let fontSchemesManager: FontSchemesManager = objectGraph.fontSchemesManager
    let colorSchemesManager: ColorSchemesManager = objectGraph.colorSchemesManager
    
    var selectedRows: IndexSet {tableView.selectedRowIndexes}
    
    var selectedRowCount: Int {tableView.numberOfSelectedRows}
    
    var rowCount: Int {tableView.numberOfRows}
    
    var lastRow: Int {tableView.numberOfRows - 1}
    
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
        nil
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
    
    func dropTracks(fromIndices sourceIndices: IndexSet, toRow destRow: Int) -> [TrackMoveResult] {
        []
    }
    
    func insertFiles(_ files: [URL], atRow destRow: Int) {}
}
