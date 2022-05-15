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
import OrderedCollections

class TrackList: AbstractTrackListProtocol, TrackLoaderReceiver, Sequence {
    
    static let empty: TrackList = .init()
    
    /// A type representing the sequence's elements.
    typealias Element = Track
    
    typealias Iterator = TrackListIterator
    
    // TODO: Consider using OrderedSet instead of []. It will eliminate the need for the tracksByFile [:].
    var tracks: [Track] = []
    
    // A map to quickly look up tracks by (absolute) file path (used when adding tracks, to prevent duplicates)
    private var tracksByFile: [URL: Track] = [:]
    
    private var _isBeingModified: AtomicBool = AtomicBool(value: false)
    
    var isBeingModified: Bool {
        _isBeingModified.value
    }
    
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
    subscript(index: Int) -> Track? {
        
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
        tracksByFile[track.file] != nil
    }
    
    func hasTrack(forFile file: URL) -> Bool {
        tracksByFile[file] != nil
    }
    
    func findTrack(forFile file: URL) -> Track? {
        tracksByFile[file]
    }
    
    private func deDupeTracks(_ tracks: [Track]) -> [Track] {
        OrderedSet<Track>(tracks).filter {!hasTrack($0)}
    }
    
    @discardableResult func addTracks(_ newTracks: [Track]) -> ClosedRange<Int> {
        
        let dedupedTracks = deDupeTracks(newTracks)
        
        for track in dedupedTracks {
            tracksByFile[track.file] = track
        }
        
        return dedupedTracks.isNonEmpty ? tracks.addItems(dedupedTracks) : -1...(-1)
    }
    
    @discardableResult func insertTracks(_ newTracks: [Track], at insertionIndex: Int) -> ClosedRange<Int> {
        
        let dedupedTracks = deDupeTracks(newTracks)
        guard dedupedTracks.isNonEmpty else {return -1...(-1)}
        
        tracks.insert(contentsOf: dedupedTracks, at: insertionIndex)
        
        for track in dedupedTracks {
            tracksByFile[track.file] = track
        }
        
        return insertionIndex...(insertionIndex + dedupedTracks.lastIndex)
    }
    
    @discardableResult func moveTracksUp(from indices: IndexSet) -> [TrackMoveResult] {
        tracks.moveItemsUp(from: indices).map {TrackMoveResult($0.key, $0.value)}
    }
    
    @discardableResult func moveTracksToTop(from indices: IndexSet) -> [TrackMoveResult] {
        tracks.moveItemsToTop(from: indices).map {TrackMoveResult($0.key, $0.value)}
    }
    
    @discardableResult func moveTracksToBottom(from indices: IndexSet) -> [TrackMoveResult] {
        tracks.moveItemsToBottom(from: indices).map {TrackMoveResult($0.key, $0.value)}
    }
    
    @discardableResult func moveTracksDown(from indices: IndexSet) -> [TrackMoveResult] {
        tracks.moveItemsDown(from: indices).map {TrackMoveResult($0.key, $0.value)}
    }
    
    func removeAllTracks() {
        
        tracks.removeAll()
        tracksByFile.removeAll()
    }
    
    @discardableResult func removeTracks(_ tracksToRemove: [Track]) -> IndexSet {
        
        for track in tracksToRemove {
            
            // Add a mapping by track's file path.
            tracksByFile.removeValue(forKey: track.file)
        }
        
        return tracks.removeItems(tracksToRemove)
    }
    
    @discardableResult func removeTracks(at indices: IndexSet) -> [Track] {
        
        let removedTracks = tracks.removeItems(at: indices)
        
        for track in removedTracks {
            
            // Add a mapping by track's file path.
            tracksByFile.removeValue(forKey: track.file)
        }
        
        return removedTracks
    }
    
    @discardableResult func moveTracks(from sourceIndices: IndexSet, to dropIndex: Int) -> [TrackMoveResult] {
        tracks.dragAndDropItems(sourceIndices, dropIndex).map {TrackMoveResult($0.key, $0.value)}
    }
    
//    // TODO:
//    func search(_ searchQuery: SearchQuery) -> SearchResults {
//        SearchResults([])
//    }
//
    func sort(_ sort: TrackListSort) {
        tracks.sort(by: sort.comparator)
    }
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
    
    // MARK: TrackLoaderReceiver ---------------------------------------------------------------------------
    
    func loadTracks(from files: [URL], atPosition position: Int?, usingLoader loader: TrackLoader, observer: TrackLoaderObserver) {
        
        let dedupedFiles = files.filter {tracksByFile[$0] == nil}
        guard dedupedFiles.isNonEmpty else {return}
        
        _isBeingModified.setValue(true)
        
        loader.loadMetadata(ofType: .primary, from: dedupedFiles, into: self, at: position, observer: observer) {[weak self] in
            self?._isBeingModified.setValue(false)
        }
    }

    func acceptBatch(_ batch: FileMetadataBatch) -> ClosedRange<Int> {
        
        let tracks = batch.orderedMetadata.map {(file, metadata) -> Track in
            
            let track = Track(file, fileMetadata: metadata)

            do {
                try trackReader.computePlaybackContext(for: track)
            } catch {}

            return track
        }
        
        if let insertionIndex = batch.insertionIndex {
            return insertTracks(tracks, at: insertionIndex)
            
        } else {
            return addTracks(tracks)
        }
    }
}
