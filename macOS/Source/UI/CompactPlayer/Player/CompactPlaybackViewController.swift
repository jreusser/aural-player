//
//  CompactPlaybackViewController.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import Foundation

class CompactPlaybackViewController: PlaybackViewController {
    
    override var displaysChapterIndicator: Bool {false}
    
    override func initSubscriptions() {
        
        // MARK: Notifications --------------------------------------------------------------
        
        messenger.subscribe(to: .player_playOrPause, handler: playOrPause)
        messenger.subscribe(to: .player_stop, handler: stop)
        messenger.subscribe(to: .player_replayTrack, handler: replayTrack)
        messenger.subscribe(to: .player_previousTrack, handler: previousTrack)
        messenger.subscribe(to: .player_nextTrack, handler: nextTrack)
        messenger.subscribe(to: .player_seekBackward, handler: seekBackward(_:))
        messenger.subscribe(to: .player_seekForward, handler: seekForward(_:))
        messenger.subscribe(to: .player_jumpToTime, handler: jumpToTime(_:))
        
        messenger.subscribeAsync(to: .player_trackTransitioned, handler: trackTransitioned(_:))
        messenger.subscribe(to: .player_trackNotPlayed, handler: trackNotPlayed(_:))
        
        messenger.subscribe(to: .effects_playbackRateChanged, handler: playbackRateChanged(_:))
        messenger.subscribe(to: .player_playbackLoopChanged, handler: playbackLoopChanged)
        
        messenger.subscribeAsync(to: .player_playTrack, handler: performTrackPlayback(_:))
        
//        messenger.subscribe(to: .applyTheme, handler: (playbackView as! CompactPlaybackView).applyTheme)
    }
    
    func performTrackPlayback(_ command: TrackPlaybackCommandNotification) {
        
        switch command.type {
            
        case .index:
            
            if let index = command.index {
                playbackDelegate.play(index, .defaultParams())
            }
            
        case .track:
            
            if let track = command.track {
                playbackDelegate.play(track, .defaultParams())
            }
        }
    }
}
