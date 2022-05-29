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
typealias GroupSortFunction = (Group, Group) -> Bool

class ArtistsRootGroup: Group {
    
    override func doCreateSubGroup(named groupName: String) -> Group {
        ArtistGroup(name: groupName, depth: self.depth + 1)
    }
}

class AlbumsRootGroup: Group {
    
    override func doCreateSubGroup(named groupName: String) -> Group {
        AlbumGroup(name: groupName, depth: self.depth + 1)
    }
}

class DecadesRootGroup: Group {
    
    override func doCreateSubGroup(named groupName: String) -> Group {
        DecadeGroup(name: groupName, depth: self.depth + 1)
    }
}

class ArtistGroup: Group {}
class DecadeGroup: Group {}

class Group: PlayableItem {
    
    let name: String
    let depth: Int
    
    var duration: Double {
        _tracks.values.reduce(0.0, {(totalSoFar: Double, track: Track) -> Double in totalSoFar + track.duration})
    }
    
    var _tracks: OrderedDictionary<URL, Track> = OrderedDictionary()
    var tracks: [Track] {Array(_tracks.values)}
    
    var numberOfTracks: Int {_tracks.count}
    var hasTracks: Bool {!_tracks.isEmpty}
    
    /// Safe array access.
    subscript(index: Int) -> Track {
        _tracks.elements[index].value
    }
    
    func subGroup(at index: Int) -> Group {
        subGroups.elements[index].value
    }
    
    unowned var parentGroup: Group?
    var isRootLevelGroup: Bool {parentGroup == nil}
    
    var subGroups: OrderedDictionary<String, Group> = OrderedDictionary()
    var numberOfSubGroups: Int {subGroups.count}
    var hasSubGroups: Bool {!subGroups.isEmpty}
    
    init(name: String, depth: Int, tracks: [Track] = []) {
        
        self.name = name
        self.depth = depth
        
        for track in tracks {
            self._tracks[track.file] = track
        }
    }
    
//    init(name: String, depth: Int, parentGroup: Group? = nil, subGroups: [Group]) {
//
//        self.name = name
//        self.depth = depth
//        self.parentGroup = parentGroup
//
//        for group in
//    }
    
    func doCreateSubGroup(named groupName: String) -> Group {
        Group(name: groupName, depth: self.depth + 1)
    }
    
    func findOrCreateSubGroup(named groupName: String) -> Group {
        
        if let subGroup = subGroups[groupName] {
            return subGroup
        }
        
        let newGroup = doCreateSubGroup(named: groupName)
        newGroup.parentGroup = self
        subGroups[groupName] = newGroup
        
        return newGroup
    }
    
    func addSubGroup(_ subGroup: Group) {
        
        if subGroups[subGroup.name] == nil {
            
            subGroups[subGroup.name] = subGroup
            subGroup.parentGroup = self
        }
    }
    
    func removeSubGroup(_ subGroup: Group) {
        
        subGroups.removeValue(forKey: subGroup.name)
        
        if subGroups.isEmpty {
            removeFromParent()
        }
    }
    
    func removeAllSubGroups() {
        subGroups.removeAll()
    }
    
    func removeFromParent() {
        parentGroup?.removeSubGroup(self)
    }
    
    func addTracks(_ newTracks: [Track]) {
        
        for track in newTracks {
            _tracks[track.file] = track
        }
    }
    
    func sortTracks(by comparator: @escaping TrackSortFunction) {
        
        _tracks.sort(by: {kvPair1, kvPair2 in
            comparator(kvPair1.value, kvPair2.value)
        })
    }
    
    func sortSubGroups(by comparator: @escaping GroupSortFunction) {
        
        subGroups.sort(by: {kvPair1, kvPair2 in
            comparator(kvPair1.value, kvPair2.value)
        })
    }
    
    func removeTracks(_ tracksToRemove: [Track]) {
        
        for track in tracksToRemove {
            _tracks.removeValue(forKey: track.file)
        }
    }
    
    func removeAllTracks() {
        _tracks.removeAll()
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
