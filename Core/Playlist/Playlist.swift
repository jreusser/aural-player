//
//  Playlist.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Foundation

///
/// A facade for all operations pertaining to the playlist. Delegates operations to the underlying
/// playlists (flat and grouping/hierarchical), and aggregates results from those operations.
///
class Playlist: TrackListWrapper, PlaylistProtocol, UserManagedObject {
    
    var key: String {

        get {name}
        set {name = newValue}
    }

    let userDefined: Bool = true

    var name: String
    
    // TODO:
//    let dateCreated: Date
    
    init(name: String) {
        self.name = name
    }
}

extension Playlist: PersistentModelObject {
    
    // Returns all state for this playlist that needs to be persisted to disk
    var persistentState: PlaylistPersistentState {
        PlaylistPersistentState(name: name, tracks: tracks.map {$0.file})
    }
}
