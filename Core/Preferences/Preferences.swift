//
//  Preferences.swift
//  Aural
//
//  Copyright © 2023 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
/*
 Handles loading/saving of app user preferences
 */
import Foundation

///
/// Encapsulates all user preferences for this application.
///
class Preferences {
    
    /// The underlying datastore containing the user preferences.
    let defaults: UserDefaults
    
    // Preferences for different app components / features.
    
    var playlistPreferences: PlaylistPreferences
    var playbackPreferences: PlaybackPreferences
    var soundPreferences: SoundPreferences
    
#if os(macOS)
    var viewPreferences: ViewPreferences
#endif
    
    var historyPreferences: HistoryPreferences
    var controlsPreferences: ControlsPreferences
    var metadataPreferences: MetadataPreferences
    
    var allPreferences: [PersistentPreferencesProtocol] {
        
#if os(macOS)
        
        [playbackPreferences, soundPreferences, playlistPreferences, viewPreferences,
                          historyPreferences, controlsPreferences, metadataPreferences]
        
        #elseif os(iOS)
        
        [playbackPreferences, soundPreferences, playlistPreferences,
                          historyPreferences, controlsPreferences, metadataPreferences]
        
        #endif
    }
    
    init(defaults: UserDefaults) {
        
        self.defaults = defaults
        let defaultsDictionary = defaults.dictionaryRepresentation()
        
        controlsPreferences = ControlsPreferences(defaultsDictionary)
        playbackPreferences = PlaybackPreferences(defaultsDictionary, controlsPreferences.gestures)
        soundPreferences = SoundPreferences(defaultsDictionary, controlsPreferences.gestures)
        playlistPreferences = PlaylistPreferences(defaultsDictionary)
        
#if os(macOS)
        viewPreferences = ViewPreferences(defaultsDictionary)
#endif
        
        historyPreferences = HistoryPreferences(defaultsDictionary)
        metadataPreferences = MetadataPreferences(defaultsDictionary)
    }
    
    func persist() {
        allPreferences.forEach {$0.persist(to: defaults)}
    }
}
