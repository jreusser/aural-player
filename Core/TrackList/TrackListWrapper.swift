//
//  TrackListWrapper.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import Foundation

class TrackListWrapper {
    
    var trackList: TrackList = TrackList()
    
    // MARK: Accessor functions
    
    var tracks: [Track] {trackList.tracks}

    var size: Int {trackList.size}

    var duration: Double {trackList.duration}
    
    var summary: (size: Int, totalDuration: Double) {trackList.summary}

    subscript(_ index: Int) -> Track? {
        trackList[index]
    }

    func indexOfTrack(_ track: Track) -> Int?  {
        trackList.indexOfTrack(track)
    }
    
    func hasTrack(_ track: Track) -> Bool {
        trackList.hasTrack(track)
    }
    
    func hasTrackForFile(_ file: URL) -> Bool {
        trackList.hasTrackForFile(file)
    }
    
    func findTrackByFile(_ file: URL) -> Track? {
        trackList.findTrackByFile(file)
    }

    // MARK: Mutator functions ------------------------------------------------------------------------
    
    func insertTracks(_ newTracks: [Track], at insertionIndex: Int) -> ClosedRange<Int> {
        trackList.insertTracks(newTracks, at: insertionIndex)
    }

    func removeTracks(at indexes: IndexSet) -> [Track] {
        trackList.removeTracks(at: indexes)
    }

    func removeAllTracks() {
        trackList.removeAllTracks()
    }

    func moveTracksUp(from indices: IndexSet) -> [TrackMoveResult] {
        trackList.moveTracksUp(from: indices)
    }

    func moveTracksDown(from indices: IndexSet) -> [TrackMoveResult] {
        trackList.moveTracksDown(from: indices)
    }

    func moveTracksToTop(from indices: IndexSet) -> [TrackMoveResult] {
        trackList.moveTracksToTop(from: indices)
    }

    func moveTracksToBottom(from indices: IndexSet) -> [TrackMoveResult] {
        trackList.moveTracksToBottom(from: indices)
    }

    func moveTracks(from sourceIndexes: IndexSet, to dropIndex: Int) -> [TrackMoveResult] {
        trackList.moveTracks(from: sourceIndexes, to: dropIndex)
    }

    func exportToFile(_ file: URL) {
        trackList.exportToFile(file)
    }
}
