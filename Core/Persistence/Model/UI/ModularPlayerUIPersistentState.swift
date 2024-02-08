//
//  PlayerUIPersistentState.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Foundation

///
/// Persistent state for the Player UI.
///
/// - SeeAlso: `PlayerUIState`
///
struct ModularPlayerUIPersistentState: Codable {
    
    let showAlbumArt: Bool?
    let showArtist: Bool?
    let showAlbum: Bool?
    let showCurrentChapter: Bool?
    
    let showControls: Bool?
    let showTrackTime: Bool?
    
    let trackTimeDisplayType: TrackTimeDisplayType?
    
    init(showAlbumArt: Bool?, showArtist: Bool?, showAlbum: Bool?, showCurrentChapter: Bool?, showControls: Bool?, showTrackTime: Bool?, trackTimeDisplayType: TrackTimeDisplayType?) {
        
        self.showAlbumArt = showAlbumArt
        self.showArtist = showArtist
        self.showAlbum = showAlbum
        self.showCurrentChapter = showCurrentChapter
        self.showControls = showControls
        self.showTrackTime = showTrackTime
        self.trackTimeDisplayType = trackTimeDisplayType
    }
    
    init(legacyPersistentState: LegacyPlayerUIPersistentState?) {
        
        self.showAlbumArt = legacyPersistentState?.showAlbumArt
        self.showArtist = legacyPersistentState?.showArtist
        self.showAlbum = legacyPersistentState?.showAlbum
        self.showCurrentChapter = legacyPersistentState?.showCurrentChapter
        
        self.showControls = legacyPersistentState?.showControls
        self.showTrackTime = legacyPersistentState?.showTimeElapsedRemaining
        
        self.trackTimeDisplayType = nil
    }
}
