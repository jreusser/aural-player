//
//  ControlBarPlaybackViewController.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  
import Cocoa

class ControlBarPlaybackViewController: PlaybackViewController {
    
    override var displaysChapterIndicator: Bool {false}
    
    override func initSubscriptions() {
        
        // MARK: Notifications --------------------------------------------------------------
        
        messenger.subscribe(to: .Player.playOrPause, handler: playOrPause)
        messenger.subscribe(to: .Player.stop, handler: stop)
        messenger.subscribe(to: .Player.replayTrack, handler: replayTrack)
        messenger.subscribe(to: .Player.previousTrack, handler: previousTrack)
        messenger.subscribe(to: .Player.nextTrack, handler: nextTrack)
        messenger.subscribe(to: .Player.seekBackward, handler: seekBackward(_:))
        messenger.subscribe(to: .Player.seekForward, handler: seekForward(_:))
        messenger.subscribe(to: .Player.jumpToTime, handler: jumpToTime(_:))
        
        messenger.subscribeAsync(to: .Player.trackTransitioned, handler: trackTransitioned(_:))
        messenger.subscribe(to: .Player.trackNotPlayed, handler: trackNotPlayed(_:))
        
        messenger.subscribe(to: .Effects.playbackRateChanged, handler: playbackRateChanged(_:))
        messenger.subscribe(to: .Player.playbackLoopChanged, handler: playbackLoopChanged)
        
        messenger.subscribe(to: .applyTheme, handler: (playbackView as! ControlBarPlaybackView).applyTheme)
    }
}
