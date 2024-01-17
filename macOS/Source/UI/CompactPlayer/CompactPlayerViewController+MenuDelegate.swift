//
//  CompactPlayerViewController+MenuDelegate.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import AppKit

extension CompactPlayerViewController: NSMenuDelegate {
    
    // MARK: View settings menu delegate functions and action handlers -----------------
    
    func menuNeedsUpdate(_ menu: NSMenu) {
        
        scrollingEnabledMenuItem.onIf(textView.scrollingEnabled)
        
        showSeekPositionMenuItem.onIf(uiState.showSeekPosition)
        guard uiState.showSeekPosition else {return}

        seekPositionDisplayTypeItems.forEach {$0.off()}

        switch seekSliderView.seekPositionDisplayType {

        case .elapsed:

            timeElapsedMenuItem.on()

        case .remaining:

            timeRemainingMenuItem.on()

        case .duration:

            trackDurationMenuItem.on()
        }
    }
    
    @IBAction func toggleTrackInfoScrollingAction(_ sender: NSMenuItem) {
        textView.scrollingEnabled.toggle()
    }
    
    @IBAction func toggleShowSeekPositionAction(_ sender: NSMenuItem) {
        
        uiState.showSeekPosition.toggle()
        layoutTextView()
    }
    
    @IBAction func changeSeekPositionDisplayTypeAction(_ sender: SeekPositionDisplayTypeMenuItem) {
        seekSliderView.seekPositionDisplayType = sender.displayType
    }
}
