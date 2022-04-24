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
    
    static let blackAqua: ColorScheme = .init(name: "Black & aqua (default)", systemDefined: true,
                                                backgroundColor: .white8Percent, captionTextColor: .white40Percent,
                                                primaryTextColor: .white70Percent, secondaryTextColor: .white45Percent, tertiaryTextColor: .white30Percent,
                                                primarySelectedTextColor: .white, secondarySelectedTextColor: .white75Percent, tertiarySelectedTextColor: .white50Percent,
                                                buttonColor: .white90Percent, buttonOffColor: .white25Percent,
                                                activeControlColor: .aqua, bypassedControlColor: .white60Percent, suppressedControlColor: PlatformColor(red: 0, green: 0.31, blue: 0.5),
                                                sliderBackgroundColor: .white15Percent, sliderTickColor: .black,
                                                textSelectionColor: .white15Percent, iconColor: .white60Percent)
    
    static let blackGreen: ColorScheme = .init(name: "Black & green", systemDefined: true,
                                               backgroundColor: .white8Percent, captionTextColor: .white40Percent,
                                               primaryTextColor: .white70Percent, secondaryTextColor: .white45Percent, tertiaryTextColor: .white30Percent,
                                               primarySelectedTextColor: .white, secondarySelectedTextColor: .white75Percent, tertiarySelectedTextColor: .white50Percent,
                                               buttonColor: .white90Percent, buttonOffColor: .white25Percent,
                                               activeControlColor: .green75Percent, bypassedControlColor: .white60Percent, suppressedControlColor: .green50Percent,
                                                sliderBackgroundColor: .white15Percent, sliderTickColor: .black,
                                                textSelectionColor: .white15Percent, iconColor: .white60Percent)
    
    static let lava: ColorScheme = .init(name: "Lava", systemDefined: true,
                                         backgroundColor: PlatformColor(red: 0.144, green: 0.144, blue: 0.144), captionTextColor: .white40Percent,
                                         primaryTextColor: .white70Percent, secondaryTextColor: .white45Percent, tertiaryTextColor: .white30Percent,
                                         primarySelectedTextColor: .white, secondarySelectedTextColor: .white75Percent, tertiarySelectedTextColor: .white50Percent,
                                         buttonColor: .white80Percent, buttonOffColor: .white35Percent,
                                         activeControlColor: .lava, bypassedControlColor: .white60Percent, suppressedControlColor: PlatformColor(red: 0.5, green: 0.204, blue: 0.107),
                                         sliderBackgroundColor: PlatformColor(red: 0.326, green: 0.326, blue: 0.326), sliderTickColor: .black,
                                         textSelectionColor: .black, iconColor: .white60Percent)
    
    static let whiteBlight: ColorScheme = .init(name: "White blight", systemDefined: true,
                                              backgroundColor: .white75Percent, captionTextColor: .white30Percent,
                                         primaryTextColor: .black, secondaryTextColor: .white25Percent, tertiaryTextColor: .white40Percent,
                                         primarySelectedTextColor: .white, secondarySelectedTextColor: .white70Percent, tertiarySelectedTextColor: .white60Percent,
                                         buttonColor: .black, buttonOffColor: .white55Percent,
                                              activeControlColor: .white40Percent, bypassedControlColor: .white30Percent, suppressedControlColor: .white50Percent,
                                              sliderBackgroundColor: .black, sliderTickColor: .black,
                                         textSelectionColor: .white15Percent, iconColor: .white60Percent)
    
    static let gloomyDay: ColorScheme = .init(name: "Gloomy day", systemDefined: true,
                                              backgroundColor: .white20Percent, captionTextColor: .white50Percent,
                                         primaryTextColor: .white70Percent, secondaryTextColor: .white45Percent, tertiaryTextColor: .white35Percent,
                                         primarySelectedTextColor: .white, secondarySelectedTextColor: .white75Percent, tertiarySelectedTextColor: .white50Percent,
                                         buttonColor: .white80Percent, buttonOffColor: .white35Percent,
                                              activeControlColor: .white70Percent, bypassedControlColor: .white30Percent, suppressedControlColor: .white50Percent,
                                              sliderBackgroundColor: .black, sliderTickColor: .black,
                                         textSelectionColor: .black, iconColor: .white60Percent)
    
    static let allPresets: [ColorScheme] = [.blackAqua, .blackGreen, .lava, .gloomyDay, .whiteBlight]
}
