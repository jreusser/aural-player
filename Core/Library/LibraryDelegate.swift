//
//  LibraryDelegate.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import Foundation

protocol LibraryDelegateProtocol: TrackListProtocol {}

class LibraryDelegate: LibraryDelegateProtocol {
    
    private lazy var messenger: Messenger = .init(for: self)
    
    private let persistentTracks: [URL]?
    
    init(persistentState: LibraryPersistentState?) {

        self.persistentTracks = persistentState?.tracks
        
        // Subscribe to notifications
        messenger.subscribe(to: .application_launched, handler: appLaunched(_:))
        messenger.subscribe(to: .application_reopened, handler: appReopened(_:))
    }
    
    var tracks: [Track] {library.tracks}
    
    var size: Int {library.size}
    
    var duration: Double {library.duration}
    
    var isBeingModified: Bool {library.isBeingModified}
    
    subscript(index: Int) -> Track? {
        library[index]
    }
    
    subscript(indices: IndexSet) -> [Track] {
        library[indices]
    }
    
    var summary: (size: Int, totalDuration: Double) {
        library.summary
    }
    
    func indexOfTrack(_ track: Track) -> Int? {
        library.indexOfTrack(track)
    }
    
    func hasTrack(_ track: Track) -> Bool {
        library.hasTrack(track)
    }
    
    func hasTrack(forFile file: URL) -> Bool {
        library.hasTrack(forFile: file)
    }
    
    func findTrack(forFile file: URL) -> Track? {
        library.findTrack(forFile: file)
    }
    
    func loadTracks(from files: [URL], atPosition position: Int?) {
        library.loadTracks(from: files, atPosition: position)
    }
    
    func addTracks(_ newTracks: [Track]) -> IndexSet {
        
        let indices = library.addTracks(newTracks)
        messenger.publish(LibraryTracksAddedNotification(trackIndices: indices, groupingResults: [:]))
        return indices
    }
    
    func insertTracks(_ tracks: [Track], at insertionIndex: Int) -> IndexSet {
        
        let indices = library.insertTracks(tracks, at: insertionIndex)
        messenger.publish(LibraryTracksAddedNotification(trackIndices: indices, groupingResults: [:]))
        return indices
    }
    
    func removeTracks(at indices: IndexSet) -> [Track] {
        library.removeTracks(at: indices)
    }
    
    func removeAllTracks() {
        library.removeAllTracks()
    }
    
    func moveTracksUp(from indices: IndexSet) -> [TrackMoveResult] {[]}
    
    func moveTracksToTop(from indices: IndexSet) -> [TrackMoveResult] {[]}
    
    func moveTracksDown(from indices: IndexSet) -> [TrackMoveResult] {[]}
    
    func moveTracksToBottom(from indices: IndexSet) -> [TrackMoveResult] {[]}
    
    func moveTracks(from sourceIndices: IndexSet, to dropIndex: Int) -> [TrackMoveResult] {[]}
    
    func sort(_ sort: TrackListSort) {
        library.sortOrder = sort
    }
    
    func sort(by comparator: (Track, Track) -> Bool) {}
    
    func exportToFile(_ file: URL) {
        library.exportToFile(file)
    }

    // MARK: Notification handling ---------------------------------------------------------------
    
    func appLaunched(_ filesToOpen: [URL]) {
        
        // Check if any launch parameters were specified
        if filesToOpen.isNonEmpty {
            
            // Launch parameters  specified, override playlist saved state and add file paths in params to playlist
//            addTracks(from: filesToOpen, AutoplayOptions(true), userAction: false)
            loadTracks(from: filesToOpen)

        } else if let files = self.persistentTracks {

            // No launch parameters specified, load playlist saved state if "Remember state from last launch" preference is selected
//            addFiles_async(tracks, AutoplayOptions(playbackPreferences.autoplayOnStartup), userAction: false, reorderGroupingPlaylists: true)
            loadTracks(from: files)
        }
        
        // TODO: Monitor a folder ? 'My Music' ???
            
//        } else if playlistPreferences.playlistOnStartup == .loadFile,
//                  let playlistFile: URL = playlistPreferences.playlistFile {
//
//            addFiles_async([playlistFile], AutoplayOptions(playbackPreferences.autoplayOnStartup), userAction: false)
//
//        } else if playlistPreferences.playlistOnStartup == .loadFolder,
//                  let folder: URL = playlistPreferences.tracksFolder {
//
//            addFiles_async([folder], AutoplayOptions(playbackPreferences.autoplayOnStartup), userAction: false)
//        }
    }
    
    func appReopened(_ notification: AppReopenedNotification) {
        
        // When a duplicate notification is sent, don't autoplay ! Otherwise, always autoplay.
//        addTracks(from: notification.filesToOpen, AutoplayOptions(!notification.isDuplicateNotification))
        loadTracks(from: notification.filesToOpen)
    }
}
