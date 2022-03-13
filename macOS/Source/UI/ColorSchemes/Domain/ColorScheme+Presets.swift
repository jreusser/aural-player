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
    
    static let blackAttack: ColorScheme = .init(name: "Black Attack", systemDefined: true,
                                                backgroundColor: .white8Percent, captionTextColor: .white40Percent,
                                                primaryTextColor: .white90Percent, secondaryTextColor: .white65Percent, tertiaryTextColor: .white55Percent,
                                                primarySelectedTextColor: .white80Percent, secondarySelectedTextColor: .white55Percent,
                                                buttonColor: .white90Percent, buttonOffColor: .white25Percent,
                                                activeControlColor: .green75Percent, bypassedControlColor: .white60Percent, suppressedControlColor: PlatformColor(red: 0.76, green: 0.69, blue: 0),
                                                sliderBackgroundColor: .white15Percent, sliderTickColor: .black,
                                                textSelectionColor: .white15Percent)
    
    static let allPresets: [ColorScheme] = [.blackAttack]
}
