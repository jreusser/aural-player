//
//  GroupedTrackList.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import Foundation

class GroupedTrackList: TrackList {
    
    let groupings: [Grouping]
    
    init(withGroupings groupings: [Grouping]) {
        self.groupings = groupings
    }
    
    override func addTracks(_ newTracks: [Track]) -> ClosedRange<Int> {
        
        let indices = super.addTracks(newTracks)
        
        // TODO: Add to groupings
        groupings.forEach {
            $0.addTracks(newTracks)
        }
        
        return indices
    }
    
    override func removeTracks(at indices: IndexSet) -> [Track] {
        
        let tracks = super.removeTracks(at: indices)
        
        // TODO: Remove from groupings
        
        return tracks
    }
    
    override func removeTracks(_ tracksToRemove: [Track]) -> IndexSet {
        
        let indices = super.removeTracks(tracksToRemove)
        
        // TODO: Remove from groupings
        
        return indices
    }
    
    override func removeAllTracks() {
        
        super.removeAllTracks()
        
        // TODO: Remove from groupings
    }
}
