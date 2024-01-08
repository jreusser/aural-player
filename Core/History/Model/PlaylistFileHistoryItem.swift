//
//  PlaylistFileHistoryItem.swift
//  Aural-macOS
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import Foundation

class PlaylistFileHistoryItem: HistoryItem {
    
    let playlistFile: URL
    
    override var displayName: String {
        playlistFile.lastPathComponents(count: 2)
    }
    
    override var key: String {
        playlistFile.path
    }
    
    init(playlistFile: URL, lastEventTime: Date, eventCount: Int = 1) {
        
        self.playlistFile = playlistFile
        super.init(lastEventTime: lastEventTime, eventCount: eventCount)
    }
    
    override func equals(other: HistoryItem) -> Bool {
        
        guard let otherPlaylistFile = other as? PlaylistFileHistoryItem else {return false}
        return self.playlistFile == otherPlaylistFile.playlistFile
    }
}
