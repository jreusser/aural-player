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

class TracksAddedNotification: NotificationPayload {

    let notificationName: Notification.Name
    
    // The indices of the newly added tracks
    let trackIndices: ClosedRange<Int>
    
    init(notificationName: Notification.Name, trackIndices: ClosedRange<Int>) {
        
        self.notificationName = notificationName
        self.trackIndices = trackIndices
    }
}

class PlayQueueTracksAddedNotification: TracksAddedNotification {
    
    init(trackIndices: ClosedRange<Int>) {
        super.init(notificationName: .playQueue_tracksAdded, trackIndices: trackIndices)
    }
}

class PlaylistTracksAddedNotification: TracksAddedNotification {
    
    init(trackIndices: ClosedRange<Int>) {
        super.init(notificationName: .playlist_tracksAdded, trackIndices: trackIndices)
    }
}
