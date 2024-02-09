//
//  WindowedModePlaybackViewController.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  
import Cocoa

class WindowedModePlaybackViewController: PlaybackViewController {
    
    override func initSubscriptions() {
        
        // MARK: Notifications --------------------------------------------------------------
        
        messenger.subscribeAsync(to: .player_trackTransitioned, handler: trackTransitioned(_:))
        messenger.subscribe(to: .player_trackNotPlayed, handler: trackNotPlayed(_:))
        
        messenger.subscribe(to: .effects_playbackRateChanged, handler: playbackRateChanged(_:))
        messenger.subscribe(to: .player_playbackLoopChanged, handler: playbackLoopChanged)
        
        // MARK: Commands --------------------------------------------------------------
        
        messenger.subscribeAsync(to: .player_playTrack, handler: performTrackPlayback(_:))
        
        messenger.subscribe(to: .player_playOrPause, handler: playOrPause)
        messenger.subscribe(to: .player_stop, handler: stop)
        messenger.subscribe(to: .player_previousTrack, handler: previousTrack)
        messenger.subscribe(to: .player_nextTrack, handler: nextTrack)
        messenger.subscribe(to: .player_replayTrack, handler: replayTrack)
        messenger.subscribe(to: .player_seekBackward, handler: seekBackward(_:))
        messenger.subscribe(to: .player_seekForward, handler: seekForward(_:))
        messenger.subscribe(to: .player_seekBackward_secondary, handler: seekBackward_secondary)
        messenger.subscribe(to: .player_seekForward_secondary, handler: seekForward_secondary)
        messenger.subscribe(to: .player_jumpToTime, handler: jumpToTime(_:))
        messenger.subscribe(to: .player_toggleLoop, handler: toggleLoop)
        
        messenger.subscribe(to: .player_playChapter, handler: playChapter(_:))
        messenger.subscribe(to: .player_previousChapter, handler: previousChapter)
        messenger.subscribe(to: .player_nextChapter, handler: nextChapter)
        messenger.subscribe(to: .player_replayChapter, handler: replayChapter)
        messenger.subscribe(to: .player_toggleChapterLoop, handler: toggleChapterLoop)
        
        messenger.subscribe(to: .player_showOrHideTrackTime, handler: playbackView.showOrHideTimeElapsedRemaining)
        messenger.subscribe(to: .player_setTrackTimeDisplayType, handler: playbackView.setTrackTimeDisplayType(_:))
        
        guard let playbackView = self.playbackView as? WindowedModePlaybackView else {return}
        
        messenger.subscribe(to: .applyTheme, handler: playbackView.applyTheme)
    }
    
    func performTrackPlayback(_ command: TrackPlaybackCommandNotification) {
        
        switch command.type {
            
        case .index:
            
            if let index = command.index {
                playTrackWithIndex(index)
            }
            
        case .track:
            
            if let track = command.track {
                playTrack(track)
            }
        }
    }
    
    func playTrackWithIndex(_ trackIndex: Int) {
        player.play(trackIndex, .defaultParams())
    }
    
    func playTrack(_ track: Track) {
        player.play(track, .defaultParams())
    }
    
    // Returns a view that marks the current position of the seek slider knob.
    var seekPositionMarkerView: NSView! {
        
        (playbackView as? WindowedModePlaybackView)?.positionSeekPositionMarkerView()
        return (playbackView as? WindowedModePlaybackView)?.seekPositionMarker
    }
    
    // MARK: Chapter playback functions ------------------------------------------------------------
    
    private func loopChanged() {
        playbackView.playbackLoopChanged(player.playbackLoop, player.playingTrack?.duration ?? 0)
    }
    
    func playChapter(_ index: Int) {
        
        player.playChapter(index)
        loopChanged()
        playbackView.playbackStateChanged(player.state)
    }
    
    func previousChapter() {
        
        player.previousChapter()
        loopChanged()
        playbackView.playbackStateChanged(player.state)
    }
    
    func nextChapter() {
        
        player.nextChapter()
        loopChanged()
        playbackView.playbackStateChanged(player.state)
    }
    
    func replayChapter() {
        
        player.replayChapter()
        playbackView.updateSeekPosition()
        playbackView.playbackStateChanged(player.state)
    }
    
    func toggleChapterLoop() {
        
        _ = player.toggleChapterLoop()
        loopChanged()
        
        messenger.publish(.player_playbackLoopChanged)
    }
}
