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

class GroupedSortedTrackList: SortedTrackList, GroupedSortedTrackListProtocol {
    
    let groupings: [Grouping]
    
    init(sortOrder: TrackListSort, withGroupings groupings: [Grouping]) {
        
        self.groupings = groupings
        super.init(sortOrder: sortOrder)
    }
    
    override func addTracks(_ newTracks: [Track]) -> IndexSet {
        
        let indices = super.addTracks(newTracks)
        
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
    
    func remove(tracks: [GroupedTrack], andGroups groups: [Group]) -> TrackRemovalResults {
        .empty
    }
    
    override func removeAllTracks() {
        
        super.removeAllTracks()
        
        // TODO: Remove from groupings
    }
}
