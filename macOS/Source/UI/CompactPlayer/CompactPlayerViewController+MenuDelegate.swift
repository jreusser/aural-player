//
//  CompactPlayerViewController+MenuDelegate.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import AppKit

extension CompactPlayerViewController: NSMenuDelegate {
    
    // MARK: View settings menu delegate functions and action handlers -----------------
    
    func menuNeedsUpdate(_ menu: NSMenu) {
        
        showPlayerMenuItem.onIf(compactPlayerUIState.displayedTab == .player)
        showPlayQueueMenuItem.onIf(compactPlayerUIState.displayedTab.equalsOneOf(.playQueue, .search))
        scrollingEnabledMenuItem.onIf(compactPlayerUIState.trackInfoScrollingEnabled)
        showSeekPositionMenuItem.onIf(compactPlayerUIState.showSeekPosition)
        seekPositionDisplayTypeMenuItem.showIf(compactPlayerUIState.showSeekPosition)
        
        if compactPlayerUIState.showSeekPosition {
            
            seekPositionDisplayTypeItems.forEach {$0.off()}
            
            switch playerUIState.trackTimeDisplayType {
                
            case .elapsed:
                
                timeElapsedMenuItem.on()
                
            case .remaining:
                
                timeRemainingMenuItem.on()
                
            case .duration:
                
                trackDurationMenuItem.on()
            }
        }
        
        cornerRadiusStepper.integerValue = compactPlayerUIState.cornerRadius.roundedInt
        lblCornerRadius.stringValue = "\(cornerRadiusStepper.integerValue)px"
        
        print("Set stepper to: \(cornerRadiusStepper.integerValue)")
    }
    
    @IBAction func toggleTrackInfoScrollingAction(_ sender: NSMenuItem) {
        
        compactPlayerUIState.trackInfoScrollingEnabled.toggle()
        textView.scrollingEnabled.toggle()
    }
    
    @IBAction func toggleShowSeekPositionAction(_ sender: NSMenuItem) {
        
        compactPlayerUIState.showSeekPosition.toggle()
        layoutTextView()
    }
    
    @IBAction func changeSeekPositionDisplayTypeAction(_ sender: SeekPositionDisplayTypeMenuItem) {
        
        playerUIState.trackTimeDisplayType = sender.displayType
        seekSliderView.seekPositionDisplayType = sender.displayType
    }
}
