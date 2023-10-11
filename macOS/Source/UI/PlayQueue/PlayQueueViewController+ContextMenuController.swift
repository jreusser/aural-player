//
//  PlayQueueViewController+ContextMenuController.swift
//  Aural
//
//  Copyright © 2023 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import Cocoa

extension PlayQueueViewController: NSMenuDelegate {
    
    func menuNeedsUpdate(_ menu: NSMenu) {
        
        let oneRowSelected = selectedRowCount == 1
        let playingTrackSelected = playQueueDelegate.currentTrackIndex == selectedRows.first
        
        [playNowMenuItem, favoritesMenuItem, infoMenuItem].forEach {
            $0.enableIf(oneRowSelected)
        }
        
        playNextMenuItem.enableIf(oneRowSelected && playQueueDelegate.currentTrack != nil && !playingTrackSelected)
        
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
    
    @IBAction func playNowAction(_ sender: NSMenuItem) {
        playSelectedTrack()
    }
    
    @IBAction func playNextAction(_ sender: NSMenuItem) {
        messenger.publish(.playQueue_playNext)
    }
    
    @IBAction func copyTracksToPlaylistAction(_ sender: NSMenuItem) {
        messenger.publish(CopyTracksToPlaylistCommand(tracks: selectedTracks, destinationPlaylistName: sender.title))
    }
    
    @IBAction func createPlaylistWithTracksAction(_ sender: NSMenuItem) {
        messenger.publish(.playlists_createPlaylistFromTracks, payload: selectedTracks)
    }
    
    @IBAction func removeTracksMenuAction(_ sender: Any) {
        messenger.publish(.playQueue_removeTracks)
    }
    
    @IBAction func cropSelectionMenuAction(_ sender: Any) {
        messenger.publish(.playQueue_cropSelection)
    }
    
    @IBAction func moveTracksUpAction(_ sender: Any) {
        messenger.publish(.playQueue_moveTracksUp)
    }
    
    @IBAction func moveTracksDownAction(_ sender: Any) {
        messenger.publish(.playQueue_moveTracksDown)
    }
    
    @IBAction func moveTracksToTopAction(_ sender: Any) {
        messenger.publish(.playQueue_moveTracksToTop)
    }

    @IBAction func moveTracksToBottomAction(_ sender: Any) {
        messenger.publish(.playQueue_moveTracksToBottom)
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
    
    // Shows a popover with detailed information for the currently playing track, if there is one
    @IBAction func trackInfoAction(_ sender: AnyObject) {
        
        // If there is a track currently playing, load detailed track info and toggle the popover view
        guard let selectedTrack = selectedTracks.first else {return}
                
        trackReader.loadAuxiliaryMetadata(for: selectedTrack)
        TrackInfoViewContext.displayedTrack = selectedTrack
        windowLayoutsManager.showWindow(withId: .trackInfo)
    }
    
    // Shows the selected tracks in Finder.
    @IBAction func showInFinderAction(_ sender: NSMenuItem) {
        URL.showInFinder(selectedTracks.map {$0.file})
    }
}
