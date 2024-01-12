//
//  AppSetup.swift
//  Aural
//
//  Copyright © 2023 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import Foundation

class AppSetup {
    
    private init() {}
    
    /// Singleton
    static var shared: AppSetup = .init()
    
    static var setupRequired: Bool {
        
        if !persistenceManager.persistentStateFileExists {
            return true
        }
        
        if let appVersion = appPersistentState.appVersion {
            return !appVersion.starts(with: "4")
        }
        
        return true
    }
    
    var performSetup: Bool = false
    
    var presentationMode: AppMode = .defaultMode
    var windowLayout: WindowLayoutPresets = .defaultLayout
    var colorScheme: ColorSchemePreset = .defaultScheme
    var fontScheme: FontSchemePreset = .defaultScheme
    var libraryHome: URL = FilesAndPaths.musicDir
}
