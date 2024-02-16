//
//  FavoritePersistentState.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
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
    let favoriteFolders: [FavoriteFolderPersistentState]?
    
    init(legacyPersistentState: [LegacyFavoritePersistentState]?) {
        
        self.favoriteTracks = legacyPersistentState?.compactMap {
            
            guard let path = $0.file else {return nil}
            return FavoriteTrackPersistentState(trackFile: URL(fileURLWithPath: path))
        }
        
        self.favoriteArtists = nil
        self.favoriteAlbums = nil
        self.favoriteGenres = nil
        self.favoriteDecades = nil
        self.favoriteFolders = nil
    }
    
    init(favoriteTracks: [FavoriteTrackPersistentState]?, favoriteArtists: [FavoriteGroupPersistentState]?, favoriteAlbums: [FavoriteGroupPersistentState]?, favoriteGenres: [FavoriteGroupPersistentState]?, favoriteDecades: [FavoriteGroupPersistentState]?, favoriteFolders: [FavoriteFolderPersistentState]?) {
        
        self.favoriteTracks = favoriteTracks
        self.favoriteArtists = favoriteArtists
        self.favoriteAlbums = favoriteAlbums
        self.favoriteGenres = favoriteGenres
        self.favoriteDecades = favoriteDecades
        self.favoriteFolders = favoriteFolders
    }
}

///
/// Persistent state for a single item in the **Favorites** list.
///
/// - SeeAlso: `FavoriteTrack`
///
struct FavoriteTrackPersistentState: Codable {
    
    var trackFile: URL? = nil
    
    init(trackFile: URL?) {
        self.trackFile = trackFile
    }
    
    init(favorite: FavoriteTrack) {
        self.trackFile = favorite.track.file
    }
}

///
/// Persistent state for a single item in the **Favorites** list.
///
/// - SeeAlso: `FavoriteFolder`
///
struct FavoriteFolderPersistentState: Codable {
    
    var folder: URL? = nil
    
    init(folder: URL?) {
        self.folder = folder
    }
    
    init(favorite: FavoriteFolder) {
        self.folder = favorite.folder
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
