//
//  MenuBarPlaybackView.swift
//  Aural
//
//  Copyright © 2023 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  
import Cocoa

class MenuBarPlaybackView: PlaybackView {
    
    // Constant white color, no changes will be made.
    override func setUpButtonColorObservation() {
        [btnSeekBackward, btnSeekForward, btnPreviousTrack, btnNextTrack].forEach {$0.image?.isTemplate = false}
    }
    
    override func setUpPreviousTrackAndNextTrackButtonTooltips() {
        
        guard let btnPreviousTrack = btnPreviousTrack as? WhiteTrackPeekingButton,
              let btnNextTrack = btnNextTrack as? WhiteTrackPeekingButton else {
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
        
        
//           ButtonStateMachine.StateMapping(state: .none, image: .imgLoop, colorProperty: \.inactiveControlColor, toolTip: "Initiate a segment loop"),
//           ButtonStateMachine.StateMapping(state: .started, image: .imgLoopStarted, colorProperty: \.activeControlColor, toolTip: "Complete the segment loop"),
//           ButtonStateMachine.StateMapping(state: .complete, image: .imgLoop, colorProperty: \.activeControlColor, toolTip: "Remove the segment loop")
    }
    
    override func updatePreviousTrackAndNextTrackButtonTooltips() {
        
        if let btnPreviousTrack = btnPreviousTrack as? TrackPeekingButton,
           let btnNextTrack = btnNextTrack as? TrackPeekingButton {
            
            [btnPreviousTrack, btnNextTrack].forEach {$0?.updateTooltip()}
        }
    }
}
