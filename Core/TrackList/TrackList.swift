//
//  TrackList.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
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
    
    /// Meant to be overriden
    var displayName: String {"Track List"}
    
    /// A map to quickly look up tracks by (absolute) file path (used when adding tracks, to prevent duplicates)
    var _tracks: OrderedDictionary<URL, Track> = OrderedDictionary()
    
    var tracks: [Track] {
        Array(_tracks.values)
    }

    // TODO: Expose this only to subclasses
    var _isBeingModified: AtomicBool = AtomicBool(value: false)
    
    var isBeingModified: Bool {
        _isBeingModified.value
    }
    
    var size: Int {
        _tracks.count
    }
    
    var indices: Range<Int> {
        0..<_tracks.count
    }
    
    var duration: Double {
        _tracks.values.reduce(0.0, {(totalSoFar: Double, track: Track) -> Double in totalSoFar + track.duration})
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
        !isEmpty
    }
    
    /// Safe array access.
    subscript(index: Int) -> Track? {
        
        guard index >= 0, index < _tracks.count else {return nil}
        return _tracks.elements[index].value
    }
    
    subscript(indices: IndexSet) -> [Track] {
        indices.map {_tracks.elements[$0].value}
    }
    
    func indexOfTrack(_ track: Track) -> Int?  {
        _tracks.index(forKey: track.file)
    }
    
    func indexOfTrack(forFile file: URL) -> Int? {
        _tracks.index(forKey: file)
    }
    
    func hasTrack(_ track: Track) -> Bool {
        _tracks[track.file] != nil
    }
    
    func hasTrack(forFile file: URL) -> Bool {
        _tracks[file] != nil
    }
    
    func findTrack(forFile file: URL) -> Track? {
        _tracks[file]
    }

    // TODO: Verify that this actually works (OrderedSet) ... no duplicates !!!
    // Use case - A track and a playlist containing it (M3U) are both added.
    
    @inlinable
    @inline(__always)
    func deDupeTracks(_ tracks: [Track]) -> [Track] {
        tracks.filter {_tracks[$0.file] == nil}
    }
    
    @discardableResult func addTracks(_ newTracks: [Track]) -> IndexSet {
        
        let dedupedTracks = deDupeTracks(newTracks)
        guard dedupedTracks.isNonEmpty else {return .empty}
        
        return doAddTracks(dedupedTracks)
    }
    
    @inlinable
    @inline(__always)
    func doAddTracks(_ newTracks: [Track]) -> IndexSet {
        _tracks.addMappings(newTracks.map {($0.file, $0)})
    }
    
    @discardableResult func insertTracks(_ newTracks: [Track], at insertionIndex: Int) -> IndexSet {
        
        let dedupedTracks = deDupeTracks(newTracks)
        guard dedupedTracks.isNonEmpty else {return .empty}
        
        // Need to insert in reverse order.
        for index in stride(from: dedupedTracks.lastIndex, through: 0, by: -1) {
            
            let track = dedupedTracks[index]
            _tracks.insertItem(track, forKey: track.file, at: insertionIndex)
        }
        
        return IndexSet(insertionIndex..<(insertionIndex + dedupedTracks.count))
    }
    
    @discardableResult func moveTracksUp(from indices: IndexSet) -> [TrackMoveResult] {
        _tracks.moveItemsUp(from: indices).map {TrackMoveResult($0.key, $0.value)}
    }
    
    @discardableResult func moveTracksDown(from indices: IndexSet) -> [TrackMoveResult] {
        _tracks.moveItemsDown(from: indices).map {TrackMoveResult($0.key, $0.value)}
    }
    
    @discardableResult func moveTracksToTop(from indices: IndexSet) -> [TrackMoveResult] {
        _tracks.moveItemsToTop(from: indices).map {TrackMoveResult($0.key, $0.value)}
    }
    
    @discardableResult func moveTracksToBottom(from indices: IndexSet) -> [TrackMoveResult] {
        _tracks.moveItemsToBottom(from: indices).map {TrackMoveResult($0.key, $0.value)}
    }
    
    func removeAllTracks() {
        _tracks.removeAll()
    }
    
    @discardableResult func removeTracks(_ tracksToRemove: [Track]) -> IndexSet {
        
        let indices: [Int] = tracksToRemove.compactMap {_tracks.index(forKey: $0.file)}
        
        for track in tracksToRemove {
            
            // Add a mapping by track's file path.
            _tracks.removeValue(forKey: track.file)
        }
        
        return IndexSet(indices)
    }
    
    @discardableResult func removeTracks(at indices: IndexSet) -> [Track] {
        _tracks.removeItems(at: indices)
    }
    
    func cropTracks(at indices: IndexSet) {
        cropTracks(self[indices])
    }
    
    func cropTracks(_ tracks: [Track]) {
        
        let tracksToKeep: Set<Track> = Set(tracks)
        let tracksToRemove: [Track] = _tracks.values.filter {!tracksToKeep.contains($0)}
        removeTracks(tracksToRemove)
    }
    
    @discardableResult func moveTracks(from sourceIndices: IndexSet, to dropIndex: Int) -> [TrackMoveResult] {
        _tracks.dragAndDropItems(sourceIndices, dropIndex).map {TrackMoveResult($0.key, $0.value)}
    }
    
    // TODO:
    func search(_ searchQuery: SearchQuery) -> SearchResults {
        SearchResults(scope: .all, [])
    }

    func sort(_ sort: TrackListSort) {
        
        _tracks.sort(by: {m1, m2 in
            sort.comparator(m1.value, m2.value)
        })
    }

    func sort(by comparator: (Track, Track) -> Bool) {
        
        _tracks.sort(by: {m1, m2 in
            comparator(m1.value, m2.value)
        })
    }
    
    func exportToFile(_ file: URL) {
        
        // Perform asynchronously, to unblock the main thread
        DispatchQueue.global(qos: .userInitiated).async {
            PlaylistIO.savePlaylist(tracks: self.tracks, toFile: file)
        }
    }
    
    // MARK: TrackLoaderReceiver ---------------------------------------------------------------------------
    
    func loadTracks(from files: [URL], atPosition position: Int?, usingLoader loader: TrackLoader, observer: TrackLoaderObserver) {
        
        _isBeingModified.setValue(true)
        
        loader.loadMetadata(ofType: .primary, from: files, into: self, at: position, observer: observer) {[weak self] in
            self?._isBeingModified.setValue(false)
        }
    }

    func acceptBatch(_ batch: FileMetadataBatch) -> IndexSet {
        
        let orderedMetadata = batch.orderedMetadata
        
        let tracks = orderedMetadata.map {(file, metadata) -> Track in
            
            let track = Track(file, fileMetadata: metadata)

            do {
                try trackReader.computePlaybackContext(for: track)
            } catch {}

            return track
        }
        
        let indices: IndexSet
        
        if let insertionIndex = batch.insertionIndex {
            indices = insertTracks(tracks, at: insertionIndex)
            
        } else {
            indices = addTracks(tracks)
        }
        
        let batchFiles = batch.files.elements.values
        let indicesArray = indices.toArray()
        
        for (index, _) in orderedMetadata.enumerated() {
            batchFiles[index].indexOfFileInTrackList = indicesArray[index]
//            print("File '\(batchFiles[index].file.lastPathComponent)' added to PQ at index: \(batchFiles[index].indexOfFileInTrackList ?? -1)")
        }
        
        return indices
    }
    
    // Dummy impl - subclasses should override!
    func firstFileLoaded(file: URL, atIndex index: Int) {}
}

extension IndexSet {
    
    static let empty: IndexSet = IndexSet()
}
