//
//  PlayQueueDelegate+History.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import Foundation

extension PlayQueueDelegate {
    
    var allRecentItems: [HistoryItem] {
        
        // Reverse the array for chronological order (most recent items first).
        recentItems.values.reversed()
    }
    
    func appWillExit() {
        
        if playbackInfoDelegate.state == .stopped {return}
        
        let playerPosition = playbackInfoDelegate.seekPosition.timeElapsed
        
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
        
        if let newTrack = notification.endTrack {
            
            doTrackPlayed(newTrack)
            messenger.publish(.history_updated)
        }
    }
    
    func tracksPlayed(_ tracks: [Track]) {
        
        for track in tracks {
            doTrackPlayed(track)
        }
        
        messenger.publish(.history_updated)
    }
    
    func doTrackPlayed(_ track: Track) {
        
        let trackKey = TrackHistoryItem.key(forTrack: track)
        
        if let existingHistoryItem: TrackHistoryItem = recentItems[trackKey] as? TrackHistoryItem {
            markNewEvent(forItem: existingHistoryItem)
            
        } else {
            recentItems[trackKey] = TrackHistoryItem(track: track, lastEventTime: Date())
        }
    }
    
    func fileSystemItemsPlayed(_ fileSystemItems: [FileSystemItem]) {
        
        for fileSystemItem in fileSystemItems {
            
            if fileSystemItem.isTrack, let trackItem = fileSystemItem as? FileSystemTrackItem {
                doTrackPlayed(trackItem.track)
                
            } else if fileSystemItem.isDirectory {
                doFolderPlayed(fileSystemItem.url)
                
            } else {
                doPlaylistFilePlayed(fileSystemItem.url)
            }
        }
        
        messenger.publish(.history_updated)
    }
    
    func playlistFilesAndTracksPlayed(playlistFiles: [ImportedPlaylist], tracks: [Track]) {
        
        let deDupedTracks: [Track] = tracks.filter {track in
            !playlistFiles.contains(where: {$0.hasTrack(forFile: track.file)})
        }
        
        for playlistFile in playlistFiles {
            doPlaylistFilePlayed(playlistFile.file)
        }
        
        tracksPlayed(deDupedTracks)
        
        messenger.publish(.history_updated)
    }
    
    func doPlaylistFilePlayed(_ playlistFile: URL) {
        
        let playlistFileKey = PlaylistFileHistoryItem.key(forPlaylistFile: playlistFile)
        
        if let existingHistoryItem: PlaylistFileHistoryItem = recentItems[playlistFileKey] as? PlaylistFileHistoryItem {
            markNewEvent(forItem: existingHistoryItem)
            
        } else {
            recentItems[playlistFileKey] = PlaylistFileHistoryItem(playlistFile: playlistFile, lastEventTime: Date())
        }
    }
    
    func groupsAndTracksPlayed(groups: [Group], tracks: [Track]) {
        
        let deDupedTracks: [Track] = tracks.filter {track in
            !groups.contains(where: {$0.hasTrack(forFile: track.file)})
        }
        
        for group in groups {
            doGroupPlayed(group)
        }
        
        tracksPlayed(deDupedTracks)
        
        messenger.publish(.history_updated)
    }
    
    private func doGroupPlayed(_ group: Group) {
        
        let groupKey = GroupHistoryItem.key(forGroupName: group.name, andType: group.type)
        
        if let existingHistoryItem: GroupHistoryItem = recentItems[groupKey] as? GroupHistoryItem {
            markNewEvent(forItem: existingHistoryItem)
            
        } else {
            recentItems[groupKey] = GroupHistoryItem(groupName: group.name, groupType: group.type, lastEventTime: Date())
        }
    }
    
    private func doFolderPlayed(_ folder: URL) {
        
        let folderKey = FolderHistoryItem.key(forFolder: folder)
        
        if let existingHistoryItem: FolderHistoryItem = recentItems[folderKey] as? FolderHistoryItem {
            markNewEvent(forItem: existingHistoryItem)
            
        } else {
            recentItems[folderKey] = FolderHistoryItem(folder: folder, lastEventTime: Date())
        }
    }
    
    func playlistPlayed(_ playlist: Playlist) {
        
        let playlistKey = PlaylistHistoryItem.key(forPlaylistNamed: playlist.name)
        
        if let existingHistoryItem: PlaylistHistoryItem = recentItems[playlistKey] as? PlaylistHistoryItem {
            markNewEvent(forItem: existingHistoryItem)
            
        } else {
            recentItems[playlistKey] = PlaylistHistoryItem(playlistName: playlist.name, lastEventTime: Date())
        }
    }
    
    private func markNewEvent(forItem existingHistoryItem: HistoryItem) {
        
        existingHistoryItem.markEvent()
        
        // Move to bottom (i.e. most recent)
        recentItems.removeValue(forKey: existingHistoryItem.key)
        recentItems[existingHistoryItem.key] = existingHistoryItem
    }
    
    // MARK: Playback of items ---------------------------------------------------------------------------------------------------------
    
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
            playbackDelegate.play(track: trackHistoryItem.track, PlaybackParams().withStartAndEndPosition(seekPosition))
        } else {
            playbackDelegate.play(track: trackHistoryItem.track)
        }
    }
    
    private func playPlaylistFileItem(_ playlistFileHistoryItem: PlaylistFileHistoryItem) {
        
        doPlaylistFilePlayed(playlistFileHistoryItem.playlistFile)
        
        // Add it to the PQ
        if let importedPlaylist = libraryDelegate.findImportedPlaylist(atLocation: playlistFileHistoryItem.playlistFile) {
            playQueueDelegate.enqueueToPlayNow(playlistFile: importedPlaylist, clearQueue: false)
        } else {
            playQueueDelegate.loadTracks(from: [playlistFileHistoryItem.playlistFile], autoplay: true)
        }
    }
    
    private func playGroupItem(_ groupHistoryItem: GroupHistoryItem) {
        
        guard let group = libraryDelegate.findGroup(named: groupHistoryItem.groupName, ofType: groupHistoryItem.groupType) else {return}
        
        doGroupPlayed(group)
        playQueueDelegate.enqueueToPlayNow(group: group, clearQueue: false)
    }
    
    private func playFolderItem(_ folderHistoryItem: FolderHistoryItem) {
        
        let folder = folderHistoryItem.folder
        
        doFolderPlayed(folder)
        messenger.publish(LoadAndPlayNowCommand(files: [folder], clearPlayQueue: false))
    }
    
    func markLastPlaybackPosition(_ position: Double) {
        self.lastPlaybackPosition = position
    }
    
    // MARK: Management of history (cleanup, resizing) ---------------------------------------------------------------------------------------------------------
    
    func deleteItem(_ item: HistoryItem) {
//        recentlyPlayedItems.remove(item)
    }
    
    func resizeList(_ listSize: Int) {
        
//        recentlyPlayedItems.resize(recentlyPlayedListSize)
//        messenger.publish(.history_updated)
    }
    
    func clearAllHistory() {
        recentItems.removeAll()
    }
}
