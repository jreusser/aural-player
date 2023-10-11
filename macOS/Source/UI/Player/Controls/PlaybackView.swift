//
//  PlaybackView.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

/*
    View that encapsulates all playback-related controls (play/pause, prev/next track, seeking, segment looping).
*/
class PlaybackView: NSView {
    
    // Fields that display/control seek position within the playing track
    @IBOutlet weak var sliderView: SeekSliderView!
   
    // Toggle buttons (their images change)
    @IBOutlet weak var btnPlayPause: TintedImageButton!
    @IBOutlet weak var btnLoop: TintedImageButton!
    
    // Buttons whose tool tips may change
    @IBOutlet weak var btnPreviousTrack: TrackPeekingButton!
    @IBOutlet weak var btnNextTrack: TrackPeekingButton!
    
    @IBOutlet weak var btnSeekBackward: TintedImageButton!
    @IBOutlet weak var btnSeekForward: TintedImageButton!
    
    private let player: PlaybackDelegateProtocol = playbackDelegate
    
    private lazy var btnPlayPauseStateMachine: ButtonStateMachine<PlaybackState> = ButtonStateMachine(initialState: player.state,
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
        
//        // Button tool tips
//        btnPreviousTrack.toolTipFunction = {[weak self] in
//
//            if let prevTrack = self?.sequencer.peekPrevious() {
//                return String(format: "Previous track: '%@'", prevTrack.displayName)
//            }
//
//            return nil
//        }
//
//        btnNextTrack.toolTipFunction = {[weak self] in
//
//            if let nextTrack = self?.sequencer.peekNext() {
//                return String(format: "Next track: '%@'", nextTrack.displayName)
//            }
//
//            return nil
//        }

        [btnPreviousTrack, btnNextTrack].forEach {$0?.updateTooltip()}
        
        // MARK: Update controls based on current player state
        
        btnPlayPauseStateMachine.setState(player.state)
        btnLoopStateMachine.setState(player.playbackLoopState)
        
        colorSchemesManager.registerObservers([btnSeekBackward, btnSeekForward, btnPreviousTrack, btnNextTrack],
                                                          forProperty: \.buttonColor)
    }
    
    // When the playback state changes (e.g. playing -> paused), fields may need to be updated
    func playbackStateChanged(_ newState: PlaybackState) {
        
        btnPlayPauseStateMachine.setState(newState)
        sliderView.playbackStateChanged(newState)
    }

    // When the playback loop for the current playing track is changed, the seek slider needs to be updated (redrawn) to show the current loop state
    func playbackLoopChanged(_ playbackLoop: PlaybackLoop?, _ trackDuration: Double) {

        btnLoopStateMachine.setState(player.playbackLoopState)
        sliderView.playbackLoopChanged(playbackLoop, trackDuration)
    }

    func trackChanged(_ playbackState: PlaybackState, _ loop: PlaybackLoop?, _ newTrack: Track?) {
        
        btnPlayPauseStateMachine.setState(playbackState)
        btnLoopStateMachine.setState(player.playbackLoopState)
        [btnPreviousTrack, btnNextTrack].forEach {$0?.updateTooltip()}
        
        sliderView.trackChanged(loop, newTrack)
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
