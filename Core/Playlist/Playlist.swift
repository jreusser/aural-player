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
class Playlist: TrackList, PlaylistProtocol, UserManagedObject, TrackLoaderObserver {
    
    var name: String
    
    let dateCreated: Date
//    let dateModified: Date
//    let datePlayed: Date
    
    private var persistentTracks: [URL]? = nil
    
    var key: String {

        get {name}
        set {name = newValue}
    }

    let userDefined: Bool = true
    
    private lazy var loader: TrackLoader = TrackLoader()
    
    private lazy var messenger: Messenger = Messenger(for: self)

    init(name: String) {
        
        self.name = name
        self.dateCreated = Date()
    }
    
    init?(persistentState: PlaylistPersistentState) {
        
        guard let name = persistentState.name else {return nil}
        
        self.name = name
        self.dateCreated = persistentState.dateCreated ?? Date()
        self.persistentTracks = persistentState.tracks
    }
    
    func loadPersistentTracks() {
        
        if let files = self.persistentTracks, files.isNonEmpty {
            loadTracks(from: files)
        }
    }
    
    func loadTracks(from files: [URL], atPosition position: Int? = nil) {
        loadTracks(from: files, atPosition: position, usingLoader: loader, observer: self)
    }
    
    func preTrackLoad() {
        messenger.publish(.playlist_startedAddingTracks)
    }
    
    func postTrackLoad() {
        messenger.publish(.playlist_doneAddingTracks, payload: name)
    }
    
    func postBatchLoad(indices: ClosedRange<Int>) {
        messenger.publish(PlaylistTracksAddedNotification(playlistName: name, trackIndices: indices))
    }
}

extension Playlist: PersistentModelObject {
    
    // Returns all state for this playlist that needs to be persisted to disk
    var persistentState: PlaylistPersistentState {
        PlaylistPersistentState(name: name, tracks: tracks.map {$0.file}, dateCreated: dateCreated)
    }
}
