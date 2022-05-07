//
//  DevicesViewController+TableViewDelegate.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import Cocoa

extension DevicesViewController: NSTableViewDataSource, NSTableViewDelegate {
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        audioGraphDelegate.availableDevices.numberOfDevices
    }
    
    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {24}
    
    func tableView(_ tableView: NSTableView, rowViewForRow row: Int) -> NSTableRowView? {
        AuralTableRowView()
    }
    
    // Returns a view for a single column
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        let device = audioGraphDelegate.availableDevices.allDevices[row]
        
        let builder = TableCellBuilder().withText(text: device.name, inFont: systemFontScheme.effectsPrimaryFont,
                                                  andColor: systemColorScheme.primaryTextColor, selectedTextColor: systemColorScheme.primarySelectedTextColor)
        
        let cell = builder.buildCell(forTableView: tableView, forColumnWithId: .cid_Device)
        
        cell?.rowSelectionStateFunction = {[weak tableView] in
            tableView?.selectedRowIndexes.contains(row) ?? false
        }
        
        return cell
    }
}

extension NSUserInterfaceItemIdentifier {
    
    static let cid_Device: NSUserInterfaceItemIdentifier = NSUserInterfaceItemIdentifier("cid_Device")
}
