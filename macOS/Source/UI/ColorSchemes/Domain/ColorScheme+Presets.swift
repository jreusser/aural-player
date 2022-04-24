//
//  ColorScheme+Presets.swift
//  Aural-macOS
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

extension ColorScheme {
    
    static let blackAttack: ColorScheme = .init(name: "Black attack (default)", systemDefined: true,
                                                backgroundColor: .white8Percent, captionTextColor: .white40Percent,
                                                primaryTextColor: .white90Percent, secondaryTextColor: .white55Percent, tertiaryTextColor: .white40Percent,
                                                primarySelectedTextColor: .white80Percent, secondarySelectedTextColor: .white55Percent, tertiarySelectedTextColor: .white40Percent,
                                                buttonColor: .white90Percent, buttonOffColor: .white25Percent,
                                                activeControlColor: .green75Percent, bypassedControlColor: .white60Percent, suppressedControlColor: PlatformColor(red: 0.76, green: 0.69, blue: 0),
                                                sliderBackgroundColor: .white15Percent, sliderTickColor: .black,
                                                textSelectionColor: .white15Percent, iconColor: .white60Percent)
    
    static let lava: ColorScheme = .init(name: "Lava", systemDefined: true,
                                         backgroundColor: PlatformColor(red: 0.144, green: 0.144, blue: 0.144), captionTextColor: .white40Percent,
                                         primaryTextColor: .white90Percent, secondaryTextColor: .white65Percent, tertiaryTextColor: .white55Percent,
                                         primarySelectedTextColor: .white80Percent, secondarySelectedTextColor: .white55Percent,
                                         tertiarySelectedTextColor: .white40Percent,
                                         buttonColor: .white80Percent, buttonOffColor: .white35Percent,
                                         activeControlColor: .lava, bypassedControlColor: .white60Percent, suppressedControlColor: PlatformColor(red: 0.5, green: 0.204, blue: 0.107),
                                         sliderBackgroundColor: PlatformColor(red: 0.326, green: 0.326, blue: 0.326), sliderTickColor: .black,
                                         textSelectionColor: .black, iconColor: .white60Percent)
    
    static let allPresets: [ColorScheme] = [.blackAttack, .lava]
}
