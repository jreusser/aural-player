//
//  PlayQueueTracksDragDroppedNotification.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import Foundation

struct PlayQueueTracksDragDroppedNotification: NotificationPayload {
    
    let notificationName: Notification.Name = .playQueue_tracksDragDropped
    
    let results: [TrackMoveResult]
}
