//
//  TrackListTableViewController+Actions.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import AppKit

extension TrackListTableViewController {
    
    @IBAction func importFilesAndFoldersAction(_ sender: NSButton) {
        importFilesAndFolders()
    }
    
    @IBAction func removeTracksAction(_ sender: NSButton) {
        removeTracks()
    }
    
    @IBAction func cropSelectionAction(_ sender: Any) {
        cropSelection()
    }
    
    @IBAction func removeAllTracksAction(_ sender: NSButton) {
        removeAllTracks()
    }
    
    // MARK: Table view selection manipulation
    
    @IBAction func clearSelectionAction(_ sender: NSButton) {
        clearSelection()
    }
    
    @IBAction func invertSelectionAction(_ sender: NSButton) {
        invertSelection()
    }
    
    @IBAction func exportToPlaylistAction(_ sender: NSButton) {
        exportTrackList()
    }
    
    @IBAction func sortByTrackNameAction(_ sender: NSMenuItem) {
        doSort(by: [.name])
    }
    
    @IBAction func sortByArtistAlbumDiscTrackNumberAction(_ sender: NSMenuItem) {
        doSort(by: [.artist, .album, .discNumberAndTrackNumber])
    }
    
    @IBAction func sortByArtistAlbumTrackNameAction(_ sender: NSMenuItem) {
        doSort(by: [.artist, .album, .name])
    }
    
    @IBAction func sortByArtistTrackNameAction(_ sender: NSMenuItem) {
        doSort(by: [.artist, .name])
    }
    
    @IBAction func sortByAlbumDiscTrackNumberAction(_ sender: NSMenuItem) {
        doSort(by: [.album, .discNumberAndTrackNumber])
    }
    
    @IBAction func sortByAlbumTrackNameAction(_ sender: NSMenuItem) {
        doSort(by: [.album, .name])
    }
    
    @IBAction func sortByDurationAction(_ sender: NSMenuItem) {
        doSort(by: [.duration])
    }
    
    @IBAction func pageUpAction(_ sender: NSButton) {
        pageUp()
    }
    
    @IBAction func pageDownAction(_ sender: NSButton) {
        pageDown()
    }
    
    @IBAction func scrollToTopAction(_ sender: NSButton) {
        scrollToTop()
    }
    
    @IBAction func scrollToBottomAction(_ sender: NSButton) {
        scrollToBottom()
    }
}
