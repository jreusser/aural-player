//
//  Images.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
/*
    Container for images used by the UI
*/
struct Images {
    
    static let imgPlaylist: PlatformImage = PlatformImage(systemSymbolName: "list.dash", accessibilityDescription: nil)!
    static let imgPlayQueue: PlatformImage = PlatformImage(systemSymbolName: "music.note.list", accessibilityDescription: nil)!
    static let imgEffects: PlatformImage = PlatformImage(systemSymbolName: "slider.vertical.3", accessibilityDescription: nil)!
    
    static let imgPlay: PlatformImage = PlatformImage(systemSymbolName: "play", accessibilityDescription: nil)!
    static let imgPause: PlatformImage = PlatformImage(systemSymbolName: "pause", accessibilityDescription: nil)!
    
    static let imgPlayingArt: PlatformImage = PlatformImage(named: "PlayingArt")!
    
    static let imgPlayingTrack: PlatformImage = PlatformImage(named: "PlayingTrack")!
    
    static let imgFavorite: PlatformImage = PlatformImage(systemSymbolName: "heart", accessibilityDescription: nil)!
    
    static let imgVolumeZero: PlatformImage = PlatformImage(systemSymbolName: "volume", accessibilityDescription: nil)!
    static let imgVolumeLow: PlatformImage = PlatformImage(systemSymbolName: "volume.1", accessibilityDescription: nil)!
    static let imgVolumeMedium: PlatformImage = PlatformImage(systemSymbolName: "volume.2", accessibilityDescription: nil)!
    static let imgVolumeHigh: PlatformImage = PlatformImage(systemSymbolName: "volume.3", accessibilityDescription: nil)!
    static let imgMute: PlatformImage = PlatformImage(systemSymbolName: "volume.slash", accessibilityDescription: nil)!
    
    static let imgRepeatOne: PlatformImage = PlatformImage(systemSymbolName: "repeat.1", accessibilityDescription: nil)!
    static let imgRepeat: PlatformImage = PlatformImage(systemSymbolName: "repeat", accessibilityDescription: nil)!
    
    static let imgShuffle: PlatformImage = PlatformImage(systemSymbolName: "shuffle", accessibilityDescription: nil)!
    
    static let imgLoop: PlatformImage = PlatformImage(named: "Loop")!
    static let imgLoopStarted: PlatformImage = PlatformImage(named: "LoopStarted")!
    
    static let imgSwitch: PlatformImage = PlatformImage(named: "Switch")!
    
    static let imgHistory_playlist_padded: PlatformImage = PlatformImage(named: "History_PaddedPlaylist")!
    
    // Displayed in the playlist view
    static let imgGroup: PlatformImage = PlatformImage(named: "Group")!
    
    // Displayed in the History menu
    static let imgGroup_menu: PlatformImage = PlatformImage(named: "Group-Menu")!
    
    // Images displayed in alerts
    static let imgWarning: PlatformImage = PlatformImage(named: "Warning")!
    static let imgError: PlatformImage = PlatformImage(named: "Error")!
    
    static let imgPlayedTrack: PlatformImage = PlatformImage(named: "PlayedTrack")!
    
    static let imgPlayerPreview: PlatformImage = PlatformImage(named: "PlayerPreview")!
    static let imgPlaylistPreview: PlatformImage = PlatformImage(named: "PlaylistView-On")!
    static let imgEffectsPreview: PlatformImage = PlatformImage(named: "EffectsView-On")!
    
    static let imgDisclosure_collapsed: PlatformImage = PlatformImage(named: "DisclosureTriangle-Collapsed")!
    static let imgDisclosure_expanded: PlatformImage = PlatformImage(named: "DisclosureTriangle-Expanded")!
}
