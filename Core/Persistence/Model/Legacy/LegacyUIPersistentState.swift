//
//  LegacyUIPersistentState.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import Foundation

struct LegacyUIPersistentState: Codable {
    
    let appMode: LegacyAppMode?
    
//    let windowLayout: WindowLayoutsPersistentState?
//    let themes: ThemesPersistentState?
//    let fontSchemes: FontSchemesPersistentState?
//    let colorSchemes: ColorSchemesPersistentState?
    let windowAppearance: WindowAppearancePersistentState?
    
    let player: LegacyPlayerUIPersistentState?
//    let menuBarPlayer: MenuBarPlayerUIPersistentState?
//    let controlBarPlayer: ControlBarPlayerUIPersistentState?
//    
//    let playlist: PlaylistUIPersistentState?
//    let visualizer: VisualizerUIPersistentState?
}

enum LegacyAppMode: String, CaseIterable, Codable {
    
    case windowed
    case menuBar
    case controlBar
}

struct LegacyPlayerUIPersistentState: Codable {
    
    let showAlbumArt: Bool?
    let showArtist: Bool?
    let showAlbum: Bool?
    let showCurrentChapter: Bool?
    
    let showControls: Bool?
    let showTimeElapsedRemaining: Bool?
}
