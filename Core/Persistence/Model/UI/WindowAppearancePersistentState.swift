//
//  WindowUIPersistentState.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Foundation

#if os(macOS)

///
/// Persistent state for window appearance settings.
///
/// - SeeAlso: `WindowAppearanceState`
///
struct WindowAppearancePersistentState: Codable {
    
    let cornerRadius: CGFloat?
    
    init(cornerRadius: CGFloat) {
        self.cornerRadius = cornerRadius
    }
    
    init(legacyPersistentState: WindowAppearancePersistentState?) {
        self.cornerRadius = legacyPersistentState?.cornerRadius?.clamped(to: 0...20)
    }
}

#endif
