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
        colorSchemesManager.registerObserver(tableView, forProperties: [\.backgroundColor])
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
              let cell = tableView.makeView(withIdentifier: columnId, owner: nil) as? FavoritesTableCellView else {return nil}
        
        let favorite = favoritesDelegate.allFavoriteTracks[row]
        cell.setInfoFor(favorite: favorite)
        
        return cell
    }
}
