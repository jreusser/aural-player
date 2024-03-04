//
//  FavoriteGenresViewController.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import AppKit

class FavoriteGenresViewController: FavoriteGroupsViewController {
    
    override var nibName: String? {"FavoriteGenres"}
    
    override var numberOfGroups: Int {
        favoritesDelegate.numberOfFavoriteGenres
    }
    
    override func groupName(forRow row: Int) -> String? {
        favoritesDelegate.favoriteGenre(atChronologicalIndex: row)?.groupName
    }
    
    override func image(forRow row: Int) -> NSImage {
        .imgGenreGroup
    }
}
