//
//  HistoryDelegate.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
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
    func noteAddedItems(tracks: [Track]) {
        
    }
    
    func noteAddedItems(groups: [Group], tracks: [Track]) {
        
    }
    
    func noteAddedItems(playlistFiles: [ImportedPlaylist], tracks: [Track]) {
        
    }
    
    func noteAddedItems(folders: [FileSystemFolderItem], tracks: [FileSystemTrackItem], playlistFiles: [FileSystemPlaylistItem]) {
        
    }
    
    func noteAddedItems(playlist: Playlist) {
        
    }
    
    
    // Recently added items
    var recentlyAddedItems: OrderedDictionary<String, HistoryItem>
    
    // Recently played items
    var recentlyPlayedItems: OrderedDictionary<String, HistoryItem>
    
    var lastPlaybackPosition: Double = 0
    
    var lastPlayedItem: TrackHistoryItem? {
        recentlyPlayedItems.values.reversed().first(where: {$0 is TrackHistoryItem}) as? TrackHistoryItem
    }
    
    // Delegate used to perform playback
    private let player: PlaybackDelegateProtocol
    
    private let playQueue: PlayQueueDelegateProtocol
    
    let backgroundQueue: DispatchQueue = .global(qos: .background)
    
    private lazy var messenger = Messenger(for: self, asyncNotificationQueue: backgroundQueue)
    
    init(persistentState: HistoryPersistentState?, _ preferences: HistoryPreferences,
         _ playQueue: PlayQueueDelegateProtocol, _ player: PlaybackDelegateProtocol) {
        
        print("HistDelegate: init()")
        
        recentlyAddedItems = OrderedDictionary()
        recentlyPlayedItems = OrderedDictionary()
        lastPlaybackPosition = persistentState?.lastPlaybackPosition ?? 0
        
        self.playQueue = playQueue
        self.player = player
        
        messenger.publish(.history_updated)
        
        messenger.subscribeAsync(to: .history_itemsAdded, handler: itemsAdded(_:))
        
        messenger.subscribeAsync(to: .Player.trackTransitioned, handler: trackPlayed(_:),
                                 filter: {msg in msg.playbackStarted})
        
        messenger.subscribeAsync(to: .Library.fileSystemItemsPlayed, handler: fileSystemItemsPlayed(_:))
        messenger.subscribeAsync(to: .Library.groupPlayed, handler: groupPlayed(_:))
        
        messenger.subscribe(to: .application_willExit, handler: appWillExit)
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
    
    func playItem(_ item: HistoryItem) {
        
        if let trackHistoryItem = item as? TrackHistoryItem {
            playTrackItem(trackHistoryItem)
            
        } else if let playlistFileHistoryItem = item as? PlaylistFileHistoryItem {
            playPlaylistFileItem(playlistFileHistoryItem)
            
        } else if let folderHistoryItem = item as? FolderHistoryItem {
            playFolderItem(folderHistoryItem)
            
        } else if let groupHistoryItem = item as? GroupHistoryItem {
            playGroupItem(groupHistoryItem)
        }
    }
    
    private func playTrackItem(_ trackHistoryItem: TrackHistoryItem, fromPosition position: Double? = nil) {
        
        // Add it to the PQ
        playQueue.addTracks([trackHistoryItem.track])
        
        if let seekPosition = position {
            player.play(trackHistoryItem.track, PlaybackParams().withStartAndEndPosition(seekPosition))
        } else {
            player.play(trackHistoryItem.track)
        }
    }
    
    private func playPlaylistFileItem(_ playlistFileHistoryItem: PlaylistFileHistoryItem) {
        
        doPlaylistFilePlayed(playlistFileHistoryItem.playlistFile)
        
        // Add it to the PQ
        // TODO: Get it from the Library ! Don't re-load the tracks from the playlist.
        playQueue.loadTracks(from: [playlistFileHistoryItem.playlistFile], autoplay: true)
    }
    
    private func playGroupItem(_ groupHistoryItem: GroupHistoryItem) {
        
        guard let group = libraryDelegate.findGroup(named: groupHistoryItem.groupName, ofType: groupHistoryItem.groupType) else {return}
        
        doGroupPlayed(group)
        messenger.publish(EnqueueAndPlayNowCommand(tracks: group.tracks, clearPlayQueue: false))
    }
    
    private func playFolderItem(_ folderHistoryItem: FolderHistoryItem) {
        
        let folder = folderHistoryItem.folder
        
        doFolderPlayed(folder)
        messenger.publish(LoadAndPlayNowCommand(files: [folder], clearPlayQueue: false))
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
        
        if let lastPlayedItem = lastPlayedItem, lastPlaybackPosition > 0 {
            playTrackItem(lastPlayedItem, fromPosition: lastPlaybackPosition)
        }
    }
    
    // Whenever a track is played by the player, add an entry in the "Recently played" list
    func trackPlayed(_ notification: TrackTransitionNotification) {
        
        guard let newTrack = notification.endTrack else {return}
        let trackKey = newTrack.file.path
        
        if let existingHistoryItem: TrackHistoryItem = recentlyPlayedItems[trackKey] as? TrackHistoryItem {
            markNewEvent(forItem: existingHistoryItem)
            
        } else {
            recentlyPlayedItems[trackKey] = TrackHistoryItem(track: newTrack, lastEventTime: Date())
        }
        
        messenger.publish(.history_updated)
    }
    
    func fileSystemItemsPlayed(_ notification: LibraryFileSystemItemsPlayedNotification) {
        
        for url in notification.filesAndFolders {
            
            if url.isSupportedPlaylistFile {
                doPlaylistFilePlayed(url)
                
            } else if url.isDirectory {
                doFolderPlayed(url)
            }
        }
        
        messenger.publish(.history_updated)
    }
    
    func doPlaylistFilePlayed(_ playlistFile: URL) {
        
        let playlistFileKey = playlistFile.path
        
        if let existingHistoryItem: PlaylistFileHistoryItem = recentlyPlayedItems[playlistFileKey] as? PlaylistFileHistoryItem {
            markNewEvent(forItem: existingHistoryItem)
            
        } else {
            recentlyPlayedItems[playlistFileKey] = PlaylistFileHistoryItem(playlistFile: playlistFile, lastEventTime: Date())
        }
    }
    
    func groupPlayed(_ notif: LibraryGroupPlayedNotification) {
        doGroupPlayed(notif.group)
    }
    
    private func doGroupPlayed(_ group: Group) {
        
        let groupKey = "\(group.type)_\(group.name)"
        
        if let existingHistoryItem: GroupHistoryItem = recentlyPlayedItems[groupKey] as? GroupHistoryItem {
            markNewEvent(forItem: existingHistoryItem)
            
        } else {
            recentlyPlayedItems[groupKey] = GroupHistoryItem(groupName: group.name, groupType: group.type, lastEventTime: Date())
        }
        
        messenger.publish(.history_updated)
    }
    
    private func doFolderPlayed(_ folder: URL) {
        
        let folderKey = folder.path
        
        if let existingHistoryItem: FolderHistoryItem = recentlyPlayedItems[folderKey] as? FolderHistoryItem {
            markNewEvent(forItem: existingHistoryItem)
            
        } else {
            recentlyPlayedItems[folderKey] = FolderHistoryItem(folder: folder, lastEventTime: Date())
        }
    }
    
    private func markNewEvent(forItem existingHistoryItem: HistoryItem) {
        
        existingHistoryItem.markEvent()
        
        // Move to bottom (i.e. most recent)
        recentlyPlayedItems.removeValue(forKey: existingHistoryItem.key)
        recentlyPlayedItems[existingHistoryItem.key] = existingHistoryItem
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
        
        let recentlyAdded = allRecentlyAddedItems().compactMap {HistoryItemPersistentState(item: $0)}
        let recentlyPlayed = allRecentlyPlayedItems().compactMap {HistoryItemPersistentState(item: $0)}
        
        return HistoryPersistentState(recentlyAdded: recentlyAdded, recentlyPlayed: recentlyPlayed, lastPlaybackPosition: lastPlaybackPosition)
    }
}
