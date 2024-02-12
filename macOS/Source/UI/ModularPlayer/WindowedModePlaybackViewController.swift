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
        
        messenger.subscribeAsync(to: .Player.trackTransitioned, handler: trackTransitioned(_:))
        messenger.subscribe(to: .Player.trackNotPlayed, handler: trackNotPlayed(_:))
        
        messenger.subscribe(to: .Effects.playbackRateChanged, handler: playbackRateChanged(_:))
        messenger.subscribe(to: .Player.playbackLoopChanged, handler: playbackLoopChanged)
        
        // MARK: Commands --------------------------------------------------------------
        
        messenger.subscribeAsync(to: .Player.playTrack, handler: performTrackPlayback(_:))
        
        messenger.subscribe(to: .Player.playOrPause, handler: playOrPause)
        messenger.subscribe(to: .Player.stop, handler: stop)
        messenger.subscribe(to: .Player.previousTrack, handler: previousTrack)
        messenger.subscribe(to: .Player.nextTrack, handler: nextTrack)
        messenger.subscribe(to: .Player.replayTrack, handler: replayTrack)
        messenger.subscribe(to: .Player.seekBackward, handler: seekBackward(_:))
        messenger.subscribe(to: .Player.seekForward, handler: seekForward(_:))
        messenger.subscribe(to: .Player.seekBackward_secondary, handler: seekBackward_secondary)
        messenger.subscribe(to: .Player.seekForward_secondary, handler: seekForward_secondary)
        messenger.subscribe(to: .Player.jumpToTime, handler: jumpToTime(_:))
        messenger.subscribe(to: .Player.toggleLoop, handler: toggleLoop)
        
        messenger.subscribe(to: .Player.playChapter, handler: playChapter(_:))
        messenger.subscribe(to: .Player.previousChapter, handler: previousChapter)
        messenger.subscribe(to: .Player.nextChapter, handler: nextChapter)
        messenger.subscribe(to: .Player.replayChapter, handler: replayChapter)
        messenger.subscribe(to: .Player.toggleChapterLoop, handler: toggleChapterLoop)
        
        messenger.subscribe(to: .Player.showOrHideTrackTime, handler: playbackView.showOrHideTimeElapsedRemaining)
        messenger.subscribe(to: .Player.setTrackTimeDisplayType, handler: playbackView.setTrackTimeDisplayType(_:))
        
        guard let playbackView = self.playbackView as? WindowedModePlaybackView else {return}
        
        messenger.subscribe(to: .applyTheme, handler: playbackView.applyTheme)
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
        
        messenger.publish(.Player.playbackLoopChanged)
    }
}
