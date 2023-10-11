//
//  EffectsFontScheme.swift
//  Aural
//
//  Copyright © 2023 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import Cocoa

class EffectsFontScheme {

    var filterChartFont: NSFont
    var auRowTextYOffset: CGFloat
    
    init(_ persistentState: FontSchemePersistentState?) {
        
        self.filterChartFont = FontSchemePreset.standard.effectsSecondaryFont
        self.auRowTextYOffset = FontSchemePreset.standard.effectsAURowTextYOffset
        
        guard let textFontName = persistentState?.textFontName else {
            return
        }
        
        if let filterChartSize = persistentState?.effects?.filterChartSize, let filterChartFont = NSFont(name: textFontName, size: filterChartSize) {
            self.filterChartFont = filterChartFont
        }
        
        if let auRowTextYOffset = persistentState?.effects?.auRowTextYOffset {
            self.auRowTextYOffset = auRowTextYOffset
        }
    }
    
    init(preset: FontSchemePreset) {
        
        self.filterChartFont = preset.effectsSecondaryFont
        self.auRowTextYOffset = preset.effectsAURowTextYOffset
    }
    
    init(_ fontScheme: EffectsFontScheme) {
        
        self.filterChartFont = fontScheme.filterChartFont
        self.auRowTextYOffset = fontScheme.auRowTextYOffset
    }
    
    func clone() -> EffectsFontScheme {
        return EffectsFontScheme(self)
    }
}
