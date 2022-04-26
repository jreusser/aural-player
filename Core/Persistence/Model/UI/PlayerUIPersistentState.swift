//
//  PlayerUIPersistentState.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
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
struct PlayerUIPersistentState: Codable {
    
    let showAlbumArt: Bool?
    let showArtist: Bool?
    let showAlbum: Bool?
    let showCurrentChapter: Bool?
    
    let showControls: Bool?
    let showTrackTime: Bool?
    
    let trackTimeDisplayType: TrackTimeDisplayType?
}
