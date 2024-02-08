//
//  TrackHistoryItem.swift
//  Aural-macOS
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import Foundation

class TrackHistoryItem: HistoryItem {
    
    let track: Track
    
    override var displayName: String {
        track.displayName
    }
    
    override var key: String {
        track.file.path
    }
    
    init(track: Track, lastEventTime: Date, eventCount: Int = 1) {
        
        self.track = track
        super.init(lastEventTime: lastEventTime, eventCount: eventCount)
    }
}
