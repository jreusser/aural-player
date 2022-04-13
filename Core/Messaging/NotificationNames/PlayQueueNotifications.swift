//
//  PlayQueueNotifications.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import Foundation

extension Notification.Name {
    
    // MARK: Notifications published by the play queue.
    
    // Signifies that the play queue has begun adding a set of tracks.
    static let playQueue_startedAddingTracks = Notification.Name("playQueue_startedAddingTracks")
    
    // Signifies that the play queue has finished adding a set of tracks.
    static let playQueue_doneAddingTracks = Notification.Name("playQueue_doneAddingTracks")
    
    // Signifies that some chosen tracks could not be added to the play queue (i.e. an error condition).
    static let playQueue_tracksNotAdded = Notification.Name("playQueue_tracksNotAdded")
    
    // Signifies that a new track has been added to the play queue.
    static let playQueue_trackAdded = Notification.Name("playQueue_trackAdded")
    
    static let playQueue_tracksAdded = Notification.Name("playQueue_tracksAdded")
    
    static let playQueue_tracksRemoved = Notification.Name("playQueue_tracksRemoved")
    
    static let playQueue_tracksDragDropped = Notification.Name("playQueue_tracksDragDropped")
    
    static let playQueue_sorted = Notification.Name("playQueue_sorted")
    
    // ----------------------------------------------------------------------------------------
    
    // MARK: Play Queue commands
    
    // Commands the play queue to display a file dialog to let the user add new tracks.
    static let playQueue_addTracks = Notification.Name("playQueue_addTracks")
    
    // Commands the play queue to display a file dialog to let the user add new tracks, and auto-plays the first added track.
    static let playQueue_addAndPlayTracks = Notification.Name("playQueue_addAndPlayTracks")
    
    // Commands the play queue to remove any selected tracks.
    static let playQueue_removeTracks = Notification.Name("playQueue_removeTracks")
    static let playQueue_clear = Notification.Name("playQueue_clear")
    
    // Commands the play queue to remove any selected tracks.
    static let playQueue_exportAsPlaylistFile = Notification.Name("playQueue_exportAsPlaylistFile")
    
    // Commands the playlist to initiate playback of a selected item.
    static let playQueue_playSelectedTrack = Notification.Name("playQueue_playSelectedTrack")
    
    static let playQueue_moveTracksUp = Notification.Name("playQueue_moveTracksUp")
    static let playQueue_moveTracksDown = Notification.Name("playQueue_moveTracksDown")
    static let playQueue_moveTracksToTop = Notification.Name("playQueue_moveTracksToTop")
    static let playQueue_moveTracksToBottom = Notification.Name("playQueue_moveTracksToBottom")
    
    static let playQueue_clearSelection = Notification.Name("playQueue_clearSelection")
    static let playQueue_cropSelection = Notification.Name("playQueue_cropSelection")
    static let playQueue_invertSelection = Notification.Name("playQueue_invertSelection")
    
    // Commands the playQueue to scroll to the top of its list view.
    static let playQueue_scrollToTop = Notification.Name("playQueue_scrollToTop")

    // Commands the playQueue to scroll to the bottom of its list view.
    static let playQueue_scrollToBottom = Notification.Name("playQueue_scrollToBottom")

    // Commands the playQueue to scroll one page up within its list view.
    static let playQueue_pageUp = Notification.Name("playQueue_pageUp")

    // Commands the playQueue to scroll one page down within its list view.
    static let playQueue_pageDown = Notification.Name("playQueue_pageDown")
}
