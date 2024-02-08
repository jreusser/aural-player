//
//  SeekSliderView.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

/*
   View that encapsulates the seek slider and seek time labels.
*/
class SeekSliderView: NSView, Destroyable, ColorSchemeObserver {
    
    // Fields that display/control seek position within the playing track
    @IBOutlet weak var lblTrackTime: NSTextField!
    
    // Shows the time elapsed for the currently playing track, and allows arbitrary seeking within the track
    @IBOutlet weak var seekSlider: NSSlider!
    @IBOutlet weak var seekSliderCell: SeekSliderCell!
    
    // Timer that periodically updates the seek position slider and label
    var seekTimer: RepeatingTaskExecutor?
    
    // Delegate representing the Time effects unit
    let timeStretchUnit: TimeStretchUnitDelegateProtocol = audioGraphDelegate.timeStretchUnit
    
    // Delegate that conveys all playback requests to the player / playback sequencer
    let player: PlaybackDelegateProtocol = playbackDelegate
    
    var seekSliderValue: Double {seekSlider.doubleValue}
    
    private let seekTimerTaskQueue: SeekTimerTaskQueue = .instance
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        
        initSeekPositionLabels()
        
        // MARK: Update controls based on current player state
        
        initSeekTimer()
        trackChanged(player.playbackLoop, player.playingTrack)
        
        colorSchemesManager.registerPropertyObserver(self, forProperties: [\.activeControlColor, \.inactiveControlColor], changeReceiver: seekSlider)
//        //fontSchemesManager.registerObserver(lblTrackTime, forProperty: \.normalFont)
    }
    
    func destroy() {
        
        seekTimer?.stop()
        seekTimerTaskQueue.destroy()
    }
    
    func initSeekPositionLabels() {
        
        colorSchemesManager.registerSchemeObserver(self)
        colorSchemesManager.registerPropertyObserver(self, forProperty: \.primaryTextColor, changeReceiver: lblTrackTime)
        
        // Allow clicks on the seek time display labels to switch to different display formats.
        lblTrackTime?.addGestureRecognizer(NSClickGestureRecognizer(target: self, action: #selector(self.switchTrackTimeDisplayTypeAction)))
    }
    
    func initSeekTimer() {
        
        let seekTimerInterval = (1000 / (2 * timeStretchUnit.effectiveRate)).roundedInt
        
        seekTimer = RepeatingTaskExecutor(intervalMillis: seekTimerInterval,
                                          task: {[weak self] in
            self?.updateSeekPosition()},
                                          queue: .main)
    }
    
    @IBAction func switchTrackTimeDisplayTypeAction(_ sender: Any) {
        
        playerUIState.trackTimeDisplayType = playerUIState.trackTimeDisplayType.toggle()
        setTrackTimeDisplayType(playerUIState.trackTimeDisplayType)
    }
    
    func setTrackTimeDisplayType(_ format: TrackTimeDisplayType) {
        
        updateSeekPosition()
        updateSeekTimerState()
    }
    
    func trackStartedPlaying() {
        
        updateSeekPosition()
        seekSlider.enable()
        seekSlider.show()
        
        showSeekPositionLabels()
    }
    
    func showSeekPositionLabels() {
        
        lblTrackTime.showIf(playerUIState.showTrackTime)
        updateSeekTimerState()
    }
    
    func hideSeekPositionLabels() {
        
        lblTrackTime.hide()
        updateSeekTimerState()
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
                                                                  percentageElapsed: seekPos.percentageElapsed, trackTimeDisplayType: playerUIState.trackTimeDisplayType)
    }
    
    func setSeekTimerState(_ timerOn: Bool) {
        timerOn ? seekTimer?.startOrResume() : seekTimer?.pause()
    }
    
    func updateSeekTimerState() {
        
        var needTimer = false
        let isPlaying = player.state == .playing
        
        if isPlaying {
            
            let hasTasks = seekTimerTaskQueue.hasTasks
            
            let labelShown = playerUIState.showTrackTime
            let trackTimeDisplayType = playerUIState.trackTimeDisplayType
            let trackTimeNotStatic = labelShown && trackTimeDisplayType != .duration
            
            needTimer = hasTasks || trackTimeNotStatic
        }
        
        setSeekTimerState(needTimer)
        print("Updated timer state: \(needTimer)")
    }
    
    // When the playback state changes (e.g. playing -> paused), fields may need to be updated
    func playbackStateChanged(_ newState: PlaybackState) {
        updateSeekTimerState()
    }
    
    // When the playback loop for the current playing track is changed, the seek slider needs to be updated (redrawn) to show the current loop state
    func playbackLoopChanged(_ playbackLoop: PlaybackLoop?, _ trackDuration: Double) {
        
        if let loop = playbackLoop {
            
            // If loop start has not yet been marked, mark it (e.g. when marking chapter loops)
            
            let startPerc = loop.startTime * 100 / trackDuration
            seekSliderCell.markLoopStart(startPerc: startPerc)
            
            // Use the seek slider clone to mark the exact position of the center of the slider knob, at both the start and end points of the playback loop (for rendering)
            if let loopEndTime = loop.endTime {
                
                let endPerc = (loopEndTime / trackDuration) * 100
                seekSliderCell.markLoopEnd(endPerc: endPerc)
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
        
        updateSeekTimerState()
    }
    
    // TODO: Should disable / re-enable the timer when labels are hidden / shown (unnecessary CPU usage), or when showing track duration (which is static).
    func showOrHideTrackTime() {
        
        lblTrackTime.showIf(playerUIState.showTrackTime)
        updateSeekTimerState()
    }
    
    // When the playback rate changes (caused by the Time Stretch effects unit), the seek timer interval needs to be updated, to ensure that the seek position fields are updated fast/slow enough to match the new playback rate.
    func playbackRateChanged(_ rate: Float, _ playbackState: PlaybackState) {
        
        let interval = (1000 / (2 * rate)).roundedInt
        
        if interval != seekTimer?.interval {
            seekTimer?.interval = interval
        }
    }
    
    func colorSchemeChanged() {
        
        seekSlider.redraw()
        lblTrackTime.textColor = systemColorScheme.primaryTextColor
    }
}
