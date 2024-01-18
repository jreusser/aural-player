//
//  SeekSliderView.swift
//  Aural
//
//  Copyright © 2023 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

/*
   View that encapsulates the seek slider and seek time labels.
*/
class SeekSliderView: NSView, Destroyable {
    
    // Fields that display/control seek position within the playing track
    @IBOutlet weak var lblTrackTime: NSTextField!
    
    // Shows the time elapsed for the currently playing track, and allows arbitrary seeking within the track
    @IBOutlet weak var seekSlider: NSSlider!
    @IBOutlet weak var seekSliderCell: SeekSliderCell!
    
    // A clone of the seek slider, used to render the segment playback loop
    @IBOutlet weak var seekSliderClone: NSSlider!
    @IBOutlet weak var seekSliderCloneCell: SeekSliderCell!
    
    // Timer that periodically updates the seek position slider and label
    var seekTimer: RepeatingTaskExecutor?
    
    // Delegate representing the Time effects unit
    let timeStretchUnit: TimeStretchUnitDelegateProtocol = audioGraphDelegate.timeStretchUnit
    
    // Delegate that conveys all playback requests to the player / playback sequencer
    let player: PlaybackDelegateProtocol = playbackDelegate
    
    private lazy var uiState: PlayerUIState = playerUIState
    
    var seekSliderValue: Double {seekSlider.doubleValue}
    
    private let seekTimerTaskQueue: SeekTimerTaskQueue = .instance
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        
        initSeekPositionLabels()
        
        // MARK: Update controls based on current player state
        
        initSeekTimer()
        trackChanged(player.playbackLoop, player.playingTrack)
        
        colorSchemesManager.registerSchemeObserver(seekSlider, forProperties: [\.backgroundColor, \.activeControlColor, \.inactiveControlColor])
        fontSchemesManager.registerObserver(lblTrackTime, forProperty: \.playerSecondaryFont)
    }
    
    func destroy() {
        
        seekTimer?.stop()
        seekTimerTaskQueue.destroy()
    }
    
    func initSeekPositionLabels() {
        
        colorSchemesManager.registerObserver(lblTrackTime, forProperty: \.primaryTextColor)
        
        // Allow clicks on the seek time display labels to switch to different display formats.
        lblTrackTime?.addGestureRecognizer(NSClickGestureRecognizer(target: self, action: #selector(self.switchTrackTimeDisplayTypeAction)))
    }
    
    func initSeekTimer() {
        
        let seekTimerInterval = (1000 / (2 * timeStretchUnit.effectiveRate)).roundedInt
        
        seekTimer = RepeatingTaskExecutor(intervalMillis: seekTimerInterval,
                                          task: updateSeekPosition,
                                          queue: .main)
    }
    
    @IBAction func switchTrackTimeDisplayTypeAction(_ sender: Any) {
        
        uiState.trackTimeDisplayType = uiState.trackTimeDisplayType.toggle()
        updateSeekPosition()
    }
    
    func setTrackTimeDisplayType(_ format: TrackTimeDisplayType) {
        updateSeekPosition()
    }
    
    func trackStartedPlaying() {
        
        updateSeekPosition()
        seekSlider.enable()
        seekSlider.show()
        
        showSeekPositionLabels()
    }
    
    func showSeekPositionLabels() {
        
        lblTrackTime.showIf(uiState.showTrackTime)
        setSeekTimerState(true)
    }
    
    func hideSeekPositionLabels() {
        
//        lblTrackTime.hide()
        setSeekTimerState(false)
    }
    
    func noTrackPlaying() {
        
        hideSeekPositionLabels()

        seekSlider.hide()
        seekSliderCell.removeLoop()
        seekSlider.doubleValue = 0
        seekSlider.disable()
    }
    
    func updateSeekPosition() {
        
        let seekPosn = player.seekPosition
        seekSlider.doubleValue = seekPosn.percentageElapsed
        
        updateSeekPositionLabels(seekPosn)
        
        for task in seekTimerTaskQueue.tasks {
            task()
        }
    }
    
    func updateSeekPositionLabels(_ seekPos: PlaybackPosition) {
        
        lblTrackTime.stringValue = ValueFormatter.formatTrackTime(elapsedSeconds: seekPos.timeElapsed, duration: seekPos.trackDuration,
                                                                  percentageElapsed: seekPos.percentageElapsed, trackTimeDisplayType: uiState.trackTimeDisplayType)
    }
    
    func setSeekTimerState(_ timerOn: Bool) {
        timerOn ? seekTimer?.startOrResume() : seekTimer?.pause()
    }
    
    // When the playback state changes (e.g. playing -> paused), fields may need to be updated
    func playbackStateChanged(_ newState: PlaybackState) {
        setSeekTimerState(newState == .playing)
    }
    
    // When the playback loop for the current playing track is changed, the seek slider needs to be updated (redrawn) to show the current loop state
    func playbackLoopChanged(_ playbackLoop: PlaybackLoop?, _ trackDuration: Double) {
        
        if let loop = playbackLoop {
            
            // If loop start has not yet been marked, mark it (e.g. when marking chapter loops)
            
            seekSliderClone.doubleValue = loop.startTime * 100 / trackDuration
            seekSliderCell.markLoopStart(seekSliderCloneCell.knobCenter)
            
            // Use the seek slider clone to mark the exact position of the center of the slider knob, at both the start and end points of the playback loop (for rendering)
            if let loopEndTime = loop.endTime {
                
                seekSliderClone.doubleValue = loopEndTime * 100 / trackDuration
                seekSliderCell.markLoopEnd(seekSliderCloneCell.knobCenter)
            }
            
        } else {
            seekSliderCell.removeLoop()
        }

        seekSlider.redraw()
        updateSeekPosition()
    }
    
    func trackChanged(_ loop: PlaybackLoop?, _ newTrack: Track?) {
        
        if let track = newTrack {
            
            playbackLoopChanged(loop, track.duration)
            trackStartedPlaying()
            
        } else {
            noTrackPlaying()
        }
    }
    
    // TODO: Should disable / re-enable the timer when labels are hidden / shown (unnecessary CPU usage), or when showing track duration (which is static).
    func showOrHideTrackTime() {
        lblTrackTime.showIf(uiState.showTrackTime)
    }
    
    // When the playback rate changes (caused by the Time Stretch effects unit), the seek timer interval needs to be updated, to ensure that the seek position fields are updated fast/slow enough to match the new playback rate.
    func playbackRateChanged(_ rate: Float, _ playbackState: PlaybackState) {
        
        let interval = (1000 / (2 * rate)).roundedInt
        
        if interval != seekTimer?.interval {
            seekTimer?.interval = interval
        }
    }
}
