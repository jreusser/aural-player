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

class TableViewController: NSViewController, ColorSchemeObserver {
    
    @IBOutlet weak var tableView: NSTableView!
    
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
}
