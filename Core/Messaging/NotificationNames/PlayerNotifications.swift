//
//  PlayerNotifications.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  
import Foundation

///
/// Notifications pertaining to the **Player**.
///
extension Notification.Name {
    
    // MARK: Notifications published by the player.
    
    // Signifies that the playback state of the player has changed.
    static let player_playbackStateChanged = Notification.Name("player_playbackStateChanged")
    
    // Signifies that the player has performed a seek, resulting in a change in the playback position.
    static let player_seekPerformed = Notification.Name("player_seekPerformed")
    
    // Signifies that the player has restarted a segment loop.
    static let player_loopRestarted = Notification.Name("player_loopRestarted")
    
    // Signifies that the currently playing track chapter has changed.
    static let player_chapterChanged = Notification.Name("player_chapterChanged")
    
    // Signifies that the currently playing track has completed playback.
    static let player_trackPlaybackCompleted = Notification.Name("player_trackPlaybackCompleted")
    
    // Signifies that an error occurred and the player was unable to play the requested track.
    static let player_trackNotPlayed = Notification.Name("player_trackNotPlayed")
    
    // Signifies that the current track is about to change.
    static let player_preTrackChange = Notification.Name("player_preTrackChange")
    
    // Signifies that a new track is about to start playback.
    static let player_preTrackPlayback = Notification.Name("player_preTrackPlayback")
    
    // Signifies that a track / playback state transition has occurred.
    // eg. when changing tracks or stopping playback
    static let player_trackTransitioned = Notification.Name("player_trackTransitioned")
    
    // Signifies that a track's info/metadata has been updated (eg. duration / album art)
    static let player_trackInfoUpdated = Notification.Name("player_trackInfoUpdated")
    
    // Signifies that the playback loop for the currently playing track has changed.
    // Either a new loop point has been defined, or an existing loop has been removed.
    static let player_playbackLoopChanged = Notification.Name("player_playbackLoopChanged")
    
    // MARK: Playback commands (sent to the player)
    
    // Commands the player to play a specific track
    static let player_playTrack = Notification.Name("player_playTrack")
    
    // Commands the player to perform "autoplay"
    static let player_autoplay = Notification.Name("player_autoplay")
    
    // Commands the player to play, pause, or resume playback
    static let player_playOrPause = Notification.Name("player_playOrPause")

    // Commands the player to stop playback
    static let player_stop = Notification.Name("player_stop")

    // Commands the player to play the previous track in the current playback sequence
    static let player_previousTrack = Notification.Name("player_previousTrack")

    // Commands the player to play the next track in the current playback sequence
    static let player_nextTrack = Notification.Name("player_nextTrack")

    // Commands the player to replay the currently playing track from the beginning, if there is one
    static let player_replayTrack = Notification.Name("player_replayTrack")

    // Commands the player to seek backward within the currently playing track
    static let player_seekBackward = Notification.Name("player_seekBackward")

    // Commands the player to seek forward within the currently playing track
    static let player_seekForward = Notification.Name("player_seekForward")

    // Commands the player to seek backward within the currently playing track (secondary seek function - allows a different seek interval)
    static let player_seekBackward_secondary = Notification.Name("player_seekBackward_secondary")

    // Commands the player to seek forward within the currently playing track (secondary seek function - allows a different seek interval)
    static let player_seekForward_secondary = Notification.Name("player_seekForward_secondary")

    // Commands the player to seek to a specific position within the currently playing track
    static let player_jumpToTime = Notification.Name("player_jumpToTime")
    
    // Commands the player to toggle A ⇋ B segment playback loop
    static let player_toggleLoop = Notification.Name("player_toggleLoop")
    
    // ----------------------------------------------------------------------------------------
    
    // MARK: Chapter playback commands (sent to the player)
    
    // Commands the player to play a specific chapter within the currently playing track.
    static let player_playChapter = Notification.Name("player_playChapter")
    
    // Commands the player to play the previous available chapter
    static let player_previousChapter = Notification.Name("player_previousChapter")
    
