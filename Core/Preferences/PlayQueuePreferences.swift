//
//  PlayQueuePreferences.swift
//  Aural
//
//  Copyright © 2023 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

///
/// Encapsulates all user preferences pertaining to the Play Queue.
///
class PlayQueuePreferences: PersistentPreferencesProtocol {
    
    var playQueueOnStartup: PlayQueueStartupOption
    
    // This will be used only when playQueueOnStartup == PlayQueueStartupOption.loadFile
    var playlistFile: URL?
    
    // This will be used only when playQueueOnStartup == PlayQueueStartupOption.loadFolder
    var tracksFolder: URL?
    
    var showNewTrackInPlayQueue: Bool
    var showChaptersList: Bool
    
    var dragDropAddMode: PlayQueueTracksAddMode
    var openWithAddMode: PlayQueueTracksAddMode
    
    // ------ MARK: Property keys ---------
    
    private static let keyPrefix: String = "playQueue"
    
    static let key_playQueueOnStartup: String = "\(keyPrefix).playQueueOnStartup"
    static let key_playlistFile: String = "\(keyPrefix).playQueueOnStartup.playlistFile"
    static let key_tracksFolder: String = "\(keyPrefix).playQueueOnStartup.tracksFolder"
    
    static let key_showNewTrackInPlayQueue: String = "\(keyPrefix).showNewTrackInPlayQueue"
    static let key_showChaptersList: String = "\(keyPrefix).showChaptersList"
    
    static let key_dragDropAddMode: String = "\(keyPrefix).dragDropAddMode"
    static let key_openWithAddMode: String = "\(keyPrefix).openWithAddMode"
    
    private typealias Defaults = PreferencesDefaults.PlayQueue
    
    internal required init(_ dict: [String: Any]) {
        
        playQueueOnStartup = dict.enumValue(forKey: Self.key_playQueueOnStartup, ofType: PlayQueueStartupOption.self) ?? Defaults.playQueueOnStartup
        
        playlistFile = dict.urlValue(forKey: Self.key_playlistFile) ?? Defaults.playlistFile
        
        showNewTrackInPlayQueue = dict[Self.key_showNewTrackInPlayQueue, Bool.self] ?? Defaults.showNewTrackInPlayQueue
        
        showChaptersList = dict[Self.key_showChaptersList, Bool.self] ?? Defaults.showChaptersList
        
        // If .loadFile selected but no file available to load from, revert back to dict
        if playQueueOnStartup == .loadFile && playlistFile == nil {
            
            playQueueOnStartup = Defaults.playQueueOnStartup
            playlistFile = Defaults.playlistFile
        }
        
        tracksFolder = dict.urlValue(forKey: Self.key_tracksFolder) ?? Defaults.tracksFolder
        
        // If .loadFolder selected but no folder available to load from, revert back to dict
        if playQueueOnStartup == .loadFolder && tracksFolder == nil {
            
            playQueueOnStartup = Defaults.playQueueOnStartup
            tracksFolder = Defaults.tracksFolder
        }
        
        dragDropAddMode = dict.enumValue(forKey: Self.key_dragDropAddMode, ofType: PlayQueueTracksAddMode.self) ?? Defaults.dragDropAddMode
        openWithAddMode = dict.enumValue(forKey: Self.key_openWithAddMode, ofType: PlayQueueTracksAddMode.self) ?? Defaults.openWithAddMode
    }
    
    func persist(to defaults: UserDefaults) {
        
        defaults[Self.key_playQueueOnStartup] = playQueueOnStartup.rawValue
        defaults[Self.key_playlistFile] = playlistFile?.path
        defaults[Self.key_tracksFolder] = tracksFolder?.path
        
        defaults[Self.key_showNewTrackInPlayQueue] = showNewTrackInPlayQueue
        defaults[Self.key_showChaptersList] = showChaptersList
        
        defaults[Self.key_dragDropAddMode] = dragDropAddMode.rawValue
        defaults[Self.key_openWithAddMode] = openWithAddMode.rawValue
    }
}

// All options for the Play Queue at startup
enum PlayQueueStartupOption: String, CaseIterable {
    
    case empty
    case rememberFromLastAppLaunch
    case loadFile
    case loadFolder
}

enum PlayQueueTracksAddMode: String, CaseIterable {
    
    case append
    case replace
    case hybrid
}
