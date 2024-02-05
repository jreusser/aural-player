//
//  PlayQueueNotifications.swift
//  Aural
//
//  Copyright © 2023 Kartik Venugopal. All rights reserved.
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
    
    // Signifies that new tracks have been added to the play queue.
    static let playQueue_tracksAdded = Notification.Name("playQueue_tracksAdded")
    
    static let playQueue_tracksRemoved = Notification.Name("playQueue_tracksRemoved")
    
    static let playQueue_tracksDragDropped = Notification.Name("playQueue_tracksDragDropped")
    
    static let playQueue_sorted = Notification.Name("playQueue_sorted")
    
    // Signifies that the summary for the play queue needs to be updated.
    static let playQueue_updateSummary = Notification.Name("playQueue_updateSummary")
    
    // ----------------------------------------------------------------------------------------
    
    // MARK: Play Queue commands
    
    // Commands the play queue to display a file dialog to let the user add new tracks.
    static let playQueue_addTracks = Notification.Name("playQueue_addTracks")
    
    // Commands the play queue to enqueue the given tracks and begin playing the first one immediately.
    static let playQueue_enqueueAndPlayNow = Notification.Name("playQueue_enqueueAndPlayNow")
    
    static let playQueue_loadAndPlayNow = Notification.Name("playQueue_loadAndPlayNow")
    
    // Commands the play queue to enqueue the given tracks so that they begin playing after the currently playing track.
    static let playQueue_enqueueAndPlayNext = Notification.Name("playQueue_enqueueAndPlayNext")
    
    // Commands the play queue to enqueue the given tracks so that they begin playing after all the existing tracks have finished playing.
    static let playQueue_enqueueAndPlayLater = Notification.Name("playQueue_enqueueAndPlayLater")
    
    // Commands the play queue view to reveal (i.e. scroll to and select) the currently playing track.
    static let playQueue_showPlayingTrack = Notification.Name("playQueue_showPlayingTrack")
    
    // Commands the play queue to remove any selected tracks.
    static let playQueue_removeTracks = Notification.Name("playQueue_removeTracks")
    static let playQueue_removeAllTracks = Notification.Name("playQueue_removeAllTracks")
    static let playQueue_refresh = Notification.Name("playQueue_refresh")
    
    // Signifies that the currently playing track has been removed from the playlist, suggesting
    // that playback should stop.
    static let playQueue_playingTrackRemoved = Notification.Name("playQueue_playingTrackRemoved")
    
    // Commands the play queue to remove any selected tracks.
    static let playQueue_exportAsPlaylistFile = Notification.Name("playQueue_exportAsPlaylistFile")
    
    // Commands the playlist to initiate playback of a selected item.
    static let playQueue_playSelectedTrack = Notification.Name("playQueue_playSelectedTrack")
    
    // Context-menu action to play the selected track next.
    static let playQueue_playNext = Notification.Name("playQueue_playNext")
    
    static let playQueue_moveTracksUp = Notification.Name("playQueue_moveTracksUp")
    static let playQueue_moveTracksDown = Notification.Name("playQueue_moveTracksDown")
    static let playQueue_moveTracksToTop = Notification.Name("playQueue_moveTracksToTop")
    static let playQueue_moveTracksToBottom = Notification.Name("playQueue_moveTracksToBottom")
    
    // Commands the currently displayed Play Queue view to select all its items.
    static let playQueue_selectAllTracks = Notification.Name("playQueue_selectAllTracks")
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
    
    static let playQueue_search = Notification.Name("playQueue_search")
}
