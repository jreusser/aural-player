//
//  TrackHistoryItem.swift
//  Aural-macOS
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
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
        track.file.absoluteString
    }
    
    init(track: Track, lastEventTime: Date, eventCount: Int = 1) {
        
        self.track = track
        super.init(lastEventTime: lastEventTime, eventCount: eventCount)
    }
    
    override func equals(other: HistoryItem) -> Bool {
        
        guard let otherTrack = other as? TrackHistoryItem else {return false}
        return self.track.file == otherTrack.track.file
    }
}
