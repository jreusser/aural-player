//
//  HistoryDelegate.swift
//  Aural
//
//  Copyright © 2023 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Foundation
import OrderedCollections

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
    var recentlyAddedItems: OrderedDictionary<String, HistoryItem>
    
    // Recently played items
    var recentlyPlayedItems: OrderedDictionary<String, HistoryItem>
    
    var lastPlaybackPosition: Double = 0
    
    var lastPlayedItem: HistoryItem? {
        recentlyPlayedItems.values.last
    }
    
    // Delegate used to perform playback
    private let player: PlaybackDelegateProtocol
    
    private let playQueue: PlayQueueDelegateProtocol
    
    let backgroundQueue: DispatchQueue = .global(qos: .background)
    
    private lazy var messenger = Messenger(for: self, asyncNotificationQueue: backgroundQueue)
    
    init(persistentState: HistoryPersistentState?, _ preferences: HistoryPreferences,
         _ playQueue: PlayQueueDelegateProtocol, _ player: PlaybackDelegateProtocol) {
        
        recentlyAddedItems = OrderedDictionary()
        recentlyPlayedItems = OrderedDictionary()
        lastPlaybackPosition = persistentState?.lastPlaybackPosition ?? 0
        
        self.playQueue = playQueue
        self.player = player
        
        // Restore the history model object from persistent state.
        
        // Move to a background thread to unblock the main thread.
        DispatchQueue.global(qos: .utility).async {
            
            let recentlyPlayed = persistentState?.recentlyPlayed?.compactMap {self.itemFromPersistentState($0)} ?? []
            
            for item in recentlyPlayed.reversed() {
                self.recentlyPlayedItems[item.key] = item
            }
        }
        
//        persistentState?.recentlyAdded?.reversed().forEach {item in
//            
//            if let file = item.file, let date = item.time {
//                recentlyAddedItems.add(HistoryItem(file, item.name ?? file.lastPathComponent, date))
//            }
//        }
//        
//        persistentState?.recentlyPlayed?.reversed().forEach {item in
//            
//            if let file = item.file, let date = item.time {
//                recentlyPlayedItems.add(HistoryItem(file, item.name ?? file.lastPathComponent, date))
//            }
//        }
        
        messenger.publish(.history_updated)
        
        messenger.subscribeAsync(to: .history_itemsAdded, handler: itemsAdded(_:))
        
        messenger.subscribeAsync(to: .player_trackTransitioned, handler: trackPlayed(_:),
                                 filter: {msg in msg.playbackStarted})
        
        messenger.subscribeAsync(to: .library_groupPlayed, handler: groupPlayed(_:))
        
        messenger.subscribe(to: .application_willExit, handler: appWillExit)
    }
    
    private func itemFromPersistentState(_ state: HistoryItemPersistentState) -> HistoryItem? {
        
        guard let itemType = state.itemType, let lastEventTime = state.lastEventTime, let eventCount = state.eventCount else {return nil}
        
        switch itemType {
            
        case .track:
            
            if let trackFile = state.trackFile {
                
                do {
                    
                    var fileMetadata = FileMetadata()
                    fileMetadata.primary = try fileReader.getPrimaryMetadata(for: trackFile)
                    
                    let track = Track(trackFile, fileMetadata: fileMetadata)
                    return TrackHistoryItem(track: track, lastEventTime: lastEventTime, eventCount: eventCount)
                    
                } catch {}
            }
            
            //        case .playlistFile:
            //
            //        case .folder:
            //
            
        case .group:
            
            if let groupName = state.groupName, let groupType = state.groupType {
                return GroupHistoryItem(groupName: groupName, groupType: groupType, lastEventTime: lastEventTime, eventCount: eventCount)
            }
            
            
        default:
            return nil
            
        }
        
        return nil
    }
    
    func allRecentlyAddedItems() -> [HistoryItem] {
        
        // Reverse the array for chronological order (most recent items first).
//        recentlyAddedItems.toArray().reversed()
        []
    }
    
    func allRecentlyPlayedItems() -> [HistoryItem] {
        
        // Reverse the array for chronological order (most recent items first)
        recentlyPlayedItems.values.reversed()
    }
    
    func addItem(_ item: URL) throws {
        
        if !item.exists {
            throw FileNotFoundError(item)
        }
        
//        playlist.addFiles([item])
    }
    
    func playItem(_ item: HistoryItem) throws {
        
        if let trackHistoryItem = item as? TrackHistoryItem {
            try playTrackItem(trackHistoryItem)
            
        } else if let groupHistoryItem = item as? GroupHistoryItem {
            playGroupItem(groupHistoryItem)
        }
    }
    
    private func playTrackItem(_ trackHistoryItem: TrackHistoryItem) throws {
        
        // Add it to the PQ
        playQueue.addTracks([trackHistoryItem.track])

        // Play it
        player.play(trackHistoryItem.track)
    }
    
    private func playGroupItem(_ groupHistoryItem: GroupHistoryItem) {
        
        guard let group = libraryDelegate.findGroup(named: groupHistoryItem.groupName, ofType: groupHistoryItem.groupType) else {return}
        
        doGroupPlayed(group)
        messenger.publish(EnqueueAndPlayNowCommand(tracks: group.tracks, clearPlayQueue: false))
    }
    
    func deleteItem(_ item: HistoryItem) {
//        recentlyPlayedItems.remove(item)
    }
    
    func resizeLists(_ recentlyAddedListSize: Int, _ recentlyPlayedListSize: Int) {
        
//        recentlyAddedItems.resize(recentlyAddedListSize)
//        recentlyPlayedItems.resize(recentlyPlayedListSize)
//        
//        messenger.publish(.history_updated)
    }
    
    func clearAllHistory() {
        
        recentlyAddedItems.removeAll()
        recentlyPlayedItems.removeAll()
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
        
//        if let lastPlayedItem = lastPlayedItem, lastPlaybackPosition > 0 {
//            try playItem(lastPlayedItem.file, fromPosition: lastPlaybackPosition)
//        }
    }
    
    // Whenever a track is played by the player, add an entry in the "Recently played" list
    func trackPlayed(_ notification: TrackTransitionNotification) {
        
        guard let newTrack = notification.endTrack else {return}
        
        if let existingHistoryItem: TrackHistoryItem = recentlyPlayedItems[newTrack.file.absoluteString] as? TrackHistoryItem {
            
            existingHistoryItem.markEvent()
            
            // Move to bottom (i.e. most recent)
            recentlyPlayedItems.removeValue(forKey: existingHistoryItem.key)
            recentlyPlayedItems[existingHistoryItem.key] = existingHistoryItem
            
        } else {
            recentlyPlayedItems[newTrack.file.absoluteString] = TrackHistoryItem(track: newTrack, lastEventTime: Date())
        }
        
        messenger.publish(.history_updated)
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
    
    func groupPlayed(_ notif: LibraryGroupPlayedNotification) {
        doGroupPlayed(notif.group)
    }
    
    private func doGroupPlayed(_ group: Group) {
        
        let groupKey = "\(group.type)_\(group.name)"
        
        if let existingHistoryItem: GroupHistoryItem = recentlyPlayedItems[groupKey] as? GroupHistoryItem {
            
            existingHistoryItem.markEvent()
            
            // Move to bottom (i.e. most recent)
            recentlyPlayedItems.removeValue(forKey: existingHistoryItem.key)
            recentlyPlayedItems[existingHistoryItem.key] = existingHistoryItem
            
        } else {
            recentlyPlayedItems[groupKey] = GroupHistoryItem(groupName: group.name, groupType: group.type, lastEventTime: Date())
        }
        
        messenger.publish(.history_updated)
    }
    
    var persistentState: HistoryPersistentState {
        
        let recentlyAdded = allRecentlyAddedItems().compactMap {HistoryItemPersistentState(item: $0)}
        let recentlyPlayed = allRecentlyPlayedItems().compactMap {HistoryItemPersistentState(item: $0)}
        
        return HistoryPersistentState(recentlyAdded: recentlyAdded, recentlyPlayed: recentlyPlayed, lastPlaybackPosition: lastPlaybackPosition)
    }
}
