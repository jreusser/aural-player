//
//  DevicesViewController+TableViewDelegate.swift
//  Aural
//
//  Copyright © 2023 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import Cocoa

extension DevicesViewController: NSTableViewDataSource, NSTableViewDelegate {
    
    private var devices: [AudioDevice] {
        audioGraphDelegate.availableDevices
    }
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        audioGraphDelegate.numberOfDevices
    }
    
    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {32}
    
    func tableView(_ tableView: NSTableView, rowViewForRow row: Int) -> NSTableRowView? {
        AuralTableRowView()
    }
    
    // Returns a view for a single column
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        guard let colId = tableColumn?.identifier else {return nil}
        
        let device = devices[row]
        
        switch colId {
            
        case .cid_Device:
            
            return createNameCell(with: tableView, forDevice: device, row: row)
            
        case .cid_DeviceType:
            
            guard let cell = createTypeCell(with: tableView, forDevice: device, row: row) else {return nil}
            
            let cstrt = LayoutConstraintsManager(for: cell.imageView!)
            cstrt.setHeight(20)
            cstrt.setWidth(20)
            cstrt.centerVerticallyInSuperview()
            cstrt.centerHorizontallyInSuperview()
            
            return cell
            
        default:
            
            return nil
        }
    }
    
    private func createNameCell(with tableView: NSTableView, forDevice device: AudioDevice, row: Int) -> NSTableCellView? {
        
        let builder = TableCellBuilder().withText(text: device.name, inFont: systemFontScheme.effectsPrimaryFont,
                                                  andColor: systemColorScheme.primaryTextColor,
                                                  selectedTextColor: systemColorScheme.primarySelectedTextColor)
        
        return builder.buildCell(forTableView: tableView, forColumnWithId: .cid_Device, inRow: row)
    }
    
    private func createTypeCell(with tableView: NSTableView, forDevice device: AudioDevice, row: Int) -> NSTableCellView? {
        
        let iconWithTooltip = device.icon
        let builder = TableCellBuilder().withImage(image: iconWithTooltip.image, inColor: systemColorScheme.secondaryTextColor)
        
        let cell = builder.buildCell(forTableView: tableView, forColumnWithId: .cid_DeviceType, inRow: row)
        cell?.imageView?.toolTip = iconWithTooltip.toolTip
        return cell
    }
    
    func tableViewSelectionDidChange(_ notification: Notification) {
        
        if selectionChangeIsInternal {return}
        
        let row = tableView.selectedRow
        guard row >= 0 else {return}
        
        audioGraphDelegate.outputDevice = devices[row]
    }
}

extension NSUserInterfaceItemIdentifier {
    
    static let cid_Device: NSUserInterfaceItemIdentifier = NSUserInterfaceItemIdentifier("cid_Device")
    static let cid_DeviceType: NSUserInterfaceItemIdentifier = NSUserInterfaceItemIdentifier("cid_DeviceType")
}
