//
//  TrackList.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import Foundation

class TrackList: TrackListProtocol, Sequence {
    
    /// A type representing the sequence's elements.
    typealias Element = Track
    
    typealias Iterator = TrackListIterator
    
    private(set) var tracks: [Track] = []
    
    // A map to quickly look up tracks by (absolute) file path (used when adding tracks, to prevent duplicates)
    private var tracksByFile: [URL: Track] = [:]
    
    var size: Int {
        tracks.count
    }
    
    var indices: Range<Int> {
        tracks.indices
    }
    
    var duration: Double {
        tracks.reduce(0.0, {(totalSoFar: Double, track: Track) -> Double in totalSoFar + track.duration})
    }
    
    var summary: (size: Int, totalDuration: Double) {
        (size, duration)
    }

    /// Returns an iterator over the elements of this sequence.
    func makeIterator() -> TrackListIterator {
        TrackListIterator(trackList: self)
    }
    
    var isEmpty: Bool {
        tracks.isEmpty
    }
    
    var isNonEmpty: Bool {
        tracks.isNonEmpty
    }
    
    /// Safe array access.
    subscript(_ index: Int) -> Track? {
        
        guard index >= 0, index < tracks.count else {return nil}
        return tracks[index]
    }
    
    subscript(indices: IndexSet) -> [Track] {
        indices.compactMap {self[$0]}
    }
    
    func indexOfTrack(_ track: Track) -> Int?  {
        tracks.firstIndex(of: track)
    }
    
    func hasTrack(_ track: Track) -> Bool {
        tracks.contains(track)
    }
    
    func hasTrackForFile(_ file: URL) -> Bool {
        tracksByFile[file] != nil
    }
    
    func findTrackByFile(_ file: URL) -> Track? {
        tracksByFile[file]
    }
    
    func addTracks(_ newTracks: [Track]) -> ClosedRange<Int> {
        tracks.addItems(newTracks)
    }
    
    func insertTracks(_ newTracks: [Track], at insertionIndex: Int) -> ClosedRange<Int> {
        
        tracks.insert(contentsOf: newTracks, at: insertionIndex)
        return insertionIndex...(insertionIndex + newTracks.lastIndex)
    }
    
    func moveTracksUp(from indices: IndexSet) -> [TrackMoveResult] {
        tracks.moveItemsUp(from: indices).map {TrackMoveResult($0.key, $0.value)}
    }
    
    func moveTracksToTop(from indices: IndexSet) -> [TrackMoveResult] {
        tracks.moveItemsToTop(from: indices).map {TrackMoveResult($0.key, $0.value)}
    }
    
    func moveTracksToBottom(from indices: IndexSet) -> [TrackMoveResult] {
        tracks.moveItemsToBottom(from: indices).map {TrackMoveResult($0.key, $0.value)}
    }
    
    func moveTracksDown(from indices: IndexSet) -> [TrackMoveResult] {
        tracks.moveItemsDown(from: indices).map {TrackMoveResult($0.key, $0.value)}
    }
    
    func removeAllTracks() {
        tracks.removeAll()
    }
    
    func removeTracks(_ tracksToRemove: [Track]) -> IndexSet {
        tracks.removeItems(tracksToRemove)
    }
    
    func removeTracks(at indices: IndexSet) -> [Track] {
        tracks.removeItems(at: indices)
    }
    
    func moveTracks(from sourceIndices: IndexSet, to dropIndex: Int) -> [TrackMoveResult] {
        tracks.dragAndDropItems(sourceIndices, dropIndex).map {TrackMoveResult($0.key, $0.value)}
    }
    
//    // TODO:
//    func search(_ searchQuery: SearchQuery) -> SearchResults {
//        SearchResults([])
//    }
//
//    // TODO:
//    func sort(_ sort: Sort) -> SortResults {
//        return SortResults(.tracks, .init())
//    }
//
//    func sort(by comparator: (Track, Track) -> Bool) {
//        // TODO:
//    }
    
    func exportToFile(_ file: URL) {
        
        // Perform asynchronously, to unblock the main thread
        DispatchQueue.global(qos: .userInitiated).async {
            PlaylistIO.savePlaylist(tracks: self.tracks, toFile: file)
        }
    }
}
