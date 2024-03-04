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

class FavoriteArtistsViewController: FavoriteGroupsViewController {
    
    override var nibName: String? {"FavoriteArtists"}
    
    override var numberOfGroups: Int {
        favoritesDelegate.numberOfFavoriteArtists
    }
    
    override func groupName(forRow row: Int) -> String? {
        favoritesDelegate.favoriteArtist(atChronologicalIndex: row)?.groupName
    }
    
    override func image(forRow row: Int) -> NSImage {
        .imgArtistGroup
    }
}
