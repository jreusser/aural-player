//
//  AppPersistentState.swift
//  Aural
//
//  Copyright © 2023 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Foundation

///
/// Top-level persistent state object that encapsulates all application state.
///
struct AppPersistentState: Codable {
    
    var appVersion: String?
    
    #if os(macOS)
    var ui: UIPersistentState?
    #endif
    
    var playlists: PlaylistsPersistentState?
    var playQueue: PlayQueuePersistentState?
    var library: LibraryPersistentState?
    var audioGraph: AudioGraphPersistentState?
    
    var metadata: MetadataPersistentState?
    
    var playbackProfiles: [PlaybackProfilePersistentState]?
    
    var history: HistoryPersistentState?
    var favorites: FavoritesPersistentState?
    var bookmarks: [BookmarkPersistentState]?
    
    var musicBrainzCache: MusicBrainzCachePersistentState?
    
    init() {}
    
    init(legacyAppPersistentState: LegacyAppPersistentState) {
        
        self.playQueue = .init(legacyPlaylistPersistentState: legacyAppPersistentState.playlist,
                               legacyPlaybackSequencePersistentState: legacyAppPersistentState.playbackSequence)
        
        self.favorites = .init(legacyPersistentState: legacyAppPersistentState.favorites)
        
        self.bookmarks = legacyAppPersistentState.bookmarks?.map {BookmarkPersistentState(legacyPersistentState: $0)}
        
        self.audioGraph = AudioGraphPersistentState(legacyPersistentState: legacyAppPersistentState.audioGraph)
    }
    
    static let defaults: AppPersistentState = AppPersistentState()
}
