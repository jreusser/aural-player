//
//  FontSchemesPersistentState.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Foundation

///
/// Encapsulates all persistent state for application font schemes.
///
/// - SeeAlso: `FontSchemesManager`
///
struct FontSchemesPersistentState: Codable {

    let systemScheme: FontSchemePersistentState?
    let userSchemes: [FontSchemePersistentState]?
}

///
/// Persistent state for a single font scheme.
///
/// - SeeAlso: `FontScheme`
///
struct FontSchemePersistentState: Codable {

    let name: String?
    
    let textFontName: String?
    let headingFontName: String?
    
    let captionSize: CGFloat?

    let playerPrimarySize: CGFloat?
    let playerSecondarySize: CGFloat?
    let playerTertiarySize: CGFloat?
    
    let effectsPrimarySize: CGFloat?
    let effectsSecondarySize: CGFloat?
    let effectsTertiarySize: CGFloat?

    let playlist: PlaylistFontSchemePersistentState?
    let effects: EffectsFontSchemePersistentState?

    // When saving app state to disk
    init(_ scheme: FontScheme) {

        self.name = scheme.name
        
        self.textFontName = scheme.playerPrimaryFont.fontName
        self.headingFontName = scheme.playlist.tabButtonTextFont.fontName
        
        self.captionSize = scheme.captionFont.pointSize
        
        self.playerPrimarySize = scheme.playerPrimaryFont.pointSize
        self.playerSecondarySize = scheme.playerSecondaryFont.pointSize
        self.playerTertiarySize = scheme.playerTertiaryFont.pointSize
        
        self.effectsPrimarySize = scheme.effectsPrimaryFont.pointSize
        self.effectsSecondarySize = scheme.effectsSecondaryFont.pointSize
        self.effectsTertiarySize = scheme.effectsTertiaryFont.pointSize

        self.playlist = PlaylistFontSchemePersistentState(scheme.playlist)
        self.effects = EffectsFontSchemePersistentState(scheme.effects)
    }
}
