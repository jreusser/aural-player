//
//  HistoryItem.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  
import Foundation

///
/// Represents an item that was played in the past, i.e. a track.
///
class HistoryItem {
    
    var lastEventTime: Date
    var eventCount: Int
    
    // Override this!
    var displayName: String {
        "HistoryItem"
    }
    
    // Override this!
    var key: String {
        "HistoryItem"
    }
    
    init(lastEventTime: Date, eventCount: Int) {
        
        self.lastEventTime = lastEventTime
        self.eventCount = eventCount
    }
    
    func markEvent() {
        
        lastEventTime = Date()
        eventCount.increment()
    }
}
