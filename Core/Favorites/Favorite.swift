//
//  Favorite.swift
//  Aural
//
//  Copyright © 2023 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Foundation

///
/// Encapsulates a user-defined favorite (a track marked as such).
///
class Favorite: UserManagedObject, Hashable {
    
    // The file of the track being favorited
    let file: URL
    
    let type: FavoriteItemType
    
    // Used by the UI (track.displayName)
    let name: String
    
    var key: String {
        
        get {file.path}
        set {} // Do nothing
    }
    
    var userDefined: Bool {true}
    
    init(track: Track) {
        
        self.file = track.file
        self.type = .track
        self.name = track.displayName
    }
    
    // Playlists and folders
    init(file: URL, type: FavoriteItemType) {
        
        self.file = file
        self.type = type
        self.name = file.lastPathComponent
    }
    
    init?(persistentState: FavoritePersistentState) {
        
        guard let file = persistentState.file,
        let type = persistentState.type else {return nil}
        
        self.file = file
        self.type = type
        self.name = persistentState.name ?? (type == .track ? file.nameWithoutExtension : file.lastPathComponent)
        
    }
    
    static func == (lhs: Favorite, rhs: Favorite) -> Bool {
        lhs.file == rhs.file
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(file)
    }
}

enum FavoriteItemType: String, Codable {
    
    case track
    case playlist
    case folder
}
