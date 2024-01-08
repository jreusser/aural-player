//
//  LibraryPlaylistFilesPlayedNotification.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import Foundation

struct LibraryPlaylistFilesPlayedNotification: NotificationPayload {
    
    let notificationName: Notification.Name = .library_playlistFilesPlayed
    let playlistFiles: [URL]
}
