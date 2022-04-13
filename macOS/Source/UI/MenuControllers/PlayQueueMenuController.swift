//
//  PlayQueueMenuController.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import Cocoa

class PlayQueueMenuController: NSObject, NSMenuDelegate {
    
    private lazy var alertDialog: AlertWindowController = .instance
    
    private let playQueue: PlayQueueDelegateProtocol = objectGraph.playQueueDelegate
    
    private lazy var messenger = Messenger(for: self)
    
    // Plays the selected play queue track.
    @IBAction func playSelectedTrackAction(_ sender: Any) {
        messenger.publish(.playQueue_playSelectedTrack)
    }
    
    // Shows the file open dialog to let the user select files / folders / playlists (M3U) to add to the play queue.
    @IBAction func addTracksAction(_ sender: Any) {
        messenger.publish(.playQueue_addTracks)
    }
    
    // Exports the play queue as an M3U playlist file.
    @IBAction func exportAsPlaylistFileAction(_ sender: Any) {
        messenger.publish(.playQueue_exportAsPlaylistFile)
    }
    
    // Removes any selected playlist items from the playlist
    @IBAction func removeSelectedTracksAction(_ sender: Any) {
        
        if !checkIfPlayQueueIsBeingModified() {
            messenger.publish(.playQueue_removeTracks)
        }
    }
    
    // Crops track selection.
    @IBAction func cropSelectedTracksAction(_ sender: Any) {
        
        if !checkIfPlayQueueIsBeingModified() {
            messenger.publish(.playQueue_cropSelection)
        }
    }
    
    // Removes all tracks from the play queue.
    @IBAction func removeAllTracksAction(_ sender: Any) {
        
        if !checkIfPlayQueueIsBeingModified() {
            messenger.publish(.playQueue_removeAllTracks)
        }
    }
    
    private func checkIfPlayQueueIsBeingModified() -> Bool {
        
        let playQueueBeingModified = playQueue.isBeingModified
        
        if playQueueBeingModified {
            alertDialog.showAlert(.error, "Play Queue not modified", "The Play Queue cannot be modified while tracks are being added", "Please wait till the Play Queue is done adding tracks ...")
        }
        
        return playQueueBeingModified
    }
}
