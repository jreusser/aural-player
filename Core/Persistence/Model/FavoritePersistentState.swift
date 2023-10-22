//
//  FavoritePersistentState.swift
//  Aural
//
//  Copyright © 2023 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Foundation

///
/// Persistent state for a single item in the **Favorites** list.
///
/// - SeeAlso: `Favorite`
///
struct FavoritePersistentState: Codable {

    let key: String?   // URL path
    let type: PlayableItemType?
    let name: String?
    
    init(favorite: Favorite) {
        
        self.key = favorite.key
        self.type = favorite.type
        self.name = favorite.name
    }
}
