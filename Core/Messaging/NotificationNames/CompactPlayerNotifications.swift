//
//  CompactPlayerNotifications.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import Foundation

///
/// Notifications published by / to the compact player.
///
extension Notification.Name {
    
    struct CompactPlayer {
        
        static let showPlayer = Notification.Name("compactPlayer_showPlayer")
        static let showPlayQueue = Notification.Name("compactPlayer_showPlayQueue")
        static let toggleEffects = Notification.Name("compactPlayer_toggleEffects")
        
        static let toggleTrackInfoScrolling = Notification.Name("compactPlayer_toggleTrackInfoScrolling")
        
        static let toggleShowSeekPosition = Notification.Name("compactPlayer_toggleShowSeekPosition")
        
        static let changeTrackTimeDisplayType = Notification.Name("compactPlayer_changeTrackTimeDisplayType")
        
        static let changeWindowCornerRadius = Notification.Name("compactPlayer_changeWindowCornerRadius")
    }
}
