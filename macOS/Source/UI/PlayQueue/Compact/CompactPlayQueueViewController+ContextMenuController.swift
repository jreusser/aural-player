//
//  CompactPlayQueueViewController+ContextMenuController.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import Cocoa

extension CompactPlayQueueViewController: NSMenuDelegate {
    
    func menuNeedsUpdate(_ menu: NSMenu) {
        
        let oneRowSelected = selectedRowCount == 1
        
        [playNowMenuItem, favoritesMenuItem, infoMenuItem].forEach {
            $0.enableIf(oneRowSelected)
        }
        
        playNextMenuItem.enableIf(oneRowSelected && playQueueDelegate.currentTrack != nil)
        
        // TODO: playlist names menu should have a separate delegate so that the menu
        // is not unnecessarily updated until required.
        
        playlistNamesMenu.items.removeAll()
        
        for playlist in playlistsManager.userDefinedObjects {
            playlistNamesMenu.addItem(withTitle: playlist.name, action: #selector(copyTracksToPlaylistAction(_:)), keyEquivalent: "")
        }
        
        // Update the state of the favorites menu item (based on if the clicked track is already in the favorites list or not)
        if let theClickedTrack = selectedTracks.first {
            favoritesMenuItem.onIf(favoritesDelegate.favoriteWithFileExists(theClickedTrack.file))
        }
    }
    
    @IBAction func playNextAction(_ sender: NSMenuItem) {
        
        guard let selectedTrackIndex = selectedRows.first,
              let indexOfPlayingTrack = playQueueDelegate.currentTrackIndex else {return}
        
        let destRow = indexOfPlayingTrack + 1
        
        // No need to do anything if the selected track is already the next
        // track in the play queue.
        guard selectedTrackIndex != destRow else {return}
        
        playQueueDelegate.moveTracks(from: IndexSet([selectedTrackIndex]), to: destRow)
        
        let minRow = min(selectedTrackIndex, destRow)
        let maxRow = max(selectedTrackIndex, destRow)
        tableView.reloadRows(minRow...maxRow)
        
        // Re-select the track that was moved.
        tableView.selectRow(destRow)
    }
    
    @IBAction func copyTracksToPlaylistAction(_ sender: NSMenuItem) {
        messenger.publish(CopyTracksToPlaylistCommand(tracks: selectedTracks, destinationPlaylistName: sender.title))
    }
    
    @IBAction func createPlaylistWithTracksAction(_ sender: NSMenuItem) {
        messenger.publish(.playlists_createPlaylistFromTracks, payload: selectedTracks)
    }
    
    // Adds/removes the currently playing track, if there is one, to/from the "Favorites" list
    @IBAction func favoritesAction(_ sender: NSMenuItem) {
        
        guard let theClickedTrack = selectedTracks.first else {return}

        if favoritesMenuItem.isOn {

            // Remove from Favorites list and display notification
            favoritesDelegate.deleteFavoriteWithFile(theClickedTrack.file)

            if let rowView = selectedRowView {
                infoPopup.showMessage("Track removed from Favorites !", rowView, .maxX)
            }

        } else {

            // Add to Favorites list and display notification
            _ = favoritesDelegate.addFavorite(theClickedTrack)

            if let rowView = selectedRowView {
                infoPopup.showMessage("Track added to Favorites !", rowView, .maxX)
            }
        }
        
        // If this isn't done, the app windows are hidden when the popover is displayed
        windowLayoutsManager.mainWindow.makeKeyAndOrderFront(self)
    }
    
    // Shows the selected tracks in Finder.
    @IBAction func showInFinderAction(_ sender: NSMenuItem) {
        URL.showInFinder(selectedTracks.map {$0.file})
    }
}
