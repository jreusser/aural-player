//
//  Group.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import Foundation
import OrderedCollections

class Group: PlayableItem {
    
    let name: String
    
    var duration: Double {
        tracks.duration
    }
    
    var tracks: TrackList = TrackList()
    var hasTracks: Bool {tracks.isNonEmpty}
    
    var subGroups: [Group]
    var hasSubGroups: Bool {subGroups.isNonEmpty}
    
    init(name: String, tracks: [Track]) {
        
        self.name = name
        self.tracks.addTracks(tracks)
        self.subGroups = []
    }
    
    init(name: String, subGroups: [Group]) {
        
        self.name = name
        self.subGroups = subGroups
    }
    
    func addTracks(_ tracksMap: [(Int, Track)]) {
        
        for (index, track) in tracksMap {
            
            if index >= tracks.size {
                tracks.addTracks([track])
            } else {
                tracks.insertTracks([track], at: index)
            }
        }
    }
    
    func removeTracks(_ tracksToRemove: [Track]) {
        tracks.removeTracks(tracksToRemove)
    }
    
    // TODO: Name comparison is not enough !!!
    
    // Equatable ocnformance.
    static func == (lhs: Group, rhs: Group) -> Bool {
        lhs.name == rhs.name
    }
    
    // Hashable conformance.
    func hash(into hasher: inout Hasher) {
        hasher.combine(name)
    }
}
