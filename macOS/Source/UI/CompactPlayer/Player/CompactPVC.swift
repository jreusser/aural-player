//
//  CompactPVC.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import AppKit

class CompactPVC: CommonPlayerViewController {
    
    override var nibName: NSNib.Name? {"CompactPlayer"}
    
    override var showTrackTime: Bool {
        compactPlayerUIState.showTrackTime
    }
    
    override var displaysChapterIndicator: Bool {
        false
    }
    
    override func updateTrackTextView(for track: Track?, playingChapterTitle: String? = nil) {
        updateScrollingTrackTextView(for: track)
    }
    
    override func updateTrackTextViewFonts() {
        updateScrollingTrackTextViewFonts()
    }
    
    override func updateTrackTextViewColors() {
        updateScrollingTrackTextViewColors()
    }
    
    override func setUpTrackInfoView() {
        setUpScrollingTrackInfoView()
    }
    
    override func showOrHideTrackTime() {
        
        super.showOrHideTrackTime()
        layoutScrollingTrackTextView()
    }
    
    override func setUpScrollingTrackInfoView() {
        
        layoutScrollingTrackTextView()
        scrollingTrackTextView.scrollingEnabled = compactPlayerUIState.trackInfoScrollingEnabled
    }
    
    override func layoutScrollingTrackTextView() {
        
        let showTrackTime: Bool = compactPlayerUIState.showTrackTime
        
        // Seek Position label
//        lblTrackTime.showIf(playbackDelegate.playingTrack != nil && showTrackTime)
//        updateSeekTimerState()
        
        scrollingTextViewContainerBox.setFrameSize(NSSize(width: showTrackTime ? 200 : 280, height: 26))
        scrollingTrackTextView.setFrameSize(NSSize(width: showTrackTime ? 200 : 280, height: 26))
        
        scrollingTrackTextView.update()
    }
    
    @IBAction func toggleTrackInfoScrollingAction(_ sender: NSMenuItem) {
        
        compactPlayerUIState.trackInfoScrollingEnabled = scrollingTrackTextView.scrollingEnabled
        scrollingTrackTextView.scrollingEnabled.toggle()
    }
    
    @IBAction func toggleShowSeekPositionAction(_ sender: NSMenuItem) {
        
        compactPlayerUIState.showTrackTime.toggle()
        layoutScrollingTrackTextView()
    }
    
    @IBAction func changeSeekPositionDisplayTypeAction(_ sender: SeekPositionDisplayTypeMenuItem) {
        
        playerUIState.trackTimeDisplayType = sender.displayType
        setTrackTimeDisplayType(to: playerUIState.trackTimeDisplayType)
    }
}
