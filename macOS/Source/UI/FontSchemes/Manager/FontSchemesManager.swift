//
//  FontSchemesManager.swift
//  Aural
//
//  Copyright © 2023 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

class FontSchemesManager: UserManagedObjects<FontScheme> {
    
    // The current system color scheme. It is initialized with the default scheme.
    private(set) var systemScheme: FontScheme
    
    private lazy var messenger = Messenger(for: self)
    
    var propertyObservers: [KeyPath<FontScheme, PlatformFont>: [FontSchemePropertyObserver]] = [:]
    var schemeAndPropertyObservers: [KeyPath<FontScheme, PlatformFont>: [FontSchemeObserver]] = [:]
    
    var schemeObservers: [FontSchemeObserver] = []
    
    var reverseRegistry: [NSObject: KeyPath<FontScheme, PlatformFont>] = [:]
    
    var propertyKVO: KVOTokens<FontScheme, PlatformFont> = KVOTokens()
    var schemeKVO: KVOTokens<FontScheme, PlatformFont> = KVOTokens()
    
    var isObserving: Bool = false
    
    var schemeChanged: Bool = false
    
    init(persistentState: FontSchemesPersistentState?) {
        
        let systemDefinedSchemes = FontSchemePreset.allCases.map {FontScheme($0.name, $0)}
        let userDefinedSchemes = (persistentState?.userSchemes ?? []).map {FontScheme($0, false)}
        
        if let persistentSystemScheme = persistentState?.systemScheme {
            
            self.systemScheme = FontScheme(persistentSystemScheme, true)
            
        } else {
            
            self.systemScheme = systemDefinedSchemes.first(where: {$0.name == FontSchemePreset.standard.name}) ??
                FontScheme("_system_", FontSchemePreset.futuristic)
        }
        
        super.init(systemDefinedObjects: systemDefinedSchemes, userDefinedObjects: userDefinedSchemes)
    }
    
    func applyScheme(named name: String) {
        
        if let scheme = object(named: name) {
            applyScheme(scheme)
        }
    }
    
    func applyScheme(_ fontScheme: FontScheme) {
        
        schemeChanged = true
        systemScheme.applyScheme(fontScheme)
        schemeChanged = false
        
        messenger.publish(.applyFontScheme, payload: systemScheme)
    }
    
    // State to be persisted to disk.
    var persistentState: FontSchemesPersistentState {
        
        FontSchemesPersistentState(systemScheme: FontSchemePersistentState(systemScheme),
                                   userSchemes: userDefinedObjects.map {FontSchemePersistentState($0)})
    }
}
