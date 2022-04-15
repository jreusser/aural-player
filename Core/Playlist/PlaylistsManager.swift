//
//  PlaylistsManager.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  
import Foundation

///
/// Manages the collection of all playlists - the default playlist and all user-defined playlists (if any).
///
class PlaylistsManager: UserManagedObjects<Playlist>, PersistentModelObject {

    private lazy var messenger = Messenger(for: self)

    init(playlists: [Playlist]) {
        super.init(systemDefinedObjects: [], userDefinedObjects: playlists)
    }

    func createNewPlaylist(named name: String) -> Playlist {
        
        let newPlaylist = Playlist(name: name)
        addObject(newPlaylist)
        return newPlaylist
    }

    var persistentState: PlaylistsPersistentState {
        PlaylistsPersistentState(playlists: userDefinedObjects.map {$0.persistentState})
    }
}
