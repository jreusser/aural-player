//
//  LibraryDelegate.swift
//  Aural
//
//  Copyright © 2023 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import Foundation

protocol LibraryDelegateProtocol: GroupedSortedTrackListProtocol {
    
    var buildProgress: LibraryBuildProgress {get}
}

class LibraryDelegate: LibraryDelegateProtocol {
    
    var sortOrder: TrackListSort {
        
        get {library.sortOrder}
        set {library.sortOrder = newValue}
    }
    
    var displayName: String {library.displayName}
    
    private lazy var messenger: Messenger = .init(for: self)
    
    var buildProgress: LibraryBuildProgress {
        library.buildProgress
    }
    
    init() {

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
        messenger.publish(LibraryTracksAddedNotification(trackIndices: indices))
        return indices
    }
    
    func insertTracks(_ tracks: [Track], at insertionIndex: Int) -> IndexSet {
        
        let indices = library.insertTracks(tracks, at: insertionIndex)
        messenger.publish(LibraryTracksAddedNotification(trackIndices: indices))
        return indices
    }
    
    func removeTracks(at indices: IndexSet) -> [Track] {
        
        let removedTracks = library.removeTracks(at: indices)
        messenger.publish(LibraryTracksRemovedNotification(trackIndices: indices))
        return removedTracks
    }
    
    func remove(tracks: [GroupedTrack], andGroups groups: [Group], from grouping: Grouping) -> IndexSet {
        
        let indices = library.remove(tracks: tracks, andGroups: groups, from: grouping)
        messenger.publish(LibraryTracksRemovedNotification(trackIndices: indices))
        return indices
    }
    
    func cropTracks(at indices: IndexSet) {
        library.cropTracks(at: indices)
    }
    
    func cropTracks(_ tracks: [Track]) {
        library.cropTracks(tracks)
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
    
    func sort(grouping: Grouping, by sort: GroupedTrackListSort) {
        library.sort(grouping: grouping, by: sort)
    }
    
    func exportToFile(_ file: URL) {
        library.exportToFile(file)
    }

    // MARK: Notification handling ---------------------------------------------------------------
    
    func appLaunched(_ filesToOpen: [URL]) {
        
        library.buildLibrary()
        // TODO: Monitor a folder ? 'My Music' ???
    }
    
    func appReopened(_ notification: AppReopenedNotification) {
        
        // When a duplicate notification is sent, don't autoplay ! Otherwise, always autoplay.
//        addTracks(from: notification.filesToOpen, AutoplayOptions(!notification.isDuplicateNotification))
        loadTracks(from: notification.filesToOpen)
    }
}
