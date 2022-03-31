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

class TrackList: Sequence {
    
    /// A type representing the sequence's elements.
    typealias Element = Track
    
    typealias Iterator = TrackListIterator
    
    private(set) var tracks: [Track] = []
    
    var size: Int {
        tracks.count
    }
    
    var duration: Double {
        tracks.reduce(0.0, {(totalSoFar: Double, track: Track) -> Double in totalSoFar + track.duration})
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
    
    func indexOf(_ track: Track) -> Int?  {
        tracks.firstIndex(of: track)
    }
    
    func add(_ newTracks: [Track]) -> ClosedRange<Int> {
        tracks.addItems(newTracks)
    }
    
    func insert(_ newTracks: [Track], at index: Int) {
        
    }
    
    func moveUp(from indices: IndexSet) -> [TrackMoveResult] {
        tracks.moveItemsUp(from: indices).map {TrackMoveResult($0.key, $0.value)}
    }
    
    func moveToTop(from indices: IndexSet) -> [TrackMoveResult] {
        tracks.moveItemsToTop(from: indices).map {TrackMoveResult($0.key, $0.value)}
    }
    
    func moveToBottom(from indices: IndexSet) -> [TrackMoveResult] {
        tracks.moveItemsToBottom(from: indices).map {TrackMoveResult($0.key, $0.value)}
    }
    
    func moveDown(from indices: IndexSet) -> [TrackMoveResult] {
        tracks.moveItemsDown(from: indices).map {TrackMoveResult($0.key, $0.value)}
    }
    
    func removeAll() {
        tracks.removeAll()
    }
    
    func remove(_ tracksToRemove: [Track]) -> IndexSet {
        tracks.removeItems(tracksToRemove)
    }
    
    func remove(at indices: IndexSet) -> [Track] {
        tracks.removeItems(at: indices)
    }
    
    func dragAndDropItems(_ sourceIndices: IndexSet, _ dropIndex: Int) -> [TrackMoveResult] {
        tracks.dragAndDropItems(sourceIndices, dropIndex).map {TrackMoveResult($0.key, $0.value)}
    }
}
