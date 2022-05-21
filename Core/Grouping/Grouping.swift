//
//  Grouping.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import Foundation
import OrderedCollections

typealias GroupingFunction = (Track) -> String

extension Dictionary {
    
    mutating func append<T>(_ element: T, forKey key: Key) where Value == [T] {
        self[key, default: []].append(element)
    }
}

class Grouping {
    
    var name: String
    let depth: Int
    let keyFunction: GroupingFunction
    let subGrouping: Grouping?
    
    var groups: OrderedSet<Group> = OrderedSet()
    fileprivate var groupsByName: [String: Group] = [:]
    
    fileprivate init(name: String, depth: Int, keyFunction: @escaping GroupingFunction, subGrouping: Grouping? = nil) {
        
        self.name = name
        self.depth = depth
        self.keyFunction = keyFunction
        self.subGrouping = subGrouping
    }
    
    func addTracks(_ newTracks: [Track]) {}
    
    fileprivate func createGroup(named groupName: String) -> Group {
        
        let newGroup = Group(name: groupName, depth: depth)
        
        // TODO: When adding a new group, maintain (alphabetical or user-defined) sort order ???
        groups.append(newGroup)
        groups.sort(by: {g1, g2 in g1.name < g2.name})
        
        return newGroup
    }
    
    func remove(tracks: [GroupedTrack], andGroups groups: [Group]) -> TrackRemovalResults {
        
        // TODO
        .empty
    }
    
//    func applyTo(trackList: TrackList) -> [Group] {
//
//        let groups = groupTracks(trackList.tracks, accordingTo: self)
//
//        if let subGrouping = self.subGrouping {
//            return subGroup(groups, accordingTo: subGrouping)
//        }
//
//        return groups
//    }
//
//    private func groupTracks(_ tracks: [Track], accordingTo grouping: Grouping) -> [Group] {
//
//        var kvMap: [String: [Track]] = [:]
//
//        for track in tracks {
//            kvMap.append(track, forKey: grouping.keyFunction(track))
//        }
//
//        return kvMap.map {key, value in
//
//            if grouping is AlbumsGrouping {
//                return AlbumGroup(name: key, tracks: value)
//            }
//
//            return Group(name: key, tracks: value)
//        }
//    }
//
//    // Recursive sub-grouping function.
//    private func subGroup(_ groups: [Group], accordingTo grouping: Grouping) -> [Group] {
//
//        var newGroups: [Group] = []
//
//        for group in groups {
//
//            let subGroups = groupTracks(Array(group.tracks), accordingTo: grouping)
//            newGroups.append(Group(name: group.name, subGroups: subGroups))
//        }
//
//        if let subGrouping = grouping.subGrouping {
//            return subGroup(newGroups, accordingTo: subGrouping)
//        }
//
//        return newGroups
//    }
}

class AlbumsGrouping: Grouping {
    
    init(depth: Int = 0) {
        super.init(name: "Albums", depth: depth) {track in track.album ?? "<Unknown>"}
    }
    
    override func addTracks(_ newTracks: [Track]) {
        
        var tracksByGroupName: [String: [Track]] = [:]
        
        for track in newTracks {
            tracksByGroupName[keyFunction(track), default: []].append(track)
        }
        
        for (groupName, tracks) in tracksByGroupName {
            
            let group = groupsByName[groupName] ?? createGroup(named: groupName)
            group.addTracks(tracks)
            group.sortTracks(by: trackDiscAndTrackNumberAscendingComparator)
        }
    }
}

class ArtistsGrouping: Grouping {
    
    init(depth: Int = 0, subGroupByAlbum: Bool = true) {
        super.init(name: "Artists", depth: depth, keyFunction: {track in track.artist ?? "<Unknown>"}, subGrouping: subGroupByAlbum ? AlbumsGrouping(depth: 1) : nil)
    }
}

class GenresGrouping: Grouping {
    
    init(subGroupByArtist: Bool = true, subGroupByAlbum: Bool = true) {
        
        let keyFunction: GroupingFunction = {track in track.genre ?? "<Unknown>"}
        
        switch (subGroupByArtist, subGroupByAlbum) {
            
        case (true, true):
            
            super.init(name: "Genres", depth: 0, keyFunction: keyFunction, subGrouping: ArtistsGrouping(depth: 1))
            
        case (true, false):
            
            super.init(name: "Genres", depth: 0, keyFunction: keyFunction, subGrouping: ArtistsGrouping(depth: 1, subGroupByAlbum: false))
            
        case (false, true):
        
            super.init(name: "Genres", depth: 0, keyFunction: keyFunction, subGrouping: AlbumsGrouping(depth: 1))
            
        case (false, false):
        
            super.init(name: "Genres", depth: 0, keyFunction: keyFunction)
        }
    }
}

class DecadesGrouping: Grouping {
    
    init(depth: Int = 0) {
        
        super.init(name: "Decades", depth: depth) {track in
            
            guard let year = track.year else {return "<Unknown>"}
            
            let decade = year - (year % 10)
            return "\(decade)'s"
        }
    }
}
