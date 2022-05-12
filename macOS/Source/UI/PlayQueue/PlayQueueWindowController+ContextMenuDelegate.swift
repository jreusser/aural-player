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

extension PlayQueueWindowController: NSMenuDelegate {
    
    @IBAction func playNextAction(_ sender: NSMenuItem) {
        
        // TODO: Fix off by one error (need to do if-else depending on
        // whether the selected track is above / below the playing track.
        
        guard let selectedTrackIndex = currentViewController.selectedRows.first,
              let indexOfPlayingTrack = playQueueDelegate.currentTrackIndex else {return}
        
        let selectedTrackAbovePlayingTrack: Bool = selectedTrackIndex < indexOfPlayingTrack
        
        let destRow = indexOfPlayingTrack + (selectedTrackAbovePlayingTrack ? 0 : 1)
        
        // No need to do anything if the selected track is already the next
        // track in the play queue.
        guard selectedTrackIndex != destRow else {return}
        
        playQueueDelegate.moveTracks(from: IndexSet([selectedTrackIndex]), to: destRow)
        
        let minRow = min(selectedTrackIndex, destRow)
        let maxRow = max(selectedTrackIndex, destRow)
        currentViewController.reloadTableRows(minRow...maxRow)
        
        // Re-select the track that was moved.
        currentViewController.selectRows([destRow])
    }
    
    @IBAction func moveTracksUpAction(_ sender: NSMenuItem) {
        moveTracksUp()
    }
    
    @IBAction func moveTracksDownAction(_ sender: NSMenuItem) {
        moveTracksDown()
    }
    
    @IBAction func moveTracksToTopAction(_ sender: NSMenuItem) {
        moveTracksToTop()
    }
    
    @IBAction func moveTracksToBottomAction(_ sender: NSMenuItem) {
        moveTracksToBottom()
    }
}
