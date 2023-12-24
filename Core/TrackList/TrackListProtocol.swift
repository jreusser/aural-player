//
//  TrackListProtocol.swift
//  Aural
//
//  Copyright © 2023 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import Foundation

protocol AbstractTrackListProtocol {
    
    var displayName: String {get}
    
    // MARK: Read-only functions ------------------------------------------------------------------------
    
    var tracks: [Track] {get}
    var size: Int {get}
    var duration: Double {get}
    
    // Whether or not tracks are being added to the track list (which could be time consuming)
    var isBeingModified: Bool {get}
    
    func indexOfTrack(_ track: Track) -> Int?
    
    func hasTrack(_ track: Track) -> Bool
    
    func hasTrack(forFile file: URL) -> Bool
    
    func findTrack(forFile file: URL) -> Track?
    
    subscript(_ index: Int) -> Track? {get}
    
    subscript(indices: IndexSet) -> [Track] {get}
    
    var summary: (size: Int, totalDuration: Double) {get}
    
    func search(_ searchQuery: SearchQuery) -> SearchResults
    
    // MARK: Add and remove ------------------------------------------------------------------------
    
    @discardableResult func addTracks(_ newTracks: [Track]) -> IndexSet
    
    // Inserts tracks from an external source (eg. saved playlist) at a given insertion index.
    func insertTracks(_ tracks: [Track], at insertionIndex: Int) -> IndexSet
    
    func removeTracks(at indices: IndexSet) -> [Track]
    
    func cropTracks(at indices: IndexSet)
    
    func cropTracks(_ tracks: [Track])
    
    func removeAllTracks()
    
    // MARK: Reordering ------------------------------------------------------------------------

    func moveTracksUp(from indices: IndexSet) -> [TrackMoveResult]
    
    func moveTracksToTop(from indices: IndexSet) -> [TrackMoveResult]
    
    func moveTracksDown(from indices: IndexSet) -> [TrackMoveResult]
    
    func moveTracksToBottom(from indices: IndexSet) -> [TrackMoveResult]
    
    func moveTracks(from sourceIndices: IndexSet, to dropIndex: Int) -> [TrackMoveResult]
    
    func sort(_ sort: TrackListSort)

    func sort(by comparator: (Track, Track) -> Bool)
    
    // MARK: Miscellaneous ------------------------------------------------------------------------
    
    func exportToFile(_ file: URL)
}

protocol SortedAbstractTrackListProtocol: AbstractTrackListProtocol {
    
    var sortOrder: TrackListSort {get set}
}

// TODO: Clean up the protocol hierarchy !!!
protocol GroupedSortedAbstractTrackListProtocol: SortedAbstractTrackListProtocol {
    
    func remove(tracks: [GroupedTrack], andGroups groups: [Group], from grouping: Grouping) -> IndexSet
    
    func sort(grouping: Grouping, by sort: GroupedTrackListSort)
}

protocol TrackListProtocol: AbstractTrackListProtocol {
    
    func loadTracks(from files: [URL], atPosition position: Int?)
}

extension TrackListProtocol {
    
    func loadTracks(from files: [URL]) {
        loadTracks(from: files, atPosition: nil)
    }
}

protocol GroupedSortedTrackListProtocol: GroupedSortedAbstractTrackListProtocol, TrackListProtocol {}
