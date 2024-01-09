//
//  ColorSchemesManager.swift
//  Aural
//
//  Copyright © 2023 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

/*
    Utility class that manages all color schemes, including user-defined schemes, system-defined presets, and the current system color scheme.
 */
class ColorSchemesManager: UserManagedObjects<ColorScheme> {
    
    // The current system color scheme. It is initialized with the default scheme.
    let systemScheme: ColorScheme
    
    private lazy var messenger = Messenger(for: self)
    
    var propertyObservers: [KeyPath<ColorScheme, PlatformColor>: [ColorSchemePropertyObserver]] = [:]
    var schemeAndPropertyObservers: [KeyPath<ColorScheme, PlatformColor>: [ColorSchemeObserver]] = [:]
    
    var schemeObservers: [ColorSchemeObserver] = []
    
    // TODO: This will NOT work for an object that observes multiple properties !!!
    // The value should be an array of KeyPath.
    var reverseRegistry: [NSObject: KeyPath<ColorScheme, PlatformColor>] = [:]
    
    var propertyKVO: KVOTokens<ColorScheme, PlatformColor> = KVOTokens()
    var schemeKVO: KVOTokens<ColorScheme, PlatformColor> = KVOTokens()
    
    var isObserving: Bool = false
    
    var schemeChanged: Bool = false
    
    init(persistentState: ColorSchemesPersistentState?) {
        
        let systemDefinedSchemes: [ColorScheme] = ColorScheme.allPresets
        let userDefinedSchemes = (persistentState?.userSchemes ?? []).map {ColorScheme($0, false)}
        
        if let persistentSystemScheme = persistentState?.systemScheme {
            self.systemScheme = ColorScheme(persistentSystemScheme, true)
            
        } else {
            
            self.systemScheme = systemDefinedSchemes.first(where: {$0.name == ColorScheme.defaultScheme.name}) ??
            ColorScheme("_system_", true, .blackAqua)
        }
        
        super.init(systemDefinedObjects: systemDefinedSchemes, userDefinedObjects: userDefinedSchemes)
    }
    
    private func systemSchemeChanged() {
        
        // Update color / gradient caches whenever the system scheme changes.
//        AuralPlaylistOutlineView.updateCachedImages()
        
        schemeObservers.forEach {
            $0.colorSchemeChanged()
        }
    }
    
    // Applies a color scheme to the system color scheme and returns the modified system scheme.
    func applyScheme(_ scheme: ColorScheme) {
        
        schemeChanged = true
        
        systemScheme.applyScheme(scheme)
        systemSchemeChanged()
        
        schemeChanged = false
        
        messenger.publish(.applyColorScheme, payload: systemScheme)
    }
    
    // Attempts to apply a color scheme to the system color scheme, looking up the scheme by the given display name, and if found, returns the modified system scheme.
    func applyScheme(named name: String) {
        
        if let scheme = object(named: name) {
            applyScheme(scheme)
        }
    }
    
    // State to be persisted to disk.
    var persistentState: ColorSchemesPersistentState {
        
        ColorSchemesPersistentState(systemScheme: ColorSchemePersistentState(systemScheme),
                                    userSchemes: userDefinedObjects.map {ColorSchemePersistentState($0)})
    }
}
