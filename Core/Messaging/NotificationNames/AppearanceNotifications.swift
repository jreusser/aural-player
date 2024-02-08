//
//  AppearanceNotifications.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  
import Foundation

///
/// Notifications that pertain to the appearance of the user interface.
///
extension Notification.Name {
    
    // MARK: Font scheme commands
    
    // Commands all UI components to apply a new specified font scheme.
    static let applyFontScheme = Notification.Name("applyFontScheme")

    // MARK: Color scheme commands

    // Commands all UI components to apply a new specified color scheme.
    static let applyColorScheme = Notification.Name("applyColorScheme")
    
    // MARK: Window appearance commands sent to all app windows
    
    static let windowAppearance_changeCornerRadius = Notification.Name("windowAppearance_changeCornerRadius")
    
    // MARK: Theme commands
    
    static let applyTheme = Notification.Name("applyTheme")
}
