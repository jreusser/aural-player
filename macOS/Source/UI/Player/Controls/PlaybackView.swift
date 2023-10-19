//
//  PlaybackView.swift
//  Aural
//
//  Copyright © 2023 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

/*
    View that encapsulates all playback-related controls (play/pause, prev/next track, seeking, segment looping).
*/
class PlaybackView: NSView, Destroyable {
    
    // Fields that display/control seek position within the playing track
    @IBOutlet weak var sliderView: SeekSliderView!
   
    // Toggle buttons (their images change)
    @IBOutlet weak var btnPlayPause: NSButton!
    @IBOutlet weak var btnLoop: NSButton!
    
    // Buttons whose tool tips may change
    @IBOutlet weak var btnPreviousTrack: NSButton!
    @IBOutlet weak var btnNextTrack: NSButton!
    
    @IBOutlet weak var btnSeekBackward: NSButton!
    @IBOutlet weak var btnSeekForward: NSButton!
    
    private let player: PlaybackDelegateProtocol = playbackDelegate
    
    private lazy var btnPlayPauseStateMachine: ButtonStateMachine<PlaybackState> =
    
    ButtonStateMachine(initialState: player.state,
                       mappings: [
                        ButtonStateMachine.StateMapping(state: .stopped, image: .imgPlay, colorProperty: \.buttonColor, toolTip: "Play"),
                        ButtonStateMachine.StateMapping(state: .playing, image: .imgPause, colorProperty: \.buttonColor, toolTip: "Pause"),
                        ButtonStateMachine.StateMapping(state: .paused, image: .imgPlay, colorProperty: \.buttonColor, toolTip: "Play")
                       ],
                       button: btnPlayPause)
    
    private lazy var btnLoopStateMachine: ButtonStateMachine<PlaybackLoopState> = ButtonStateMachine(initialState: player.playbackLoopState,
                                                                                                     mappings: [
                                                                                                        ButtonStateMachine.StateMapping(state: .none, image: .imgLoop, colorProperty: \.inactiveControlColor, toolTip: "Initiate a segment loop"),
                                                                                                        ButtonStateMachine.StateMapping(state: .started, image: .imgLoopStarted, colorProperty: \.activeControlColor, toolTip: "Complete the segment loop"),
                                                                                                        ButtonStateMachine.StateMapping(state: .complete, image: .imgLoop, colorProperty: \.activeControlColor, toolTip: "Remove the segment loop")
                                                                                                     ],
                                                                                                     button: btnLoop)
    
    // When the buttons are in an "Off" state, they should be tinted according to the system color scheme's off state button color.
//    var offStateTintFunction: TintFunction {{.gray}}
//
//    // When the buttons are in an "On" state, they should be tinted according to the system color scheme's function button color.
//    var onStateTintFunction: TintFunction {{.white}}
    
    var seekSliderValue: Double {sliderView.seekSliderValue}
    
    override func awakeFromNib() {
        
        setUpPreviousTrackAndNextTrackButtonTooltips()
        
        // MARK: Update controls based on current player state
        
        updatePlayPauseButtonState(player.state)
        updateLoopButtonState(player.playbackLoopState)
        
        setUpButtonColorObservation()
    }
    
    func setUpButtonColorObservation() {
        
        colorSchemesManager.registerObservers([btnSeekBackward, btnSeekForward, btnPreviousTrack, btnNextTrack],
                                                          forProperty: \.buttonColor)
    }
    
    func setUpPreviousTrackAndNextTrackButtonTooltips() {
        
        guard let btnPreviousTrack = btnPreviousTrack as? TrackPeekingButton,
              let btnNextTrack = btnNextTrack as? TrackPeekingButton else {
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
    
    func destroy() {
        sliderView.destroy()
    }
    
    // When the playback state changes (e.g. playing -> paused), fields may need to be updated
    func playbackStateChanged(_ newState: PlaybackState) {
        
        updatePlayPauseButtonState(newState)
        sliderView.playbackStateChanged(newState)
    }

    // When the playback loop for the current playing track is changed, the seek slider needs to be updated (redrawn) to show the current loop state
    func playbackLoopChanged(_ playbackLoop: PlaybackLoop?, _ trackDuration: Double) {

        btnLoopStateMachine.setState(player.playbackLoopState)
        sliderView.playbackLoopChanged(playbackLoop, trackDuration)
    }

    func trackChanged(_ playbackState: PlaybackState, _ loop: PlaybackLoop?, _ newTrack: Track?) {
        
        updatePlayPauseButtonState(playbackState)
        btnLoopStateMachine.setState(player.playbackLoopState)
        updatePreviousTrackAndNextTrackButtonTooltips()
        
        sliderView.trackChanged(loop, newTrack)
    }
    
    func updatePlayPauseButtonState(_ newState: PlaybackState) {
        btnPlayPauseStateMachine.setState(newState)
    }
    
    func updateLoopButtonState(_ loopState: PlaybackLoopState) {
        btnLoopStateMachine.setState(loopState)
    }
    
    func updatePreviousTrackAndNextTrackButtonTooltips() {
        
        if let btnPreviousTrack = btnPreviousTrack as? TrackPeekingButton,
           let btnNextTrack = btnNextTrack as? TrackPeekingButton {
            
            [btnPreviousTrack, btnNextTrack].forEach {$0?.updateTooltip()}
        }
    }
    
    func showOrHideTimeElapsedRemaining() {
        sliderView.showOrHideTrackTime()
    }
    
    func updateSeekPosition() {
        sliderView.updateSeekPosition()
    }
    
    func playbackRateChanged(_ rate: Float, _ playbackState: PlaybackState) {
        sliderView.playbackRateChanged(rate, playbackState)
    }
    
    func setTrackTimeDisplayType(_ type: TrackTimeDisplayType) {
        sliderView.setTrackTimeDisplayType(type)
    }
}
