//
//  ControlBarSeekSliderView.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  
import Cocoa

class ControlBarSeekSliderView: SeekSliderView {
    
    private let uiState: ControlBarPlayerUIState = controlBarPlayerUIState
    
    ///
    /// Determines whether or not the seek position needs to be displayed (when a track is playing).
    ///
    var showSeekPosition: Bool = false {
       
        // When the value is updated, need to show / hide the label and update its displayed text.
        didSet {
            
            if player.playingTrack != nil {
                
                updateSeekPosition()
                showSeekPositionLabels()
                return
            }
            
            hideSeekPositionLabels()
        }
    }
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        
        updateSeekPositionLabels(player.seekPosition)
        applyTheme()
    }
    
    override func initSeekPositionLabels() {
        
        lblTrackTime?.addGestureRecognizer(NSClickGestureRecognizer(target: self,
                                                                       action: #selector(self.switchTrackTimeDisplayTypeAction)))
    }
    
//    @objc func switchSeekPositionDisplay() {
//        
//        playerUIState.trackTimeDisplayType = playerUIState.trackTimeDisplayType.toggle()
//        updateSeekPositionLabels(player.seekPosition)
//        updateSeekTimerState()
//    }
    
    override func showSeekPositionLabels() {
        
        lblTrackTime.showIf(showSeekPosition)
        updateSeekTimerState()
    }
    
    override func hideSeekPositionLabels() {
        
        lblTrackTime.hide()
        updateSeekTimerState()
    }
    
    func applyTheme() {
    }
    
    // When the playback loop for the current playing track is changed, the seek slider needs to be updated (redrawn) to show the current loop state
//    override func playbackLoopChanged(_ playbackLoop: PlaybackLoop?, _ trackDuration: Double) {
//        
////        if let loop = playbackLoop {
////            
////            let startTime = loop.startTime
////            let startPerc = startTime * 100 / trackDuration
////            
////            // If loop start has not yet been marked, mark it (e.g. when marking chapter loops)
//////            seekSliderCell.markLoopStart(CGFloat(startPerc))
////            
////            // Use the seek slider clone to mark the exact position of the center of the slider knob, at both the start and end points of the playback loop (for rendering)
////            if let loopEndTime = loop.endTime {
////
////                let endPerc = loopEndTime * 100 / trackDuration
//////                seekSliderCell.markLoopEnd(CGFloat(endPerc))
////            }
////            
////        } else {
//////            seekSliderCell.removeLoop()
////        }
//
//        seekSlider.redraw()
//        updateSeekPosition()
//    }
}
