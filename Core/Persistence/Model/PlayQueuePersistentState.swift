//
//  PlayQueuePersistentState.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import Foundation

struct PlayQueuePersistentState: Codable {
    
    let tracks: [URL]?
    
    let repeatMode: RepeatMode?
    let shuffleMode: ShuffleMode?
    
    init(playQueue: PlayQueue) {
        
        self.tracks = playQueue.tracks.map {$0.file}
        self.repeatMode = playQueue.repeatMode
        self.shuffleMode = playQueue.shuffleMode
    }
}
