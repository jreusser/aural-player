//
//  ColorSchemesPersistentState.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Foundation

///
/// Encapsulates all persistent state for application color schemes.
///
/// - SeeAlso: `ColorSchemesManager`
///
struct ColorSchemesPersistentState: Codable {

    let systemScheme: ColorSchemePersistentState?
    let userSchemes: [ColorSchemePersistentState]?
}

///
/// Persistent state for a single color scheme.
///
/// - SeeAlso: `ColorScheme`
///
struct ColorSchemePersistentState: Codable {
    
    let name: String
    
    let backgroundColor: ColorPersistentState?
    let captionTextColor: ColorPersistentState?
    
    let primaryTextColor: ColorPersistentState?
    let secondaryTextColor: ColorPersistentState?
    let tertiaryTextColor: ColorPersistentState?
    
    let primarySelectedTextColor: ColorPersistentState?
    let secondarySelectedTextColor: ColorPersistentState?
    let tertiarySelectedTextColor: ColorPersistentState?
    
    let buttonColor: ColorPersistentState?
    let buttonOffColor: ColorPersistentState?
    
    let activeControlColor: ColorPersistentState?
    let bypassedControlColor: ColorPersistentState?
    let suppressedControlColor: ColorPersistentState?
    
    let sliderBackgroundColor: ColorPersistentState?
    let sliderTickColor: ColorPersistentState?
    
    let textSelectionColor: ColorPersistentState?
    let iconColor: ColorPersistentState?
    
    // When saving app state to disk
    init(_ scheme: ColorScheme) {
        
        self.name = scheme.name

        self.backgroundColor = ColorPersistentState(color: scheme.backgroundColor)
        self.captionTextColor = ColorPersistentState(color: scheme.captionTextColor)
        
        self.primaryTextColor = ColorPersistentState(color: scheme.primaryTextColor)
        self.secondaryTextColor = ColorPersistentState(color: scheme.secondaryTextColor)
        self.tertiaryTextColor = ColorPersistentState(color: scheme.tertiaryTextColor)
        
        self.primarySelectedTextColor = ColorPersistentState(color: scheme.primarySelectedTextColor)
        self.secondarySelectedTextColor = ColorPersistentState(color: scheme.secondarySelectedTextColor)
        self.tertiarySelectedTextColor = ColorPersistentState(color: scheme.tertiarySelectedTextColor)
        
        self.buttonColor = ColorPersistentState(color: scheme.buttonColor)
        self.buttonOffColor = ColorPersistentState(color: scheme.buttonOffColor)
        
        self.activeControlColor = ColorPersistentState(color: scheme.activeControlColor)
        self.bypassedControlColor = ColorPersistentState(color: scheme.bypassedControlColor)
        self.suppressedControlColor = ColorPersistentState(color: scheme.suppressedControlColor)
        
        self.sliderBackgroundColor = ColorPersistentState(color: scheme.sliderBackgroundColor)
        self.sliderTickColor = ColorPersistentState(color: scheme.sliderTickColor)
        
        self.textSelectionColor = ColorPersistentState(color: scheme.textSelectionColor)
        self.iconColor = ColorPersistentState(color: scheme.iconColor)
    }
}
