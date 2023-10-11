//
//  UIPersistenceTests.swift
//  Tests
//
//  Copyright © 2023 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  
import Foundation

class UIPersistenceTests: PersistenceTestCase {
    
    func testPersistence() {
        
        for appMode in AppMode.allCases {
            
            for _ in 1...(runLongRunningTests ? 1000 : 100) {
                
                // Window layouts
                
                let layout = randomLayout(name: "_system_", systemDefined: true,
                                          showPlaylist: .random(), showEffects: .random())
                
                let windowLayouts = WindowLayoutsPersistentState(layout: layout, userLayouts: randomUserLayouts())
                
                // Themes
                
                let themes = ThemesPersistentState(userThemes: randomThemes())
                
                // Font schemes
                
                let systemFontScheme = randomFontScheme(named: "_system_")
                let userFontSchemes = randomFontSchemes()
                
                let fontSchemes = FontSchemesPersistentState(systemScheme: systemFontScheme, userSchemes: userFontSchemes)
                
                // Color schemes
                
                let systemColorScheme = randomColorScheme(named: "_system_")
                let userColorSchemes = randomColorSchemes()
                
                let colorSchemes = ColorSchemesPersistentState(systemScheme: systemColorScheme, userSchemes: userColorSchemes)
                
                // Player
                
                let player = PlayerUIPersistentState(viewType: .randomCase(),
                                                     showAlbumArt: .random(),
                                                     showArtist: .random(),
                                                     showAlbum: .random(),
                                                     showCurrentChapter: .random(),
                                                     showTrackInfo: .random(),
                                                     showPlayingTrackFunctions: .random(),
                                                     showControls: .random(),
                                                     showTimeElapsedRemaining: .random(),
                                                     timeElapsedDisplayType: .randomCase(),
                                                     timeRemainingDisplayType: .randomCase())
                
                // Playlist
                
                let playlist = PlaylistUIPersistentState(view: PlaylistType.randomCase().rawValue)
                
                // Visualizer
                
                let vizOptions = VisualizerOptionsPersistentState(lowAmplitudeColor: randomColor(),
                                                                  highAmplitudeColor: randomColor())
                
                let visualizer = VisualizerUIPersistentState(type: .randomCase(),
                                                             options: vizOptions)
                
                // Window appearance
                
                let windowAppearance = WindowAppearancePersistentState(cornerRadius: CGFloat.random(in: 0...25))
                
                // Menu Bar Player
                
                let menuBarPlayer = MenuBarPlayerUIPersistentState(showAlbumArt: .random(),
                                                                   showArtist: .random(),
                                                                   showAlbum: .random(),
                                                                   showCurrentChapter: .random())
                
                // Control Bar Player
                
                let controlBarPlayer = ControlBarPlayerUIPersistentState(windowFrame: NSRectPersistentState(rect: randomControlBarPlayerWindowFrame()),
                                                                         cornerRadius: CGFloat.random(in: 0...20),
                                                                         trackInfoScrollingEnabled: .random(),
                                                                         showSeekPosition: .random(),
                                                                         seekPositionDisplayType: .randomCase())
                
                let state = UIPersistentState(appMode: appMode,
                                              windowLayout: windowLayouts,
                                              themes: themes,
                                              fontSchemes: fontSchemes,
                                              colorSchemes: colorSchemes,
                                              player: player,
                                              playlist: playlist,
                                              visualizer: visualizer,
                                              windowAppearance: windowAppearance,
                                              menuBarPlayer: menuBarPlayer,
                                              controlBarPlayer: controlBarPlayer)
                
                doTestPersistence(serializedState: state)
            }
        }
    }
}

// MARK: Equality comparison for model objects -----------------------------

extension UIPersistentState: Equatable {
    
    static func == (lhs: UIPersistentState, rhs: UIPersistentState) -> Bool {
        
        lhs.appMode == rhs.appMode &&
            lhs.colorSchemes == rhs.colorSchemes &&
            lhs.controlBarPlayer == rhs.controlBarPlayer &&
            lhs.fontSchemes == rhs.fontSchemes &&
            lhs.menuBarPlayer == rhs.menuBarPlayer &&
            lhs.player == rhs.player &&
            lhs.playlist == rhs.playlist &&
            lhs.themes == rhs.themes &&
            lhs.visualizer == rhs.visualizer &&
            lhs.windowAppearance == rhs.windowAppearance &&
            lhs.windowLayout == rhs.windowLayout
    }
}
