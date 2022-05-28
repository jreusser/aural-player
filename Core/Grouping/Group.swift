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
        _tracks.duration
    }
    
    var _tracks: TrackList = TrackList()
    var tracks: [Track] {_tracks.tracks}
    
    var numberOfTracks: Int {_tracks.size}
    var hasTracks: Bool {_tracks.isNonEmpty}
    
    /// Safe array access.
    subscript(index: Int) -> Track? {
        _tracks[index]
    }
    
    unowned var parentGroup: Group?
    var isRootLevelGroup: Bool {parentGroup == nil}
    
    var subGroups: OrderedDictionary<String, Group> = OrderedDictionary()
    var hasSubGroups: Bool {!subGroups.isEmpty}
    
    init(name: String, depth: Int, tracks: [Track] = []) {
        
        self.name = name
        self.depth = depth
        self._tracks.addTracks(tracks)
    }
    
//    init(name: String, depth: Int, parentGroup: Group? = nil, subGroups: [Group]) {
//
//        self.name = name
//        self.depth = depth
//        self.parentGroup = parentGroup
//
//        for group in
//    }
    
    func addSubGroup(_ subGroup: Group) {
        
        if subGroups[subGroup.name] == nil {
            
            print("\nAdding subgroup '\(subGroup.name)' to \(name)")
            
            subGroups[subGroup.name] = subGroup
            subGroup.parentGroup = self
        }
    }
    
    func addTracks(_ newTracks: [Track]) {
        _tracks.addTracks(newTracks)
    }
    
    func sortTracks(by comparator: @escaping TrackSortFunction) {
        _tracks.sort(by: comparator)
    }
    
    func removeTracks(_ tracksToRemove: [Track]) {
        _tracks.removeTracks(tracksToRemove)
    }
    
    func removeAllTracks() {
        _tracks.removeAllTracks()
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
