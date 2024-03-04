//
//  FavoriteTracksViewController.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import AppKit

class FavoriteTracksViewController: NSViewController {
    
    override var nibName: String? {"FavoriteTracks"}
    
    @IBOutlet weak var tableView: NSTableView!
    
    private lazy var messenger: Messenger = Messenger(for: self)
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.startTrackingView(options: [.activeAlways, .mouseMoved])
        
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

extension FavoriteTracksViewController: NSTableViewDataSource, NSTableViewDelegate {
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        favoritesDelegate.numberOfFavoriteTracks
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
              let track = favoritesDelegate.favoriteTrack(atChronologicalIndex: row)?.track else {return nil}
        
        let titleAndArtist = track.titleAndArtist
        let builder = TableCellBuilder()
        
        if let artist = titleAndArtist.artist {
            
            builder.withAttributedText(strings: [(text: artist + "  ", font: systemFontScheme.normalFont, color: systemColorScheme.secondaryTextColor),
                                                        (text: titleAndArtist.title, font: systemFontScheme.normalFont, color: systemColorScheme.primaryTextColor)],
                                              selectedTextColors: [systemColorScheme.secondarySelectedTextColor, systemColorScheme.primarySelectedTextColor],
                                              bottomYOffset: systemFontScheme.tableYOffset)
            
        } else {
            
            builder.withAttributedText(strings: [(text: titleAndArtist.title,
                                                         font: systemFontScheme.normalFont,
                                                         color: systemColorScheme.primaryTextColor)], selectedTextColors: [systemColorScheme.primarySelectedTextColor],
                                              bottomYOffset: systemFontScheme.tableYOffset)
        }
        
        builder.withImage(image: track.art?.image ?? .imgPlayingArt)
        
        return builder.buildCell(forTableView: tableView, forColumnWithId: columnId, inRow: row)
    }
}

extension FavoriteTracksViewController: FontSchemeObserver {
    
    func fontSchemeChanged() {
        tableView.reloadData()
    }
}

extension FavoriteTracksViewController: ColorSchemeObserver {
    
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
