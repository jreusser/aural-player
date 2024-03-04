//
//  FavoriteGroupsViewController.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import AppKit

class FavoriteGroupsViewController: NSViewController {
    
    @IBOutlet weak var tableView: NSTableView!
    
    private lazy var messenger: Messenger = Messenger(for: self)
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        fontSchemesManager.registerObserver(self)
        
        colorSchemesManager.registerSchemeObserver(self)
        colorSchemesManager.registerPropertyObserver(self, forProperty: \.backgroundColor, changeReceiver: tableView)
        colorSchemesManager.registerPropertyObserver(self, forProperties: [\.primaryTextColor, \.secondaryTextColor], handler: tableTextColorChanged(_:))
        
        colorSchemesManager.registerPropertyObserver(self, forProperties: [\.primarySelectedTextColor, \.secondarySelectedTextColor],
                                                     handler: selectedTextColorChanged(_:))
        
        colorSchemesManager.registerPropertyObserver(self, forProperty: \.textSelectionColor,
                                                     handler: textSelectionColorChanged(_:))
        
        messenger.subscribe(to: .Favorites.itemAdded, handler: tableView.reloadData)
        messenger.subscribe(to: .Favorites.itemsRemoved, handler: tableView.reloadData)
    }
}

extension FavoriteGroupsViewController: NSTableViewDataSource, NSTableViewDelegate {
    
    // Override this !!!
    @objc var numberOfGroups: Int {
        0
    }
    
    // Override this !!!
    @objc func groupName(forRow row: Int) -> String? {
        nil
    }
    
    // Override this !!!
    @objc func image(forRow row: Int) -> NSImage {
        .imgGroup
    }
    
    // ----------------
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        numberOfGroups
    }
    
    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        30
    }
    
    func tableView(_ tableView: NSTableView, rowViewForRow row: Int) -> NSTableRowView? {
        AuralTableRowView()
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        guard let columnId = tableColumn?.identifier,
              columnId == .cid_favoriteColumn,
              let groupName = groupName(forRow: row) else {return nil}
        
        let builder = TableCellBuilder()
            .withText(text: groupName,
                      inFont: systemFontScheme.normalFont,
                      andColor: systemColorScheme.primaryTextColor,
                      selectedTextColor: systemColorScheme.primarySelectedTextColor)
            .withImage(image: image(forRow: row))
        
        return builder.buildCell(forTableView: tableView, forColumnWithId: columnId, inRow: row)
    }
}

extension FavoriteGroupsViewController: FontSchemeObserver {
    
    func fontSchemeChanged() {
        tableView.reloadData()
    }
}

extension FavoriteGroupsViewController: ColorSchemeObserver {
    
    func colorSchemeChanged() {
        
        tableView.setBackgroundColor(systemColorScheme.backgroundColor)
        tableView.reloadData()
    }
    
    func tableTextColorChanged(_ newColor: PlatformColor) {
        tableView.reloadData()
    }
    
    func selectedTextColorChanged(_ newColor: PlatformColor) {
        tableView.reloadRows(tableView.selectedRowIndexes)
    }
    
    func textSelectionColorChanged(_ newColor: PlatformColor) {
        tableView.redoRowSelection()
    }
}

