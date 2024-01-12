//
//  FavoriteTrack.swift
//  Aural-macOS
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import Foundation

class FavoriteTrack: Favorite {
    
    let track: Track
    
    override var key: String {
        track.file.path
    }
    
    init(track: Track) {
        
        self.track = track
        super.init(name: track.displayName)
    }
}
