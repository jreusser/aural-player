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

typealias TrackSortFunction = (Track, Track) -> Bool

class Group: PlayableItem {
    
    let name: String
    let depth: Int
    
    var duration: Double {
        tracks.duration
    }
    
    var tracks: TrackList = TrackList()
    var hasTracks: Bool {tracks.isNonEmpty}
    
    var parentGroup: Group?
    var isRootLevelGroup: Bool {parentGroup == nil}
    
    var subGroups: [Group]
    var hasSubGroups: Bool {subGroups.isNonEmpty}
    
    init(name: String, depth: Int, tracks: [Track] = []) {
        
        self.name = name
        self.depth = depth
        self.tracks.addTracks(tracks)
        self.subGroups = []
    }
    
    init(name: String, depth: Int, parentGroup: Group? = nil, subGroups: [Group]) {
        
        self.name = name
        self.depth = depth
        self.parentGroup = parentGroup
        self.subGroups = subGroups
    }
    
    func addTracks(_ newTracks: [Track]) {
        tracks.addTracks(newTracks)
    }
    
    func sortTracks(by comparator: @escaping TrackSortFunction) {
        tracks.sort(by: comparator)
    }
    
    func removeTracks(_ tracksToRemove: [Track]) {
        tracks.removeTracks(tracksToRemove)
    }
    
    // Equatable conformance.
    static func == (lhs: Group, rhs: Group) -> Bool {
        lhs.name == rhs.name && lhs.depth == rhs.depth
    }
    
    // Hashable conformance.
    func hash(into hasher: inout Hasher) {
        
        hasher.combine(name)
        hasher.combine(depth)
    }
}
