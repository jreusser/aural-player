//
//  EnqueueAndPlayCommandNotification.swift
//  Aural-macOS
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import Foundation

struct EnqueueAndPlayCommand: NotificationPayload {
    
    let notificationName: Notification.Name = .playQueue_addAndPlayTracks
    let tracks: [Track]
    let clearPlayQueue: Bool
}
