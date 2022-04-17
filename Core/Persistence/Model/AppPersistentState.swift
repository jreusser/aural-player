//
//  AppPersistentState.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
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
    var audioGraph: AudioGraphPersistentState?
    
    var metadata: MetadataPersistentState?
    
    var playbackProfiles: [PlaybackProfilePersistentState]?
    
    var history: HistoryPersistentState?
    var favorites: [FavoritePersistentState]?
    var bookmarks: [BookmarkPersistentState]?
    
    var musicBrainzCache: MusicBrainzCachePersistentState?
    
    init() {}
    
    static let defaults: AppPersistentState = AppPersistentState()
}
