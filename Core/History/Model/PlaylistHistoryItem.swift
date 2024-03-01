//
//  PlaylistHistoryItem.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import Foundation

///
/// Managed Playlist (not Imported Playlist)
///
class PlaylistHistoryItem: HistoryItem {
    
    let playlistName: String
    
    override var displayName: String {
        playlistName
    }
    
    override var key: String {
        playlistName
    }
    
    init(playlistName: String, lastEventTime: Date, eventCount: Int = 1) {
        
        self.playlistName = playlistName
        super.init(lastEventTime: lastEventTime, eventCount: eventCount)
    }
}
