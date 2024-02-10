//
//  MenuBarPlaybackView.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  
import Cocoa

class MenuBarPlaybackView: PlaybackView {
    
    // Constant white color, no changes will be made.
    override func setUpButtonColorObservation() {}
    
    override func setUpPreviousTrackAndNextTrackButtonTooltips() {
        
        guard let btnPreviousTrack = btnPreviousTrack as? FillableImageTrackPeekingButton,
              let btnNextTrack = btnNextTrack as? FillableImageTrackPeekingButton else {
                  return
              }
        
        // Button tool tips
        btnPreviousTrack.toolTipFunction = {

            if let prevTrack = playQueueDelegate.peekPrevious() {
                return String(format: "Previous track: '%@'", prevTrack.displayName)
            }

            return nil
        }

        btnNextTrack.toolTipFunction = {

            if let nextTrack = playQueueDelegate.peekNext() {
                return String(format: "Next track: '%@'", nextTrack.displayName)
            }

            return nil
        }

        [btnPreviousTrack, btnNextTrack].forEach {$0?.updateTooltip()}
    }

    override func updatePlayPauseButtonState(_ newState: PlaybackState) {
        (btnPlayPause as? WhiteImageButton)?.baseImage = newState == .playing ? .imgPause : .imgPlay
    }
    
    override func updateLoopButtonState(_ loopState: PlaybackLoopState) {
        
        guard let btnLoop = btnLoop as? FillableImageButton else {return}
        
        switch loopState {
            
        case .none:
            btnLoop.fill(image: .imgLoop, withColor: .darkGray)
            
        case .started:
            btnLoop.fill(image: .imgLoopStarted, withColor: .white)
            
        case .complete:
            btnLoop.fill(image: .imgLoop, withColor: .white)
        }
    }
    
    override func updatePreviousTrackAndNextTrackButtonTooltips() {
        
        if let btnPreviousTrack = btnPreviousTrack as? TrackPeekingButton,
           let btnNextTrack = btnNextTrack as? TrackPeekingButton {
            
            [btnPreviousTrack, btnNextTrack].forEach {$0?.updateTooltip()}
        }
    }
}
