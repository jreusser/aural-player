//
//  PlaybackProfilePersistentState.swift
//  Aural
//
//  Copyright © 2023 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Foundation

///
/// Persistent state for a single playback profile.
///
/// - SeeAlso:  `PlaybackProfile`
///
struct PlaybackProfilePersistentState: Codable {
    
    let file: URL?
    let lastPosition: Double?
    
    init(file: URL?, lastPosition: Double?) {
        
        self.file = file
        self.lastPosition = lastPosition
    }
    
    init(profile: PlaybackProfile) {
        
        self.file = profile.file
        self.lastPosition = profile.lastPosition
    }
}
