//
//  FontScheme.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

/*
    Container for fonts used by the UI
 */
class FontScheme: NSObject, UserManagedObject {
    
    // Displayed name
    var name: String
    
    var key: String {
        
        get {name}
        set {name = newValue}
    }
    
    var userDefined: Bool {!systemDefined}

    // False if defined by the user
    let systemDefined: Bool
    
    @objc dynamic var playerPrimaryFont: NSFont
    @objc dynamic var playerSecondaryFont: NSFont
    @objc dynamic var playerTertiaryFont: NSFont
    
    var playlist: PlaylistFontScheme
    var effects: EffectsFontScheme
    
    // Used when loading app state on startup
    init(_ persistentState: FontSchemePersistentState?, _ systemDefined: Bool) {
        
        self.name = persistentState?.name ?? ""
        self.systemDefined = systemDefined
        
        self.playerPrimaryFont = FontSchemePreset.standard.primaryFont
        self.playerSecondaryFont = FontSchemePreset.standard.secondaryFont
        self.playerTertiaryFont = FontSchemePreset.standard.tertiaryFont
        
        self.playlist = PlaylistFontScheme(persistentState)
        self.effects = EffectsFontScheme(persistentState)
        
        guard let textFontName = persistentState?.textFontName else {
            return
        }
        
        if let primarySize = persistentState?.playerPrimarySize, let primaryFont = NSFont(name: textFontName, size: primarySize) {
            self.playerPrimaryFont = primaryFont
        }
        
        if let secondarySize = persistentState?.playerSecondarySize, let secondaryFont = NSFont(name: textFontName, size: secondarySize) {
            self.playerSecondaryFont = secondaryFont
        }
        
        if let tertiarySize = persistentState?.playerTertiarySize, let tertiaryFont = NSFont(name: textFontName, size: tertiarySize) {
            self.playerTertiaryFont = tertiaryFont
        }
    }
    
    init(_ name: String, _ preset: FontSchemePreset) {
        
        self.name = name
        self.systemDefined = true
        
        self.playerPrimaryFont = preset.primaryFont
        self.playerSecondaryFont = preset.secondaryFont
        self.playerTertiaryFont = preset.tertiaryFont
        
        self.playlist = PlaylistFontScheme(preset: preset)
        self.effects = EffectsFontScheme(preset: preset)
    }
    
    init(_ name: String, _ systemDefined: Bool, _ fontScheme: FontScheme) {
        
        self.name = name
        self.systemDefined = systemDefined
        
        self.playerPrimaryFont = fontScheme.playerPrimaryFont
        self.playerSecondaryFont = fontScheme.playerSecondaryFont
        self.playerTertiaryFont = fontScheme.playerTertiaryFont
        
        self.playlist  = fontScheme.playlist.clone()
        self.effects = fontScheme.effects.clone()
    }
    
    // Applies another font scheme to this scheme.
    func applyScheme(_ fontScheme: FontScheme) {
        
        self.playerPrimaryFont = fontScheme.playerPrimaryFont
        self.playerSecondaryFont = fontScheme.playerSecondaryFont
        self.playerTertiaryFont = fontScheme.playerTertiaryFont
        
        self.playlist = fontScheme.playlist.clone()
        self.effects = fontScheme.effects.clone()
    }
    
    func clone() -> FontScheme {
        return FontScheme(self.name + "_clone", self.systemDefined, self)
    }
}
