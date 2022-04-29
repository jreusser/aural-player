//
//  PlayerFontScheme.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

//import Cocoa
//
//class PlayerFontScheme {
//
//
//
//    init(_ persistentState: FontSchemePersistentState?) {
//
//        self.primaryFont = FontSchemePreset.standard.primaryFont
//        self.secondaryFont = FontSchemePreset.standard.secondaryFont
//        self.tertiaryFont = FontSchemePreset.standard.tertiaryFont
//
//        guard let textFontName = persistentState?.textFontName else {
//            return
//        }
//
//        if let primarySize = persistentState?.player?.primarySize, let primaryFont = NSFont(name: textFontName, size: primarySize) {
//            self.primaryFont = primaryFont
//        }
//
//        if let secondarySize = persistentState?.player?.secondarySize, let secondaryFont = NSFont(name: textFontName, size: secondarySize) {
//            self.secondaryFont = secondaryFont
//        }
//
//        if let tertiarySize = persistentState?.player?.tertiarySize, let tertiaryFont = NSFont(name: textFontName, size: tertiarySize) {
//            self.tertiaryFont = tertiaryFont
//        }
//    }
//
//    init(preset: FontSchemePreset) {
//
//
//    }
//
//    init(_ fontScheme: PlayerFontScheme) {
//
//        self.primaryFont = fontScheme.primaryFont
//        self.secondaryFont = fontScheme.secondaryFont
//        self.tertiaryFont = fontScheme.tertiaryFont
//    }
//
//    func clone() -> PlayerFontScheme {
//        return PlayerFontScheme(self)
//    }
//}
