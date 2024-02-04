//
//  PlayQueueMenuController.swift
//  Aural
//
//  Copyright © 2023 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import Cocoa

class PlayQueueMenuController: NSObject, NSMenuDelegate {
    
    @IBOutlet weak var playSelectedTrackItem: NSMenuItem!
    
    @IBOutlet weak var exportToPlaylistItem: NSMenuItem!
    
    @IBOutlet weak var removeSelectedTracksItem: NSMenuItem!
    @IBOutlet weak var cropSelectedTracksItem: NSMenuItem!
    @IBOutlet weak var removeAllTracksItem: NSMenuItem!
    
    @IBOutlet weak var selectAllTracksItem: NSMenuItem!
    @IBOutlet weak var clearSelectionItem: NSMenuItem!
    @IBOutlet weak var invertSelectionItem: NSMenuItem!
    
    @IBOutlet weak var moveSelectedTracksUpItem: NSMenuItem!
    @IBOutlet weak var moveSelectedTracksToTopItem: NSMenuItem!
    @IBOutlet weak var moveSelectedTracksDownItem: NSMenuItem!
    @IBOutlet weak var moveSelectedTracksToBottomItem: NSMenuItem!
    
    @IBOutlet weak var searchItem: NSMenuItem!
    @IBOutlet weak var sortItem: NSMenuItem!
    
    @IBOutlet weak var pageUpItem: NSMenuItem!
    @IBOutlet weak var pageDownItem: NSMenuItem!
    @IBOutlet weak var scrollToTopItem: NSMenuItem!
    @IBOutlet weak var scrollToBottomItem: NSMenuItem!
    
    private lazy var alertDialog: AlertWindowController = .instance
    
    private let playQueue: PlayQueueDelegateProtocol = playQueueDelegate
    
    private lazy var messenger = Messenger(for: self)
    
    func menuNeedsUpdate(_ menu: NSMenu) {
        
        let selRows = playQueueUIState.selectedRows
        let hasSelRows = selRows.isNonEmpty
        
        let pqSize = playQueueDelegate.size
        let pqHasTracks = pqSize > 0
        let moreThanOneTrack = pqSize > 1
        
        playSelectedTrackItem.enableIf(selRows.count == 1)
        
        [exportToPlaylistItem, removeAllTracksItem, searchItem, 
         pageUpItem, pageDownItem, scrollToTopItem, scrollToBottomItem].forEach {
            
            $0.enableIf(pqHasTracks)
        }
        
        [removeSelectedTracksItem, clearSelectionItem].forEach {
            $0.enableIf(hasSelRows)
        }
        
        [cropSelectedTracksItem, moveSelectedTracksUpItem,
         moveSelectedTracksToTopItem, moveSelectedTracksDownItem, moveSelectedTracksToBottomItem].forEach {
            
            $0.enableIf(hasSelRows && moreThanOneTrack)
        }
        
        sortItem.enableIf(pqSize >= 2)
    }
    
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
    
    // Removes any selected tracks from the play queue
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
    
    @IBAction func selectAllItemsAction(_ sender: Any) {
        messenger.publish(.playQueue_selectAllItems)
    }
    
    // Clears the play queue table view selection.
    @IBAction func clearSelection(_ sender: Any) {
        messenger.publish(.playQueue_clearSelection)
    }
    
    // Inverts the play queue table view selection.
    @IBAction func invertSelection(_ sender: Any) {
        messenger.publish(.playQueue_invertSelection)
    }
    
    // Moves any selected tracks up one row in the play queue
    @IBAction func moveTracksUpAction(_ sender: Any) {
        
        if !checkIfPlayQueueIsBeingModified() {
            messenger.publish(.playQueue_moveTracksUp)
        }
    }
    
    // Moves the selected playlist item up one row in the play queue
    @IBAction func moveTracksToTopAction(_ sender: Any) {
        
        if !checkIfPlayQueueIsBeingModified() {
            messenger.publish(.playQueue_moveTracksToTop)
        }
    }
    
    // Moves any selected tracks down one row in the play queue
    @IBAction func moveTracksDownAction(_ sender: Any) {
        
        if !checkIfPlayQueueIsBeingModified() {
            messenger.publish(.playQueue_moveTracksDown)
        }
    }
    
    // Moves the selected playlist item up one row in the play queue
    @IBAction func moveTracksToBottomAction(_ sender: Any) {
        
        if !checkIfPlayQueueIsBeingModified() {
            messenger.publish(.playQueue_moveTracksToBottom)
        }
    }
    
    // Scrolls the current playlist view to the very top.
    @IBAction func scrollToTopAction(_ sender: Any) {
        messenger.publish(.playQueue_scrollToTop)
    }
    
    // Scrolls the current playlist view to the very bottom.
    @IBAction func scrollToBottomAction(_ sender: Any) {
        messenger.publish(.playQueue_scrollToBottom)
    }
    
    @IBAction func pageUpAction(_ sender: Any) {
        messenger.publish(.playQueue_pageUp)
    }
    
    @IBAction func pageDownAction(_ sender: Any) {
        messenger.publish(.playQueue_pageDown)
    }
    
    @IBAction func searchAction(_ sender: Any) {
        messenger.publish(.playQueue_search)
    }
    
    private func checkIfPlayQueueIsBeingModified() -> Bool {
        
        let playQueueBeingModified = playQueue.isBeingModified
        
        if playQueueBeingModified {
            alertDialog.showAlert(.error, "Play Queue not modified", "The Play Queue cannot be modified while tracks are being added", "Please wait till the Play Queue is done adding tracks ...")
        }
        
        return playQueueBeingModified
    }
}
