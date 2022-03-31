//
//  PlayQueueTracksAddedNotifications.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import Foundation

// Indicates that a new track has been added to the playlist, and that the UI should refresh itself to show the new information.
struct PlayQueueTrackAddedNotification: NotificationPayload {
    
    let notificationName: Notification.Name = .playQueue_trackAdded
    
    // The index of the newly added track
    let trackIndex: Int
    
    // The current progress of the track add operation (See TrackAddOperationProgress)
    let addOperationProgress: TrackAddOperationProgress
}

struct PlayQueueTracksAddedNotification: NotificationPayload {
    
    let notificationName: Notification.Name = .playQueue_tracksAdded
    
    // The indices of the newly added tracks
    let trackIndices: ClosedRange<Int>
}
