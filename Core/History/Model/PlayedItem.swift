//
//  PlayedItem.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  
import Foundation

///
/// Represents an item that was played in the past, i.e. a track.
///
class PlayedItem: HistoryItem {
    
    // TODO: Played item should not just be a track ... it could be a file system folder, a saved playlist, an M3U playlist, or a track.
    
    init(_ track: Track, _ time: Date) {
        
        super.init(track.file, track.displayName, time)
        self.track = track
    }
    
    override init(_ file: URL, _ displayName: String, _ time: Date) {
        super.init(file, displayName, time)
    }
}
