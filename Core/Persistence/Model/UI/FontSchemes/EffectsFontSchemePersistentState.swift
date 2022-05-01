//
//  EffectsFontSchemePersistentState.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Foundation

///
/// Persistent state for the effects component of a single font scheme.
///
/// - SeeAlso: `EffectsFontScheme`
///
struct EffectsFontSchemePersistentState: Codable {

    let filterChartSize: CGFloat?
    let auRowTextYOffset: CGFloat?

    init(_ scheme: EffectsFontScheme) {

        self.filterChartSize = scheme.filterChartFont.pointSize
        self.auRowTextYOffset = scheme.auRowTextYOffset
    }
}
