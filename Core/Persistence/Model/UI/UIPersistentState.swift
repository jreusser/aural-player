//
//  UIPersistentState.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
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
    
    let windowLayout: WindowLayoutsPersistentState?
    let themes: ThemesPersistentState?
    let fontSchemes: FontSchemesPersistentState?
    let colorSchemes: ColorSchemesPersistentState?
    let windowAppearance: WindowAppearancePersistentState?
    
    let modularPlayer: ModularPlayerUIPersistentState?
    let unifiedPlayer: UnifiedPlayerUIPersistentState?
    let menuBarPlayer: MenuBarPlayerUIPersistentState?
    let controlBarPlayer: ControlBarPlayerUIPersistentState?
    
    let playQueue: PlayQueueUIPersistentState?
    let visualizer: VisualizerUIPersistentState?
    let tuneBrowser: TuneBrowserUIPersistentState?
    
    init(appMode: AppMode?, windowLayout: WindowLayoutsPersistentState?, themes: ThemesPersistentState?, fontSchemes: FontSchemesPersistentState?, colorSchemes: ColorSchemesPersistentState?, windowAppearance: WindowAppearancePersistentState?, modularPlayer: ModularPlayerUIPersistentState?, unifiedPlayer: UnifiedPlayerUIPersistentState?, menuBarPlayer: MenuBarPlayerUIPersistentState?, controlBarPlayer: ControlBarPlayerUIPersistentState?, playQueue: PlayQueueUIPersistentState?, visualizer: VisualizerUIPersistentState?, tuneBrowser: TuneBrowserUIPersistentState?) {
        
        self.appMode = appMode
        self.windowLayout = windowLayout
        self.themes = themes
        self.fontSchemes = fontSchemes
        self.colorSchemes = colorSchemes
        self.windowAppearance = windowAppearance
        self.modularPlayer = modularPlayer
        self.unifiedPlayer = unifiedPlayer
        self.menuBarPlayer = menuBarPlayer
        self.controlBarPlayer = controlBarPlayer
        self.playQueue = playQueue
        self.visualizer = visualizer
        self.tuneBrowser = tuneBrowser
    }
    
    init(legacyPersistentState: LegacyUIPersistentState?) {
        
        self.appMode = AppMode.fromLegacyAppMode(legacyPersistentState?.appMode)
        
        self.windowLayout = nil
        self.themes = nil
        self.fontSchemes = nil
        self.colorSchemes = .init(legacyPersistentState: legacyPersistentState?.colorSchemes)
        self.windowAppearance = .init(legacyPersistentState: legacyPersistentState?.windowAppearance)
        
        self.modularPlayer = ModularPlayerUIPersistentState(legacyPersistentState: legacyPersistentState?.player)
        self.unifiedPlayer = nil
        self.menuBarPlayer = nil
        self.controlBarPlayer = nil
        
        self.playQueue = nil
        self.visualizer = nil
        self.tuneBrowser = nil
    }
}

#endif
