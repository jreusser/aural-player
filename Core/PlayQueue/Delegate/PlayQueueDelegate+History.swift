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
    
    // MARK: Event handling for Tracks ---------------------------------------------------------------
    
    func itemsLoadedFromFileSystem(notif: HistoryItemsAddedNotification) {
        
        for url in notif.items {
            
            if url.isSupportedAudioFile {
                
                if let track = self.findTrack(forFile: url) {
                    markEventForTrack(track)
                }
                
            } else if url.isDirectory {
                markEventForFolder(url)
                
            } else if url.isSupportedPlaylistFile {
                markEventForPlaylistFile(url)
            }
        }
    }
    
    // Whenever a track is played by the player, add an entry in the "Recently played" list
    func trackPlayed(_ notification: TrackTransitionNotification) {
        
        if let newTrack = notification.endTrack {
            
            markEventForTrack(newTrack)
            messenger.publish(.History.updated)
        }
    }
    
    func tracksEnqueued(_ tracks: [Track]) {
        
        for track in tracks {
            markEventForTrack(track)
        }
        
        messenger.publish(.History.updated)
    }
    
    fileprivate func markEventForTrack(_ track: Track) {
        
        let trackKey = TrackHistoryItem.key(forTrack: track)
        
        if let existingHistoryItem: TrackHistoryItem = recentItems[trackKey] as? TrackHistoryItem {
            markNewEvent(forItem: existingHistoryItem)
            
        } else {
            recentItems[trackKey] = TrackHistoryItem(track: track, lastEventTime: Date())
        }
    }
    
    // MARK: Event handling for FileSystemItems ---------------------------------------------------------------
    
    func fileSystemItemsEnqueued(_ fileSystemItems: [FileSystemItem]) {
        
        for fileSystemItem in fileSystemItems {
            
            if fileSystemItem.isTrack, let trackItem = fileSystemItem as? FileSystemTrackItem {
                markEventForTrack(trackItem.track)
                
            } else if fileSystemItem.isDirectory {
                markEventForFolder(fileSystemItem.url)
                
            } else {
                markEventForPlaylistFile(fileSystemItem.url)
            }
        }
        
        messenger.publish(.History.updated)
    }
    
    fileprivate func markEventForFolder(_ folder: URL) {
        
        let folderKey = FolderHistoryItem.key(forFolder: folder)
        
        if let existingHistoryItem: FolderHistoryItem = recentItems[folderKey] as? FolderHistoryItem {
            markNewEvent(forItem: existingHistoryItem)
            
        } else {
            recentItems[folderKey] = FolderHistoryItem(folder: folder, lastEventTime: Date())
        }
    }
    
    func playlistFilesAndTracksEnqueued(playlistFiles: [ImportedPlaylist], tracks: [Track]) {
        
        let deDupedTracks: [Track] = tracks.filter {track in
            !playlistFiles.contains(where: {$0.hasTrack(forFile: track.file)})
        }
        
        for playlistFile in playlistFiles {
            markEventForPlaylistFile(playlistFile.file)
        }
        
        tracksEnqueued(deDupedTracks)
        
        messenger.publish(.History.updated)
    }
    
    fileprivate func markEventForPlaylistFile(_ playlistFile: URL) {
        
        let playlistFileKey = PlaylistFileHistoryItem.key(forPlaylistFile: playlistFile)
        
        if let existingHistoryItem: PlaylistFileHistoryItem = recentItems[playlistFileKey] as? PlaylistFileHistoryItem {
            markNewEvent(forItem: existingHistoryItem)
            
        } else {
            recentItems[playlistFileKey] = PlaylistFileHistoryItem(playlistFile: playlistFile, lastEventTime: Date())
        }
    }
    
    // MARK: Event handling for Groups ---------------------------------------------------------------
    
    func groupsAndTracksEnqueued(groups: [Group], tracks: [Track]) {
        
        let deDupedTracks: [Track] = tracks.filter {track in
            !groups.contains(where: {$0.hasTrack(forFile: track.file)})
        }
        
        for group in groups {
            markEventForGroup(group)
        }
        
        tracksEnqueued(deDupedTracks)
        
        messenger.publish(.History.updated)
    }
    
    fileprivate func markEventForGroup(_ group: Group) {
        
        let groupKey = GroupHistoryItem.key(forGroupName: group.name, andType: group.type)
        
        if let existingHistoryItem: GroupHistoryItem = recentItems[groupKey] as? GroupHistoryItem {
            markNewEvent(forItem: existingHistoryItem)
            
        } else {
            recentItems[groupKey] = GroupHistoryItem(groupName: group.name, groupType: group.type, lastEventTime: Date())
        }
    }
    
    // MARK: Event handling for Playlists ---------------------------------------------------------------
    
    func playlistEnqueued(_ playlist: Playlist) {
        
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
        
        // TODO: Augment enqueueToPlayNow() with a PlaybackParams parm so you can pass in position.
        // Add it to the PQ
        enqueueToPlayLater(tracks: [trackHistoryItem.track])
        
        if let seekPosition = position {
            playbackDelegate.play(track: trackHistoryItem.track, PlaybackParams().withStartAndEndPosition(seekPosition))
        } else {
            playbackDelegate.play(track: trackHistoryItem.track)
        }
    }
    
    private func playPlaylistFileItem(_ playlistFileHistoryItem: PlaylistFileHistoryItem) {
        
        // Add it to the PQ
        if let importedPlaylist = libraryDelegate.findImportedPlaylist(atLocation: playlistFileHistoryItem.playlistFile) {
            enqueueToPlayNow(playlistFile: importedPlaylist, clearQueue: false)
            
        } else {
            loadTracks(from: [playlistFileHistoryItem.playlistFile], params: .init(autoplay: true))
        }
    }
    
    private func playGroupItem(_ groupHistoryItem: GroupHistoryItem) {
        
        guard let group = libraryDelegate.findGroup(named: groupHistoryItem.groupName, ofType: groupHistoryItem.groupType) else {return}
        enqueueToPlayNow(group: group, clearQueue: false)
    }
    
    private func playFolderItem(_ folderHistoryItem: FolderHistoryItem) {
        
        let folder = folderHistoryItem.folder
        
        if let fsFolderItem = libraryDelegate.findFileSystemFolder(atLocation: folder) {
            enqueueToPlayNow(fileSystemItems: [fsFolderItem], clearQueue: false)
            
        } else {
            loadTracks(from: [folder], params: .init(autoplay: true))
        }
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
