//
//  UIPersistentState.swift
//  Aural
//
//  Copyright © 2023 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Foundation

#if os(macOS)

///
/// Encapsulates all persistent state for the application UI.
///
struct UIPersistentState: Codable {
    
    let appMode: AppMode?
    
    let player: PlayerUIPersistentState?
    let playQueue: PlayQueueUIPersistentState?
//    let playlist: PlaylistUIPersistentState?
    

    
    let windowLayout: WindowLayoutsPersistentState?
    let themes: ThemesPersistentState?
    let fontSchemes: FontSchemesPersistentState?
    let colorSchemes: ColorSchemesPersistentState?
    
    let visualizer: VisualizerUIPersistentState?
    let windowAppearance: WindowAppearancePersistentState?
    let tuneBrowser: TuneBrowserUIPersistentState?
    
    let menuBarPlayer: MenuBarPlayerUIPersistentState?
    let controlBarPlayer: ControlBarPlayerUIPersistentState?
}

#endif
