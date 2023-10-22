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
    var file: URL? {
        type.equalsOneOf(.track, .playlist, .folder) ? URL(fileURLWithPath: _key) : nil
    }
    
    let type: PlayableItemType
    
    // Used by the UI (track.displayName)
    let name: String
    
    var key: String {
        
        get {_key}
        set {} // Do nothing
    }
    
    private var _key: String
    
    var userDefined: Bool {true}
    
    init(track: Track) {
        
        self._key = track.file.path
        self.type = .track
        self.name = track.displayName
    }
    
    // Playlists and folders
    init(file: URL, type: PlayableItemType) {
        
        self._key = file.path
        self.type = type
        self.name = file.lastPathComponent
    }
    
    // Artists, albums, genres, and decades
    init(name: String, type: PlayableItemType) {
        
        self._key = name
        self.type = type
        self.name = name
    }
    
    init?(persistentState: FavoritePersistentState) {
        
        guard let key = persistentState.key,
        let type = persistentState.type else {return nil}
        
        self._key = key
        self.type = type
        
        switch type {
            
        case .track, .playlist, .folder:
            self.name = URL(fileURLWithPath: key).lastPathComponent
            
        default:
            self.name = key
        }
    }
    
    static func == (lhs: Favorite, rhs: Favorite) -> Bool {
        lhs.key == rhs.key
    }
    
    func hash(into hasher: inout Hasher) {
        
        hasher.combine(key)
        hasher.combine(type)
    }
}

enum PlayableItemType: String, Codable {
    
    case track
    case playlist
    case artist
    case album
    case genre
    case decade
    case folder
}
