//
//  FavoriteAlbumsViewController.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import AppKit

class FavoriteAlbumsViewController: FavoriteGroupsViewController {
    
    override var nibName: String? {"FavoriteAlbums"}
    
    override var numberOfGroups: Int {
        favoritesDelegate.numberOfFavoriteAlbums
    }
    
    override func groupName(forRow row: Int) -> String? {
        favoritesDelegate.favoriteAlbum(atChronologicalIndex: row)?.groupName
    }
    
    override func image(forRow row: Int) -> NSImage {
        
        if let album = groupName(forRow: row) {
            return (libraryDelegate.findGroup(named: album, ofType: .album) as? AlbumGroup)?.art ?? .imgAlbumGroup
        }
        
        return .imgAlbumGroup
    }
}
