//
//  PlayQueueViewController+ContextMenuController.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import Cocoa

class ChapterMenuItem: NSMenuItem {
    
    let index: Int
    
    init(title: String, action: Selector, index: Int) {
        
        self.index = index
        super.init(title: title, action: action, keyEquivalent: "")
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension PlayQueueViewController: NSMenuDelegate {
    
    func menuNeedsUpdate(_ menu: NSMenu) {
        
        let atLeastOneRowSelected = selectedRowCount >= 1
        let oneRowSelected = selectedRowCount == 1
        
        var playingTrackSelected = false
        if let currentTrackIndex = playQueueDelegate.currentTrackIndex, selectedRows.contains(currentTrackIndex) {
            playingTrackSelected = true
        }
        
        playNowMenuItem.showIf(oneRowSelected && (!playingTrackSelected))
        
        [favoriteMenuItem, infoMenuItem].forEach {
            $0.showIf(oneRowSelected)
        }
        
        playNextMenuItem.showIf(atLeastOneRowSelected && playbackInfoDelegate.state.isPlayingOrPaused && !playingTrackSelected)
        
        // TODO: playlist names menu should have a separate delegate so that the menu
        // is not unnecessarily updated until required.
        
        playlistNamesMenu.items.removeAll()
        
        for playlist in playlistsManager.userDefinedObjects {
            playlistNamesMenu.addItem(withTitle: playlist.name, action: #selector(copyTracksToPlaylistAction(_:)), keyEquivalent: "")
        }
        
        chaptersMenu.removeAllItems()
        
        // Update the state of the favorites menu items (based on if the clicked track / group is already in the favorites list or not)
        guard let theClickedTrack = selectedTracks.first else {return}
        
        let clickedPlayingTrack = playbackInfoDelegate.playingTrack == theClickedTrack
        let clickedPlayingTrackAndHasChapters = clickedPlayingTrack && theClickedTrack.hasChapters
        
        viewChaptersListMenuItem.showIf(clickedPlayingTrackAndHasChapters)
        jumpToChapterMenuItem.showIf(clickedPlayingTrackAndHasChapters)
        
        if clickedPlayingTrackAndHasChapters, let playingChapter = playbackInfoDelegate.playingChapter {
            
            let chapters = theClickedTrack.chapters
            
            for (index, chapter) in chapters.enumerated() {
                
                let item = ChapterMenuItem(title: chapter.title, action: #selector(jumpToChapterAction(_:)), index: index)
                item.state = .off
                item.target = self
                chaptersMenu.addItem(item)
            }
            
            chaptersMenu.item(at: playingChapter.index)?.state = .on
        }
        
        [moveTracksUpMenuItem, moveTracksDownMenuItem, moveTracksToTopMenuItem, moveTracksToBottomMenuItem].forEach {
            $0?.showIf(atLeastOneRowSelected)
        }
        
        let titlePrefix = favoritesDelegate.favoriteExists(track: theClickedTrack) ? "Remove" : "Add"
        favoriteTrackMenuItem.title = "\(titlePrefix) this track"
        
        if let artist = theClickedTrack.artist {
            
            let titlePrefix = favoritesDelegate.favoriteExists(artist: artist) ? "Remove" : "Add"
            favoriteArtistMenuItem.title = "\(titlePrefix) artist '\(artist)'"
            favoriteArtistMenuItem.show()
            
        } else {
            favoriteArtistMenuItem.hide()
        }
        
        if let album = theClickedTrack.album {
            
            let titlePrefix = favoritesDelegate.favoriteExists(album: album) ? "Remove" : "Add"
            favoriteAlbumMenuItem.title = "\(titlePrefix) album '\(album)'"
            favoriteAlbumMenuItem.show()
            
        } else {
            favoriteAlbumMenuItem.hide()
        }
        
        if let genre = theClickedTrack.genre {
            
            let titlePrefix = favoritesDelegate.favoriteExists(genre: genre) ? "Remove" : "Add"
            favoriteGenreMenuItem.title = "\(titlePrefix) genre '\(genre)'"
            favoriteGenreMenuItem.show()
            
        } else {
            favoriteGenreMenuItem.hide()
        }
        
        if let decade = theClickedTrack.decade {
            
            let titlePrefix = favoritesDelegate.favoriteExists(decade: decade) ? "Remove" : "Add"
            favoriteDecadeMenuItem.title = "\(titlePrefix) decade '\(decade)'"
            favoriteDecadeMenuItem.show()
            
        } else {
            favoriteDecadeMenuItem.hide()
        }
    }
    
    @IBAction func viewChaptersListAction(_ sender: Any) {
        windowLayoutsManager.showWindow(withId: .chaptersList)
    }
    
    @IBAction func jumpToChapterAction(_ sender: ChapterMenuItem) {
        messenger.publish(.player_playChapter, payload: sender.index)
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
    @IBAction func favoriteTrackAction(_ sender: NSMenuItem) {
        
        guard let theClickedTrack = selectedTracks.first else {return}

        if favoriteTrackMenuItem.isOn {

            // Remove from Favorites list and display notification
            favoritesDelegate.removeFavorite(track: theClickedTrack)

            if let rowView = selectedRowView {
                infoPopup.showMessage("Track removed from Favorites !", rowView, .maxX)
            }

        } else {

            // Add to Favorites list and display notification
            favoritesDelegate.addFavorite(track: theClickedTrack)

            if let rowView = selectedRowView {
                infoPopup.showMessage("Track added to Favorites !", rowView, .maxX)
            }
        }
        
        // If this isn't done, the app windows are hidden when the popover is displayed
        windowLayoutsManager.mainWindow.makeKeyAndOrderFront(self)
    }
    
    // Adds/removes the currently playing track, if there is one, to/from the "Favorites" list
    @IBAction func favoriteArtistAction(_ sender: NSMenuItem) {
        
        guard let theClickedTrack = selectedTracks.first,
        let artist = theClickedTrack.artist else {return}

        if favoriteArtistMenuItem.isOn {

            // Remove from Favorites list and display notification
            favoritesDelegate.removeFavorite(artist: artist)

            if let rowView = selectedRowView {
                infoPopup.showMessage("Artist removed from Favorites !", rowView, .maxX)
            }

        } else {

            // Add to Favorites list and display notification
            favoritesDelegate.addFavorite(artist: artist)

            if let rowView = selectedRowView {
                infoPopup.showMessage("Artist added to Favorites !", rowView, .maxX)
            }
        }
        
        // If this isn't done, the app windows are hidden when the popover is displayed
        windowLayoutsManager.mainWindow.makeKeyAndOrderFront(self)
    }
    
    @IBAction func favoriteAlbumAction(_ sender: NSMenuItem) {
        
        guard let theClickedTrack = selectedTracks.first,
        let album = theClickedTrack.album else {return}

        if favoriteAlbumMenuItem.isOn {

            // Remove from Favorites list and display notification
            favoritesDelegate.removeFavorite(album: album)

            if let rowView = selectedRowView {
                infoPopup.showMessage("Album removed from Favorites !", rowView, .maxX)
            }

        } else {

            // Add to Favorites list and display notification
            favoritesDelegate.addFavorite(album: album)

            if let rowView = selectedRowView {
                infoPopup.showMessage("Album added to Favorites !", rowView, .maxX)
            }
        }
        
        // If this isn't done, the app windows are hidden when the popover is displayed
        windowLayoutsManager.mainWindow.makeKeyAndOrderFront(self)
    }
    
    @IBAction func favoriteGenreAction(_ sender: NSMenuItem) {
        
        guard let theClickedTrack = selectedTracks.first,
        let genre = theClickedTrack.genre else {return}

        if favoriteGenreMenuItem.isOn {

            // Remove from Favorites list and display notification
            favoritesDelegate.removeFavorite(genre: genre)

            if let rowView = selectedRowView {
                infoPopup.showMessage("Genre removed from Favorites !", rowView, .maxX)
            }

        } else {

            // Add to Favorites list and display notification
            favoritesDelegate.addFavorite(genre: genre)

            if let rowView = selectedRowView {
                infoPopup.showMessage("Genre added to Favorites !", rowView, .maxX)
            }
        }
        
        // If this isn't done, the app windows are hidden when the popover is displayed
        windowLayoutsManager.mainWindow.makeKeyAndOrderFront(self)
    }
    
    @IBAction func favoriteDecadeAction(_ sender: NSMenuItem) {
        
        guard let theClickedTrack = selectedTracks.first,
        let decade = theClickedTrack.decade else {return}

        if favoriteDecadeMenuItem.isOn {

            // Remove from Favorites list and display notification
            favoritesDelegate.removeFavorite(decade: decade)

            if let rowView = selectedRowView {
                infoPopup.showMessage("Decade removed from Favorites !", rowView, .maxX)
            }

        } else {

            // Add to Favorites list and display notification
            favoritesDelegate.addFavorite(decade: decade)

            if let rowView = selectedRowView {
                infoPopup.showMessage("Decade added to Favorites !", rowView, .maxX)
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
        
        if windowLayoutsManager.isWindowLoaded(withId: .trackInfo) {
            messenger.publish(.trackInfo_refresh)
        }
        
        windowLayoutsManager.showWindow(withId: .trackInfo)
    }
    
    // Shows the selected tracks in Finder.
    @IBAction func showInFinderAction(_ sender: NSMenuItem) {
        URL.showInFinder(selectedTracks.map {$0.file})
    }
}
