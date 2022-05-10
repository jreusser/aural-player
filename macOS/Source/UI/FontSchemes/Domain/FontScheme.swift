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
    
    @objc dynamic var captionFont: NSFont
    
    @objc dynamic var playerPrimaryFont: NSFont
    @objc dynamic var playerSecondaryFont: NSFont
    @objc dynamic var playerTertiaryFont: NSFont
    
    @objc dynamic var effectsPrimaryFont: NSFont
    @objc dynamic var effectsSecondaryFont: NSFont
    @objc dynamic var effectsTertiaryFont: NSFont
    
    @objc dynamic var playQueuePrimaryFont: NSFont
    @objc dynamic var playQueueSecondaryFont: NSFont
    @objc dynamic var playQueueTertiaryFont: NSFont
    
    var playlist: PlaylistFontScheme
    var effects: EffectsFontScheme
    
    // Used when loading app state on startup
    init(_ persistentState: FontSchemePersistentState?, _ systemDefined: Bool) {
        
        self.name = persistentState?.name ?? ""
        self.systemDefined = systemDefined
        
        self.captionFont = FontSchemePreset.standard.captionFont
        
        self.playerPrimaryFont = FontSchemePreset.standard.primaryFont
        self.playerSecondaryFont = FontSchemePreset.standard.secondaryFont
        self.playerTertiaryFont = FontSchemePreset.standard.tertiaryFont
        
        self.effectsPrimaryFont = FontSchemePreset.standard.effectsPrimaryFont
        self.effectsSecondaryFont = FontSchemePreset.standard.effectsSecondaryFont
        self.effectsTertiaryFont = FontSchemePreset.standard.tertiaryFont
        
        self.playQueuePrimaryFont = FontSchemePreset.standard.playQueuePrimaryFont
        self.playQueueSecondaryFont = FontSchemePreset.standard.playQueueSecondaryFont
        self.playQueueTertiaryFont = FontSchemePreset.standard.playQueueTertiaryFont
        
        self.playlist = PlaylistFontScheme(persistentState)
        self.effects = EffectsFontScheme(persistentState)
        
        if let captionFontName = persistentState?.headingFontName, let captionSize = persistentState?.captionSize,
            let captionFont = NSFont(name: captionFontName, size: captionSize) {
            
            self.captionFont = captionFont
        }
        
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
        
        if let primarySize = persistentState?.effectsPrimarySize, let primaryFont = NSFont(name: textFontName, size: primarySize) {
            self.effectsPrimaryFont = primaryFont
        }
        
        if let secondarySize = persistentState?.effectsSecondarySize, let secondaryFont = NSFont(name: textFontName, size: secondarySize) {
            self.effectsSecondaryFont = secondaryFont
        }
        
        if let tertiarySize = persistentState?.effectsTertiarySize, let tertiaryFont = NSFont(name: textFontName, size: tertiarySize) {
            self.effectsTertiaryFont = tertiaryFont
        }
        
        if let primarySize = persistentState?.playQueuePrimarySize, let primaryFont = NSFont(name: textFontName, size: primarySize) {
            self.playQueuePrimaryFont = primaryFont
        }
        
        if let secondarySize = persistentState?.playQueueSecondarySize, let secondaryFont = NSFont(name: textFontName, size: secondarySize) {
            self.playQueueSecondaryFont = secondaryFont
        }
        
        if let tertiarySize = persistentState?.playQueueTertiarySize, let tertiaryFont = NSFont(name: textFontName, size: tertiarySize) {
            self.playQueueTertiaryFont = tertiaryFont
        }
    }
    
    init(_ name: String, _ preset: FontSchemePreset) {
        
        self.name = name
        self.systemDefined = true
        
        self.captionFont = preset.captionFont
        
        self.playerPrimaryFont = preset.primaryFont
        self.playerSecondaryFont = preset.secondaryFont
        self.playerTertiaryFont = preset.tertiaryFont
        
        self.effectsPrimaryFont = preset.effectsPrimaryFont
        self.effectsSecondaryFont = preset.effectsSecondaryFont
        self.effectsTertiaryFont = preset.tertiaryFont
        
        self.playQueuePrimaryFont = preset.playQueuePrimaryFont
        self.playQueueSecondaryFont = preset.playQueueSecondaryFont
        self.playQueueTertiaryFont = preset.playQueueTertiaryFont
        
        self.playlist = PlaylistFontScheme(preset: preset)
        self.effects = EffectsFontScheme(preset: preset)
    }
    
    init(_ name: String, _ systemDefined: Bool, _ fontScheme: FontScheme) {
        
        self.name = name
        self.systemDefined = systemDefined
        
        self.captionFont = fontScheme.captionFont
        
        self.playerPrimaryFont = fontScheme.playerPrimaryFont
        self.playerSecondaryFont = fontScheme.playerSecondaryFont
        self.playerTertiaryFont = fontScheme.playerTertiaryFont
        
        self.effectsPrimaryFont = fontScheme.effectsPrimaryFont
        self.effectsSecondaryFont = fontScheme.effectsSecondaryFont
        self.effectsTertiaryFont = fontScheme.effectsTertiaryFont
        
        self.playQueuePrimaryFont = fontScheme.playQueuePrimaryFont
        self.playQueueSecondaryFont = fontScheme.playQueueSecondaryFont
        self.playQueueTertiaryFont = fontScheme.playQueueTertiaryFont
        
        self.playlist  = fontScheme.playlist.clone()
        self.effects = fontScheme.effects.clone()
    }
    
    // Applies another font scheme to this scheme.
    func applyScheme(_ fontScheme: FontScheme) {
        
        self.captionFont = fontScheme.captionFont
        
        self.playerPrimaryFont = fontScheme.playerPrimaryFont
        self.playerSecondaryFont = fontScheme.playerSecondaryFont
        self.playerTertiaryFont = fontScheme.playerTertiaryFont
        
        self.effectsPrimaryFont = fontScheme.effectsPrimaryFont
        self.effectsSecondaryFont = fontScheme.effectsSecondaryFont
        self.effectsTertiaryFont = fontScheme.effectsTertiaryFont
        
        self.playQueuePrimaryFont = fontScheme.playQueuePrimaryFont
        self.playQueueSecondaryFont = fontScheme.playQueueSecondaryFont
        self.playQueueTertiaryFont = fontScheme.playQueueTertiaryFont
        
        self.playlist = fontScheme.playlist.clone()
        self.effects = fontScheme.effects.clone()
    }
    
    func clone() -> FontScheme {
        return FontScheme(self.name + "_clone", self.systemDefined, self)
    }
}
