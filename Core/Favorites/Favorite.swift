//
//  Favorite.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Foundation

///
/// Encapsulates a user-defined favorite (a track marked as such).
///
class Favorite: UserManagedObject, Hashable {
    
    var track: Track
    
    // The file of the track being favorited
    var file: URL {
        track.file
    }
    
    // Used by the UI (track.displayName)
    var name: String {
        track.displayName
    }
    
    var key: String {
        
        get {file.path}
        set {} // Do nothing
    }
    
    var userDefined: Bool {true}
    
    init(track: Track) {
        self.track = track
    }
    
    init?(persistentState: FavoritePersistentState) {
        
        guard let file = persistentState.file else {return nil}
        self.track = Track(file)
    }
    
    static func == (lhs: Favorite, rhs: Favorite) -> Bool {
        lhs.file == rhs.file
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(file)
    }
}
