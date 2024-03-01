//
//  HistoryDelegateProtocol.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Foundation

///
/// A functional contract for a delegate allowing access to the chronologically ordered track lists:
/// 1. tracks recently added to the playlist
/// 2. tracks recently played
///
/// Acts as a middleman between the UI and the History lists,
/// providing a simplified interface / facade for the UI layer to manipulate the History lists
/// and add / play tracks from those lists.
///
/// - SeeAlso: `AddedItem`
/// - SeeAlso: `PlayedItem`
///
protocol HistoryDelegateProtocol {
    
    func initialize(fromPersistentState persistentState: HistoryPersistentState?)
    
    // Retrieves all items from the Recently added list, in chronological order
    var allRecentlyAddedItems: [HistoryItem] {get}
    
    // Retrieves all recently played items
    var allRecentlyPlayedItems: [HistoryItem] {get}
    
    // Adds a given item (file/folder) to the playlist
    func addItem(_ item: URL) throws
    
    // Plays a given item.
    func playItem(_ item: HistoryItem)
    
    func resizeLists(_ recentlyAddedListSize: Int, _ recentlyPlayedListSize: Int)
    
    func clearAllHistory()
    
    func deleteItem(_ item: HistoryItem)
    
    func markLastPlaybackPosition(_ position: Double)
    
    var lastPlaybackPosition: Double {get}
    
    var lastPlayedItem: TrackHistoryItem? {get}
    
    func resumeLastPlayedTrack() throws
    
    // TODO: getPlayStats(), getAddStats()
    
    func noteAddedItems(tracks: [Track])
    
    func noteAddedItems(groups: [Group], tracks: [Track])
    
    // Library (playlist files)
    func noteAddedItems(playlistFiles: [ImportedPlaylist], tracks: [Track])
    
    // Tune Browser
    func noteAddedItems(folders: [FileSystemFolderItem], tracks: [FileSystemTrackItem], playlistFiles: [FileSystemPlaylistItem])
    
    func noteAddedItems(playlist: Playlist)
}