    // Commands the player to play the next available chapter
    static let player_nextChapter = Notification.Name("player_nextChapter")
    
    // Commands the player to replay the currently playing chapter from the beginning, if there is one
    static let player_replayChapter = Notification.Name("player_replayChapter")
    
    // Commands the player to toggle the current chapter playback loop
    static let player_toggleChapterLoop = Notification.Name("player_toggleChapterLoop")
    
    
    
    // MARK: Other player commands
    
    // Commands the player to save a playback profile (i.e. playback settings) for the current track.
    static let player_savePlaybackProfile = Notification.Name("player_savePlaybackProfile")

    // Commands the player to delete the playback profile (i.e. playback settings) for the current track.
    static let player_deletePlaybackProfile = Notification.Name("player_deletePlaybackProfile")
    
    // ----------------------------------------------------------------------------------------
    
    // MARK: Player sound commands
    
    // Command to mute or unmute the player
    static let player_muteOrUnmute = Notification.Name("player_muteOrUnmute")
    
    // Command to decrease the volume by a certain preset decrement
    static let player_decreaseVolume = Notification.Name("player_decreaseVolume")

    // Command to increase the volume by a certain preset increment
    static let player_increaseVolume = Notification.Name("player_increaseVolume")

    // Command to pan the sound towards the left channel, by a certain preset value
    static let player_panLeft = Notification.Name("player_panLeft")

    // Command to pan the sound towards the right channel, by a certain preset value
    static let player_panRight = Notification.Name("player_panRight")
    
    // ----------------------------------------------------------------------------------------
    
    // MARK: Player sequencing commands
    
    // Commands the player to set the repeat mode (to a specific value)
    static let player_setRepeatMode = Notification.Name("player_setRepeatMode")
    
    // Commands the player to toggle the repeat mode.
    static let player_toggleRepeatMode = Notification.Name("player_toggleRepeatMode")
    
    // Commands the player to set the shuffle mode (to a specific value)
    static let player_setShuffleMode = Notification.Name("player_setShuffleMode")
    
    // Commands the player to toggle the shuffle mode.
    static let player_toggleShuffleMode = Notification.Name("player_toggleShuffleMode")
    
    // ----------------------------------------------------------------------------------------
    
    // MARK: Player view commands
    
    // Commands the player to show or hide album art for the current track.
    static let player_showOrHideAlbumArt = Notification.Name("player_showOrHideAlbumArt")

    // Commands the player to show or hide artist info for the current track.
    static let player_showOrHideArtist = Notification.Name("player_showOrHideArtist")

    // Commands the player to show or hide album info for the current track.
    static let player_showOrHideAlbum = Notification.Name("player_showOrHideAlbum")

    // Commands the player to show or hide the current chapter title for the current track.
    static let player_showOrHideCurrentChapter = Notification.Name("player_showOrHideCurrentChapter")

    // Commands the player to show or hide the main playback controls (i.e. seek bar, play/pause/seek)
    static let player_showOrHideMainControls = Notification.Name("player_showOrHideMainControls")
    
    // Commands the player to show or hide the seek time elapsed/remaining displays.
    static let player_showOrHideTrackTime = Notification.Name("player_showOrHideTrackTime")

    // Commands the player to set the format of the seek time elapsed display to a specific format.
    static let player_setTrackTimeDisplayType = Notification.Name("player_setTrackTimeDisplayType")
    
    // ----------------------------------------------------------------------------------------
    
    // MARK: Playing track function commands
    
    // Commands the player to show detailed info for the currently playing track
    static let player_moreInfo = Notification.Name("player_moreInfo")
    
    // Commands the player to bookmark the current seek position for the currently playing track
    static let player_bookmarkPosition = Notification.Name("player_bookmarkPosition")

    // Commands the player to bookmark the current playback loop (if there is one) for the currently playing track
    static let player_bookmarkLoop = Notification.Name("player_bookmarkLoop")
    
    
    static let trackInfo_refresh = Notification.Name("trackInfo_refresh")
}
