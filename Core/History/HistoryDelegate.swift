//
//  HistoryDelegate.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Foundation

///
/// A delegate allowing access to the chronologically ordered track lists:
/// 1. tracks recently added to the playlist
/// 2. tracks recently played
///
/// Acts as a middleman between the UI and the History lists,
/// providing a simplified interface / facade for the UI layer to manipulate the History lists.
/// and add / play tracks from those lists.
///
/// - SeeAlso: `AddedItem`
/// - SeeAlso: `PlayedItem`
///
class HistoryDelegate: HistoryDelegateProtocol {
    
    // Recently added items
    var recentlyAddedItems: FixedSizeLRUArray<AddedItem>
    
    // Recently played items
    var recentlyPlayedItems: FixedSizeLRUArray<PlayedItem>
    
    var lastPlaybackPosition: Double = 0
    
    var lastPlayedItem: PlayedItem? {
        recentlyPlayedItems.last
    }
    
    // Delegate used to perform playback
    private let player: PlaybackDelegateProtocol
    
    private let playQueue: PlayQueueDelegateProtocol
    
    let backgroundQueue: DispatchQueue = .global(qos: .background)
    
    private lazy var messenger = Messenger(for: self, asyncNotificationQueue: backgroundQueue)
    
    init(persistentState: HistoryPersistentState?, _ preferences: HistoryPreferences,
         _ playQueue: PlayQueueDelegateProtocol, _ player: PlaybackDelegateProtocol) {
        
        recentlyAddedItems = FixedSizeLRUArray<AddedItem>(size: preferences.recentlyAddedListSize)
        recentlyPlayedItems = FixedSizeLRUArray<PlayedItem>(size: preferences.recentlyPlayedListSize)
        lastPlaybackPosition = persistentState?.lastPlaybackPosition ?? 0
        
        self.playQueue = playQueue
        self.player = player
        
        // Restore the history model object from persistent state.
        
        persistentState?.recentlyAdded?.reversed().forEach {item in
            
            if let file = item.file, let date = item.time {
                recentlyAddedItems.add(AddedItem(file, item.name ?? file.lastPathComponent, date))
            }
        }
        
        persistentState?.recentlyPlayed?.reversed().forEach {item in
            
            if let file = item.file, let date = item.time {
                recentlyPlayedItems.add(PlayedItem(file, item.name ?? file.lastPathComponent, date))
            }
        }
        
        messenger.publish(.history_updated)
        
        messenger.subscribeAsync(to: .history_itemsAdded, handler: itemsAdded(_:))
        
        messenger.subscribeAsync(to: .player_trackTransitioned, handler: trackPlayed(_:),
                                 filter: {msg in msg.playbackStarted})
        
        messenger.subscribe(to: .application_willExit, handler: appWillExit)
    }
    
    func allRecentlyAddedItems() -> [AddedItem] {
        
        // Reverse the array for chronological order (most recent items first).
        recentlyAddedItems.toArray().reversed()
    }
    
    func allRecentlyPlayedItems() -> [PlayedItem] {
        
        // Reverse the array for chronological order (most recent items first)
        recentlyPlayedItems.toArray().reversed()
    }
    
    func addItem(_ item: URL) throws {
        
        if !item.exists {
            throw FileNotFoundError(item)
        }
        
//        playlist.addFiles([item])
    }
    
    func playItem(_ item: URL, fromPosition startPosition: Double? = nil) throws {
        
        // First, find or add the given file
        playQueue.loadTracks(from: [item])
        guard let newTrack = playQueue.findTrack(forFile: item) else {return}
        
        // Play it
        if let startPosition = startPosition {
            player.play(newTrack, PlaybackParams.defaultParams().withStartAndEndPosition(startPosition))
        } else {
            player.play(newTrack)
        }
    }
    
    func deleteItem(_ item: AddedItem) {
        recentlyAddedItems.remove(item)
    }
    
    func deleteItem(_ item: PlayedItem) {
        recentlyPlayedItems.remove(item)
    }
    
    func resizeLists(_ recentlyAddedListSize: Int, _ recentlyPlayedListSize: Int) {
        
        recentlyAddedItems.resize(recentlyAddedListSize)
        recentlyPlayedItems.resize(recentlyPlayedListSize)
        
        messenger.publish(.history_updated)
    }
    
    func clearAllHistory() {
        
        recentlyAddedItems.clear()
        recentlyPlayedItems.clear()
    }
    
    func markLastPlaybackPosition(_ position: Double) {
        self.lastPlaybackPosition = position
    }
    
    // MARK: Event handling ------------------------------------------------------------------------------------------
    
    private func appWillExit() {
        
        if player.state == .stopped {return}
        
        let playerPosition = player.seekPosition.timeElapsed
        
        if playerPosition > 0 {
            self.lastPlaybackPosition = playerPosition
        }
    }
    
    func resumeLastPlayedTrack() throws {
        
        if let lastPlayedItem = lastPlayedItem, lastPlaybackPosition > 0 {
            try playItem(lastPlayedItem.file, fromPosition: lastPlaybackPosition)
        }
    }
    
    // Whenever a track is played by the player, add an entry in the "Recently played" list
    func trackPlayed(_ notification: TrackTransitionNotification) {
        
        if let newTrack = notification.endTrack {
        
            recentlyPlayedItems.add(PlayedItem(newTrack.file, newTrack.displayName, Date()))
            messenger.publish(.history_updated)
        }
    }
    
    // Whenever items are added to the playlist, add entries to the "Recently added" list
    func itemsAdded(_ files: [URL]) {
        
//        let now = Date()
//
//        for file in files {
//
////            if let track = playlist.findFile(file) {
////
////                // Track
////                recentlyAddedItems.add(AddedItem(track, now))
////
////            } else {
////
////                // Folder or playlist
////                recentlyAddedItems.add(AddedItem(file, now))
////            }
//        }
        
        messenger.publish(.history_updated)
    }
    
    var persistentState: HistoryPersistentState {
        
        let recentlyAdded = allRecentlyAddedItems().map {HistoryItemPersistentState(item: $0)}
        let recentlyPlayed = allRecentlyPlayedItems().map {HistoryItemPersistentState(item: $0)}
        
        return HistoryPersistentState(recentlyAdded: recentlyAdded, recentlyPlayed: recentlyPlayed, lastPlaybackPosition: lastPlaybackPosition)
    }
}
