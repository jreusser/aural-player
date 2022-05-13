//
//  PlayQueueWindowController+ContextMenuDelegate.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import Cocoa

extension PlayQueueWindowController {
    
    func playNext() {
        
        guard let selectedTrackIndex = currentViewController.selectedRows.first,
              let indexOfPlayingTrack = playQueueDelegate.currentTrackIndex else {return}
        
        let selectedTrackAbovePlayingTrack: Bool = selectedTrackIndex < indexOfPlayingTrack
        let destRow = indexOfPlayingTrack + (selectedTrackAbovePlayingTrack ? 0 : 1)
        
        playQueueDelegate.moveTracks(from: IndexSet([selectedTrackIndex]), to: destRow)
        
        let minRow = min(selectedTrackIndex, destRow)
        let maxRow = max(selectedTrackIndex, destRow)
        
        controllers.forEach {
            $0.reloadTableRows(minRow...maxRow)
        }
        
        // Re-select the track that was moved.
        currentViewController.selectRows([destRow])
    }
}
