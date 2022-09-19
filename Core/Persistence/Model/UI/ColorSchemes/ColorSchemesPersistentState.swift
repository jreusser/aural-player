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
    let buttonColor: ColorPersistentState?
    let iconColor: ColorPersistentState?
    
    let captionTextColor: ColorPersistentState?
    
    let primaryTextColor: ColorPersistentState?
    let secondaryTextColor: ColorPersistentState?
    let tertiaryTextColor: ColorPersistentState?
    
    let primarySelectedTextColor: ColorPersistentState?
    let secondarySelectedTextColor: ColorPersistentState?
    let tertiarySelectedTextColor: ColorPersistentState?
    
    let textSelectionColor: ColorPersistentState?
    
    let activeControlColor: ColorPersistentState?
    let inactiveControlColor: ColorPersistentState?
    let suppressedControlColor: ColorPersistentState?
    
    #if os(macOS)
    
    // When saving app state to disk
    init(_ scheme: ColorScheme) {
        
        self.name = scheme.name

        self.backgroundColor = ColorPersistentState(color: scheme.backgroundColor)
        self.buttonColor = ColorPersistentState(color: scheme.buttonColor)
        self.iconColor = ColorPersistentState(color: scheme.iconColor)
        
        self.captionTextColor = ColorPersistentState(color: scheme.captionTextColor)
        
        self.primaryTextColor = ColorPersistentState(color: scheme.primaryTextColor)
        self.secondaryTextColor = ColorPersistentState(color: scheme.secondaryTextColor)
        self.tertiaryTextColor = ColorPersistentState(color: scheme.tertiaryTextColor)
        
        self.primarySelectedTextColor = ColorPersistentState(color: scheme.primarySelectedTextColor)
        self.secondarySelectedTextColor = ColorPersistentState(color: scheme.secondarySelectedTextColor)
        self.tertiarySelectedTextColor = ColorPersistentState(color: scheme.tertiarySelectedTextColor)
        
        self.textSelectionColor = ColorPersistentState(color: scheme.textSelectionColor)
        
        self.activeControlColor = ColorPersistentState(color: scheme.activeControlColor)
        self.inactiveControlColor = ColorPersistentState(color: scheme.inactiveControlColor)
        self.suppressedControlColor = ColorPersistentState(color: scheme.suppressedControlColor)
    }
    
    #endif
}
