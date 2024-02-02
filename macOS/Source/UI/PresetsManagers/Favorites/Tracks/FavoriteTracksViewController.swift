//
//  FavoriteTracksViewController.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import AppKit

class FavoriteTracksViewController: NSViewController {
    
    override var nibName: String? {"FavoriteTracks"}
    
    @IBOutlet weak var tableView: NSTableView!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
//        colorSchemesManager.registerObserver(tableView, forProperties: [\.backgroundColor])
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
              columnId == .cid_favoriteColumn else {return nil}
        
        let track = favoritesDelegate.allFavoriteTracks[row].track
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
