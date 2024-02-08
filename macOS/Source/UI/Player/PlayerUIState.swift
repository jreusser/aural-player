//
//  PlayerUIState.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Foundation

// Convenient accessor for the current state of the player UI
class PlayerUIState {
    
    // Settings for individual track metadata fields
    
    var showAlbumArt: Bool
    var showArtist: Bool
    var showAlbum: Bool
    var showCurrentChapter: Bool
    
    var showControls: Bool
    var showTrackTime: Bool
    
    var trackTimeDisplayType: TrackTimeDisplayType
    
    init(persistentState: ModularPlayerUIPersistentState?) {
        
        showAlbumArt = persistentState?.showAlbumArt ?? PlayerUIDefaults.showAlbumArt
        showArtist = persistentState?.showArtist ?? PlayerUIDefaults.showArtist
        showAlbum = persistentState?.showAlbum ?? PlayerUIDefaults.showAlbum
        showCurrentChapter = persistentState?.showCurrentChapter ?? PlayerUIDefaults.showCurrentChapter
        
        showControls = persistentState?.showControls ?? PlayerUIDefaults.showControls
        showTrackTime = persistentState?.showTrackTime ?? PlayerUIDefaults.showTrackTime
        
        trackTimeDisplayType = persistentState?.trackTimeDisplayType ?? PlayerUIDefaults.trackTimeDisplayType
    }
    
    var persistentState: ModularPlayerUIPersistentState {
        
        ModularPlayerUIPersistentState(showAlbumArt: showAlbumArt,
                                showArtist: showArtist,
                                showAlbum: showAlbum,
                                showCurrentChapter: showCurrentChapter,
                                showControls: showControls,
                                showTrackTime: showTrackTime,
                                trackTimeDisplayType: trackTimeDisplayType)
    }
}

struct PlayerUIDefaults {
    
    static let showAlbumArt: Bool = true
    static let showArtist: Bool = true
    static let showAlbum: Bool = true
    static let showCurrentChapter: Bool = true
    
    static let showControls: Bool = true
    static let showTrackTime: Bool = true
    
    static let trackTimeDisplayType: TrackTimeDisplayType = .elapsed
}
