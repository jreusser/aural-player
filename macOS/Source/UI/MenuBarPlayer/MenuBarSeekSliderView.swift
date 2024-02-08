//
//  MenuBarSeekSliderView.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  
import Cocoa

class MenuBarSeekSliderView: SeekSliderView {
    
    override func initSeekPositionLabels() {
        
        // Allow clicks on the seek time display labels to switch to different display formats.
        lblTrackTime?.addGestureRecognizer(NSClickGestureRecognizer(target: self, action: #selector(self.switchTrackTimeDisplayTypeAction)))
    }
    
    func stopUpdatingSeekPosition() {
        setSeekTimerState(false)
    }
    
    func resumeUpdatingSeekPosition() {
        
        updateSeekPosition()
        setSeekTimerState(true)
    }
}
