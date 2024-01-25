//
//  ColorSchemeChangeNotifications.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import Foundation

struct ColorSchemeChangeNotification: NotificationPayload {
    
    let property: KeyPath<ColorScheme, PlatformColor>
    let newColor: PlatformColor
    
    var notificationName: Notification.Name {
        
        let propertyString = String(reflecting: property).replacingOccurrences(of: "\\ColorScheme.", with: "")
        let notifName: Notification.Name = .init("colorSchemePropertyChange_\(propertyString)")
    }
}
