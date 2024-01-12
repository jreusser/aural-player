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
    
    let favoriteTracks: [FavoriteTrackPersistentState]?
    
    let favoriteArtists: [FavoriteGroupPersistentState]?
    let favoriteAlbums: [FavoriteGroupPersistentState]?
    let favoriteGenres: [FavoriteGroupPersistentState]?
    let favoriteDecades: [FavoriteGroupPersistentState]?
}

///
/// Persistent state for a single item in the **Favorites** list.
///
/// - SeeAlso: `FavoriteTrack`
///
struct FavoriteTrackPersistentState: Codable {
    
    var trackFile: URL? = nil
    
    init(favorite: FavoriteTrack) {
        self.trackFile = favorite.track.file
    }
}

///
/// Persistent state for a single item in the **Favorites** list.
///
/// - SeeAlso: `FavoriteGroup`
///
struct FavoriteGroupPersistentState: Codable {
    
    var groupName: String? = nil
    
    init(favorite: FavoriteGroup) {
        self.groupName = favorite.groupName
    }
}
