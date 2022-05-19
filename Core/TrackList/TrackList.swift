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
    
    var _tracks: OrderedSet<Track> = OrderedSet()
    
    var tracks: [Track] {
        _tracks.elements
    }
    
    // A map to quickly look up tracks by (absolute) file path (used when adding tracks, to prevent duplicates)
    private var tracksByFile: [URL: Track] = [:]
    
    private var _isBeingModified: AtomicBool = AtomicBool(value: false)
    
    let sortOrder: TrackListSort?
    
    init(sortOrder: TrackListSort? = nil) {
        self.sortOrder = sortOrder
    }
    
    var isBeingModified: Bool {
        _isBeingModified.value
    }
    
    var size: Int {
        _tracks.count
    }
    
    var indices: Range<Int> {
        _tracks.indices
    }
    
    var duration: Double {
        _tracks.reduce(0.0, {(totalSoFar: Double, track: Track) -> Double in totalSoFar + track.duration})
    }
    
    var summary: (size: Int, totalDuration: Double) {
        (size, duration)
    }

    /// Returns an iterator over the elements of this sequence.
    func makeIterator() -> TrackListIterator {
        TrackListIterator(trackList: self)
    }
    
    var isEmpty: Bool {
        _tracks.isEmpty
    }
    
    var isNonEmpty: Bool {
        _tracks.isNonEmpty
    }
    
    /// Safe array access.
    subscript(index: Int) -> Track? {
        
        guard index >= 0, index < _tracks.count else {return nil}
        return _tracks[index]
    }
    
    subscript(indices: IndexSet) -> [Track] {
        indices.compactMap {self[$0]}
    }
    
    func indexOfTrack(_ track: Track) -> Int?  {
        _tracks.firstIndex(of: track)
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
    
    @discardableResult func addTracks(_ newTracks: [Track]) -> IndexSet {
        
        let dedupedTracks = deDupeTracks(newTracks)
        
        guard dedupedTracks.isNonEmpty else {return .empty}
        
        for track in dedupedTracks {
            tracksByFile[track.file] = track
        }
        
        _tracks.append(contentsOf: dedupedTracks)
        
        if let sortOrder = self.sortOrder {
            _tracks.sort(by: sortOrder.comparator)
        }
        
        let newIndices = dedupedTracks.compactMap {_tracks.firstIndex(of: $0)}
        return IndexSet(newIndices)
    }
    
    @discardableResult func insertTracks(_ newTracks: [Track], at insertionIndex: Int) -> IndexSet {
        
        let dedupedTracks = newTracks.filter {!_tracks.contains($0)}
        guard dedupedTracks.isNonEmpty else {return .empty}
        
        // Need to insert in reverse order.
        for index in stride(from: dedupedTracks.lastIndex, through: -1, by: -1) {
            
            let track = dedupedTracks[index]
            _tracks.insert(track, at: insertionIndex)
            tracksByFile[track.file] = track
        }
        
        return IndexSet(insertionIndex..<(insertionIndex + dedupedTracks.count))
    }
    
    @discardableResult func moveTracksUp(from indices: IndexSet) -> [TrackMoveResult] {
        _tracks.moveItemsUp(from: indices).map {TrackMoveResult($0.key, $0.value)}
    }
    
    @discardableResult func moveTracksToTop(from indices: IndexSet) -> [TrackMoveResult] {
        _tracks.moveItemsToTop(from: indices).map {TrackMoveResult($0.key, $0.value)}
    }
    
    @discardableResult func moveTracksToBottom(from indices: IndexSet) -> [TrackMoveResult] {
        _tracks.moveItemsToBottom(from: indices).map {TrackMoveResult($0.key, $0.value)}
    }
    
    @discardableResult func moveTracksDown(from indices: IndexSet) -> [TrackMoveResult] {
        _tracks.moveItemsDown(from: indices).map {TrackMoveResult($0.key, $0.value)}
    }
    
    func removeAllTracks() {
        
        _tracks.removeAll()
        tracksByFile.removeAll()
    }
    
    @discardableResult func removeTracks(_ tracksToRemove: [Track]) -> IndexSet {
        
        for track in tracksToRemove {
            
            // Add a mapping by track's file path.
            tracksByFile.removeValue(forKey: track.file)
        }
        
        return _tracks.removeItems(tracksToRemove)
    }
    
    @discardableResult func removeTracks(at indices: IndexSet) -> [Track] {
        
        let removedTracks = _tracks.removeItems(at: indices)
        
        for track in removedTracks {
            
            // Add a mapping by track's file path.
            tracksByFile.removeValue(forKey: track.file)
        }
        
        return removedTracks
    }
    
    @discardableResult func moveTracks(from sourceIndices: IndexSet, to dropIndex: Int) -> [TrackMoveResult] {
        _tracks.dragAndDropItems(sourceIndices, dropIndex).map {TrackMoveResult($0.key, $0.value)}
    }
    
//    // TODO:
//    func search(_ searchQuery: SearchQuery) -> SearchResults {
//        SearchResults([])
//    }
//
    func sort(_ sort: TrackListSort) {
        _tracks.sort(by: sort.comparator)
    }

    func sort(by comparator: (Track, Track) -> Bool) {
        _tracks.sort(by: comparator)
    }
    
    func exportToFile(_ file: URL) {
        
        // Perform asynchronously, to unblock the main thread
        DispatchQueue.global(qos: .userInitiated).async {
            PlaylistIO.savePlaylist(tracks: self._tracks.elements, toFile: file)
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

    func acceptBatch(_ batch: FileMetadataBatch) -> IndexSet {
        
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

extension IndexSet {
    
    static let empty: IndexSet = IndexSet()
}
