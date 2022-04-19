//
//  TrackListProtocol.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import Foundation

protocol AbstractTrackListProtocol {
    
    var tracks: [Track] {get}
    var size: Int {get}
    var duration: Double {get}
    
    var isBeingModified: Bool {get}
    
    func indexOfTrack(_ track: Track) -> Int?
    
    func hasTrack(_ track: Track) -> Bool
    
    func hasTrackForFile(_ file: URL) -> Bool
    
    func findTrackByFile(_ file: URL) -> Track?
    
    subscript(_ index: Int) -> Track? {get}
    
    subscript(indices: IndexSet) -> [Track] {get}
    
    var summary: (size: Int, totalDuration: Double) {get}
    
//    func search(_ searchQuery: SearchQuery) -> SearchResults
    
    func addTracks(_ newTracks: [Track]) -> ClosedRange<Int>
    
    // Inserts tracks from an external source (eg. saved playlist) at a given insertion index.
    func insertTracks(_ tracks: [Track], at insertionIndex: Int) -> ClosedRange<Int>
    
    func removeTracks(at indices: IndexSet) -> [Track]

    func moveTracksUp(from indices: IndexSet) -> [TrackMoveResult]
    
    func moveTracksToTop(from indices: IndexSet) -> [TrackMoveResult]
    
    func moveTracksDown(from indices: IndexSet) -> [TrackMoveResult]
    
    func moveTracksToBottom(from indices: IndexSet) -> [TrackMoveResult]
    
    func moveTracks(from sourceIndices: IndexSet, to dropIndex: Int) -> [TrackMoveResult]
    
    func removeAllTracks()
    
//    func sort(_ sort: Sort) -> SortResults
//
//    func sort(by comparator: (Track, Track) -> Bool)
    
    func exportToFile(_ file: URL)
}

protocol TrackListProtocol: AbstractTrackListProtocol {
    
    func loadTracks(from files: [URL], atPosition position: Int?)
}

extension TrackListProtocol {
    
    func loadTracks(from files: [URL]) {
        loadTracks(from: files, atPosition: nil)
    }
}
