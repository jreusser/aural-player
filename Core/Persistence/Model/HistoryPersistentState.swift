//
//  HistoryPersistentState.swift
//  Aural
//
//  Copyright © 2023 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Foundation

///
/// Persistent state for the **History** lists
/// (recently added and recently played).
///
/// - SeeAlso: `AddedItem`
/// - SeeAlso: `PlayedItem`
///
struct HistoryPersistentState: Codable {
    
    let recentlyAdded: [HistoryItemPersistentState]?
    let recentlyPlayed: [HistoryItemPersistentState]?
    let lastPlaybackPosition: Double?
}

enum HistoryPersistentItemType: String, Codable {
    
    case track
    case playlistFile
    case folder
    case group
}

///
/// Persistent state for a single item in the **History** lists
/// (recently added and recently played).
///
/// - SeeAlso: `AddedItem`
/// - SeeAlso: `PlayedItem`
///
struct HistoryItemPersistentState: Codable {
    
    let itemType: HistoryPersistentItemType?
    let lastEventTime: Date?
    let eventCount: Int?
    
    var trackFile: URL? = nil
    
    var playlistFile: URL? = nil
    
    var folder: URL? = nil
    
    var groupName: String? = nil
    var groupType: GroupType? = nil
    
    
    init?(item: HistoryItem) {
        
        self.lastEventTime = item.lastEventTime
        self.eventCount = item.eventCount
        
        if let trackHistoryItem = item as? TrackHistoryItem {
            
            self.itemType = .track
            self.trackFile = trackHistoryItem.track.file
            
            return
        }
        
        if let playlistFileHistoryItem = item as? PlaylistFileHistoryItem {
            
            self.itemType = .playlistFile
            self.playlistFile = playlistFileHistoryItem.playlistFile
            
            return
        }
        
        if let folderHistoryItem = item as? FolderHistoryItem {
            
            self.itemType = .folder
            self.folder = folderHistoryItem.folder
            
            return
        }
        
        if let groupHistoryItem = item as? GroupHistoryItem {
            
            self.itemType = .group
            self.groupName = groupHistoryItem.groupName
            self.groupType = groupHistoryItem.groupType
            
            return
        }
        
        return nil
    }
}
