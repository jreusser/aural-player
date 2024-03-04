//
//  FavoriteArtistsViewController.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import AppKit

class FavoriteArtistsViewController: NSViewController {
    
    override var nibName: String? {"FavoriteArtists"}
    
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

extension FavoriteArtistsViewController: NSTableViewDataSource, NSTableViewDelegate {
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        favoritesDelegate.numberOfFavoriteArtists
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
              let artist = favoritesDelegate.favoriteArtist(atChronologicalIndex: row)?.groupName else {return nil}
        
        let builder = TableCellBuilder().withText(text: artist,
                                                  inFont: systemFontScheme.normalFont,
                                                  andColor: systemColorScheme.primaryTextColor,
                                                  selectedTextColor: systemColorScheme.primarySelectedTextColor).withImage(image: .imgArtistGroup)
        
        return builder.buildCell(forTableView: tableView, forColumnWithId: columnId, inRow: row)
    }
}

extension FavoriteArtistsViewController: FontSchemeObserver {
    
    func fontSchemeChanged() {
        tableView.reloadData()
    }
}

extension FavoriteArtistsViewController: ColorSchemeObserver {
    
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
