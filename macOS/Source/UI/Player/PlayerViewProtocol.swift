//
//  PlayerViewProtocol.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import AppKit

protocol PlayerViewProtocol: FontSchemeObserver, ColorSchemeObserver {
    
    func updateTrackInfo(for track: Track?, playingChapterTitle: String?)
    
    func updateTrackNameText(for track: Track?, playingChapterTitle: String?)
    
    func updateCoverArt(for track: Track?)
    
    func setUpTheming()
    
    func setUpCommandHandling()
    
    func setUpNotificationHandling()
    
    // MARK: Playback actions ---------------------------------------------------------------------------
    
    func togglePlayPauseAction(_ sender: NSButton)
    
    func previousTrackAction(_ sender: NSButton)
    
    func nextTrackAction(_ sender: NSButton)
    
    func seekBackwardAction(_ sender: NSButton)
    
    func seekForwardAction(_ sender: NSButton)
    
    func toggleLoopAction(_ sender: NSButton)
    
    func playChapter(index: Int)
    
    func previousChapter()
    
    func nextChapter()
    
    func replayChapter()
    
    func toggleChapterLoop()
    
    // MARK: Volume actions ---------------------------------------------------------------------------
    
    func volumeAction(_ sender: NSSlider)
    
    func muteOrUnmuteAction(_ sender: NSButton)
    
    // MARK: Sequencing actions ---------------------------------------------------------------------------
    
    func toggleRepeatModeAction(_ sender: NSButton)
    
    func toggleShuffleModeAction(_ sender: NSButton)
    
    func setRepeatMode(to repeatMode: RepeatMode)
    
    func setShuffleMode(to shuffleMode: ShuffleMode)
    
    // MARK: Player view commands ---------------------------------------------------------------------------
    
    func showOrHideAlbumArt()
    
    func showOrHideArtist()
    
    func showOrHideAlbum()
    
    func showOrHideCurrentChapter()
    
    func showOrHideMainControls()
    
    func showOrHideTrackTime()
    
    func toggleTrackTimeDisplayType()
    
    func setTrackTimeDisplayType(to format: TrackTimeDisplayType)
    
    // MARK: Event handling ---------------------------------------------------------------------------
    
    func trackTransitioned(_ notification: TrackTransitionNotification)
    
    func chapterChanged(_ notification: ChapterChangedNotification)
    
    func playingTrackInfoUpdated(_ notification: TrackInfoUpdatedNotification)
    
    func trackNotPlayed(_ notification: TrackNotPlayedNotification)
}
