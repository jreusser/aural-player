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

class TrackList: AbstractTrackListProtocol, TrackLoaderReceiver, Sequence {
    
    static let empty: TrackList = .init()
    
    /// A type representing the sequence's elements.
    typealias Element = Track
    
    typealias Iterator = TrackListIterator
    
    private(set) var tracks: [Track] = []
    
    private var _isBeingModified: AtomicBool = AtomicBool(value: false)
    
    var isBeingModified: Bool {
        _isBeingModified.value
    }
    
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
        tracksByFile[track.file] != nil
    }
    
    func hasTrackForFile(_ file: URL) -> Bool {
        tracksByFile[file] != nil
    }
    
    func findTrackByFile(_ file: URL) -> Track? {
        tracksByFile[file]
    }
    
    @discardableResult func addTracks(_ newTracks: [Track]) -> ClosedRange<Int> {
        
        var newTrackIndices: [Int] = []
        
        for track in newTracks {
            
            guard !hasTrack(track) else {continue}
            
            newTrackIndices.append(tracks.addItem(track))
            
            // Add a mapping by track's file path.
            tracksByFile[track.file] = track
        }
        
        return newTrackIndices.isEmpty ? -1...(-1) : newTrackIndices.min()!...newTrackIndices.max()!
    }
    
    @discardableResult func insertTracks(_ newTracks: [Track], at insertionIndex: Int) -> ClosedRange<Int> {
        
        var curInsertionIndex: Int = insertionIndex
        
        for track in newTracks {
            
            guard !hasTrack(track) else {continue}
            
            tracks.insert(track, at: curInsertionIndex.getAndIncrement())
            
            // Add a mapping by track's file path.
            tracksByFile[track.file] = track
        }
        
        return curInsertionIndex == insertionIndex ? -1...(-1) : insertionIndex...(curInsertionIndex - 1)
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
    
    // MARK: TrackLoaderReceiver ---------------------------------------------------------------------------
    
    func loadTracks(from files: [URL], atPosition position: Int?, usingLoader loader: TrackLoader, observer: TrackLoaderObserver) {
        
        _isBeingModified.setValue(true)
        
        let dedupedFiles = files.filter {tracksByFile[$0] == nil}
        guard dedupedFiles.isNonEmpty else {return}
        
        loader.loadMetadata(ofType: .primary, from: dedupedFiles, into: self, at: position, observer: observer) {[weak self] in
            self?._isBeingModified.setValue(false)
        }
    }

    func computeDuration(for files: [URL]) {

    }

    func shouldLoad(file: URL) -> Bool {
        
        // TODO: Should check if we already have a track for this file,
        // then simply duplicate it instead of re-reading the file.

//        if let trackInLibrary = self.library.findTrackByFile(file) {
//
//            _ = playQueue.enqueue([trackInLibrary])
//            return false
//        }

        return true
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
