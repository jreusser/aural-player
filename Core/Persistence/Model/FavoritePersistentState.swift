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

struct FavoritesPersistentState: Codable {
    let favorites: [FavoritePersistentState]?
}

enum FavoritePersistentItemType: String, Codable {
    
    case track
    case playlistFile
    case folder
    case group
}

///
/// Persistent state for a single item in the **Favorites** list.
///
/// - SeeAlso: `Favorite`
///
struct FavoritePersistentState: Codable {
    
    let itemType: FavoritePersistentItemType?

    var trackFile: URL? = nil
    
    var playlistFile: URL? = nil
    
    var folder: URL? = nil
    
    var groupName: String? = nil
    var groupType: GroupType? = nil
    
    init?(favorite: Favorite) {
        
        if let trackItem = favorite as? FavoriteTrack {
            
            self.itemType = .track
            self.trackFile = trackItem.track.file
            
            return
        }
        
        if let groupItem = favorite as? FavoriteGroup {
            
            self.itemType = .group
            self.groupName = groupItem.groupName
            self.groupType = groupItem.groupType
            
            return
        }
        
        return nil
    }
}
