//
//  PlayQueueDelegate+Init.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//

import Foundation

extension PlayQueueDelegate {
    
    func initialize(fromPersistentState persistentState: PlayQueuePersistentState?, appLaunchFiles: [URL]) {
        
        let df = DateFormatter(format: "H:mm:ss.SSS")
        print("PQDelegate.appLaunched(): \(df.string(from: Date()))")
        
        lazy var playQueuePreferences = preferences.playQueuePreferences
        lazy var playbackPreferences = preferences.playbackPreferences
        
        // Check if any launch parameters were specified
        if appLaunchFiles.isNonEmpty {
            
            // Launch parameters  specified, override playlist saved state and add file paths in params to playlist
            loadTracks(from: appLaunchFiles, autoplay: playbackPreferences.autoplayAfterOpeningTracks.value)
            
        } else {
            
            guard let state = persistentState else {return}
            
            if playQueuePreferences.playQueueOnStartup.value == .rememberFromLastAppLaunch, let files = state.tracks {
                
                // No launch parameters specified, load playlist saved state if "Remember state from last launch" preference is selected
                loadTracks(from: files, autoplay: playbackPreferences.autoplayOnStartup.value)
            }
        }
        
        // TODO: Load from playlist / playlist file / folder / group
        
        //        } else if playlistPreferences.playlistOnStartup == .loadFile,
        //                  let playlistFile: URL = playlistPreferences.playlistFile {
        //
        //            addFiles_async([playlistFile], AutoplayOptions(playbackPreferences.autoplayOnStartup), userAction: false)
        //
        //        } else if playlistPreferences.playlistOnStartup == .loadFolder,
        //                  let folder: URL = playlistPreferences.tracksFolder {
        //
        //            addFiles_async([folder], AutoplayOptions(playbackPreferences.autoplayOnStartup), userAction: false)
        //        }
    }
}
