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

typealias KeyFunction = (Track) -> String

fileprivate let groupSortByName: GroupSortFunction = {g1, g2 in
    g1.name < g2.name
}

fileprivate let artistsKeyFunction: KeyFunction = {track in
    track.artist ?? "<Unknown>"
}

fileprivate let albumsKeyFunction: KeyFunction = {track in
    track.album ?? "<Unknown>"
}

fileprivate let genresKeyFunction: KeyFunction = {track in
    track.genre ?? "<Unknown>"
}

fileprivate let decadesKeyFunction: KeyFunction = {track in
    
    guard let year = track.year else {return "<Unknown>"}
    
    let decade = year - (year % 10)
    return "\(decade)'s"
}

fileprivate let albumDiscsKeyFunction: KeyFunction = {track in
    
    if let discNumber = track.discNumber {
        return "Disc \(discNumber)"
    }
    
    return "<Unknown Disc>"
}

extension Dictionary {
    
    mutating func append<T>(_ element: T, forKey key: Key) where Value == [T] {
        self[key, default: []].append(element)
    }
}

class GroupingFunction {
    
    let keyFunction: KeyFunction
    let depth: Int
    let subGroupingFunction: GroupingFunction?
    let groupSortOrder: GroupSortFunction
    let trackSortOrder: TrackSortFunction
    
    init(keyFunction: @escaping KeyFunction, depth: Int = 0, subGroupingFunction: GroupingFunction? = nil, groupSortOrder: @escaping GroupSortFunction, trackSortOrder: @escaping TrackSortFunction) {
        
        self.keyFunction = keyFunction
        self.depth = depth
        
        self.subGroupingFunction = subGroupingFunction
        self.groupSortOrder = groupSortOrder
        self.trackSortOrder = trackSortOrder
    }
    
    // TODO: What is the most suitable place for this logic ???
    func canSubGroup(group: Group) -> Bool {
        
        guard let albumGroup = group as? AlbumGroup else {return true}
        return albumGroup.hasMoreThanOneTotalDisc
    }
    
    static func fromFunctions(_ functions: [(keyFunction: KeyFunction, groupSortFunction: GroupSortFunction, trackSortFunction: TrackSortFunction)]) -> GroupingFunction {
        
        if functions.count == 1 {
            return GroupingFunction(keyFunction: functions[0].keyFunction, depth: 1, groupSortOrder: functions[0].groupSortFunction, trackSortOrder: functions[0].trackSortFunction)
        }
        
        var childIndex: Int = functions.lastIndex
        var parentIndex: Int = childIndex - 1
        
        var child: GroupingFunction
        var parent: GroupingFunction
        
        repeat {
            
            child = GroupingFunction(keyFunction: functions[childIndex].keyFunction,
                                     depth: childIndex + 1,
                                     groupSortOrder: functions[childIndex].groupSortFunction,
                                     trackSortOrder: functions[childIndex].trackSortFunction)
            
            parent = GroupingFunction(keyFunction: functions[parentIndex].keyFunction,
                                      depth: parentIndex + 1,
                                      subGroupingFunction: child,
                                      groupSortOrder: functions[parentIndex].groupSortFunction,
                                      trackSortOrder: functions[parentIndex].trackSortFunction)
            
            parentIndex.decrement()
            childIndex.decrement()
            
        } while parentIndex >= 0
        
        return parent
    }
}

class Grouping {
    
    let name: String
    let function: GroupingFunction
    let rootGroup: Group
    
    init(name: String, function: GroupingFunction, rootGroup: Group) {

        self.name = name
        self.function = function
        self.rootGroup = rootGroup
    }
    
    var numberOfGroups: Int {rootGroup.numberOfSubGroups}
    
    func group(at index: Int) -> Group {
        rootGroup.subGroup(at: index)
    }
    
    func addTracks(_ newTracks: [Track]) {
        
        rootGroup.addTracks(newTracks)
        subGroupTracks(in: rootGroup, by: self.function)
    }
    
    fileprivate func subGroupTracks(in group: Group, by function: GroupingFunction) {
        
        guard function.canSubGroup(group: group) else {return}
        
        let tracksByGroupName = group.tracks.categorizeOneToManyBy {track in
            function.keyFunction(track)
        }
        
        for (groupName, tracks) in tracksByGroupName {
            
            let subGroup = group.findOrCreateSubGroup(named: groupName)
            subGroup.addTracks(tracks)
            
            if function.subGroupingFunction == nil {
                subGroup.sortTracks(by: function.trackSortOrder)
            }
        }
        
        // Tracks no longer in parent.
        group.removeAllTracks()
        
        group.sortSubGroups(by: groupSortByName)
        
        if let subGroupingFunction = function.subGroupingFunction {
            
            for group in group.subGroups.values {
                subGroupTracks(in: group, by: subGroupingFunction)
            }
        }
    }
    
    func removeTracks(_ newTracks: [Track]) {}
    
    func remove(tracks tracksToRemove: [GroupedTrack], andGroups groupsToRemove: [Group]) {
        
        var groupedTracks: [Group: [Track]] = [:]
        
        for track in tracksToRemove {
            groupedTracks[track.group, default: []].append(track.track)
        }
        
        for (parent, tracks) in groupedTracks {
            
            // If all tracks were removed from this group, remove the group itself.
            if parent.numberOfTracks == tracks.count {
                parent.removeFromParent()
                
            } else {
                parent.removeTracks(tracks)
            }
        }
        
        for group in groupsToRemove {
            group.removeFromParent()
        }
    }
    
    func removeAllTracks() {
        rootGroup.removeAllSubGroups()
    }
}

extension Grouping: Hashable {
    
    static func == (lhs: Grouping, rhs: Grouping) -> Bool {
        lhs.name == rhs.name
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(name)
    }
}

class ArtistsGrouping: Grouping {
    
    init() {
        
        super.init(name: "Artists",
                   function: GroupingFunction.fromFunctions([(artistsKeyFunction, groupSortByName, trackAlbumDiscAndTrackNumberAscendingComparator),
                                                             (albumsKeyFunction, groupSortByName, trackNumberAscendingComparator),
                                                             (albumDiscsKeyFunction, groupSortByName, trackNumberAscendingComparator)]),
                   rootGroup: ArtistsRootGroup(name: "Artists-Root", depth: 0))
    }
}

class AlbumsGrouping: Grouping {
    
    init() {
        
        super.init(name: "Albums", function: GroupingFunction.fromFunctions([(albumsKeyFunction, groupSortByName, trackNumberAscendingComparator),
                                                                             (albumDiscsKeyFunction, groupSortByName, trackNumberAscendingComparator)]),
        rootGroup: AlbumsRootGroup(name: "Albums-Root", depth: 0))
    }
}

class GenresGrouping: Grouping {
    
    init() {
        
        let trackComparator = TrackListSort(fields: [.artist, .album, .discNumberAndTrackNumber], order: .ascending)
        
        super.init(name: "Genres", function: GroupingFunction.fromFunctions([(genresKeyFunction, groupSortByName, trackComparator.comparator),
                                                                              (artistsKeyFunction, groupSortByName, trackAlbumDiscAndTrackNumberAscendingComparator)]),
                   rootGroup: GenresRootGroup(name: "Genres-Root", depth: 0))
    }
}

class DecadesGrouping: Grouping {
    
    init() {
        
        let trackComparator = TrackListSort(fields: [.artist, .album, .discNumberAndTrackNumber], order: .ascending)
        
        super.init(name: "Decades", function: GroupingFunction.fromFunctions([(decadesKeyFunction, groupSortByName, trackComparator.comparator),
                                                                              (artistsKeyFunction, groupSortByName, trackAlbumDiscAndTrackNumberAscendingComparator)]),
                   rootGroup: DecadesRootGroup(name: "Decades-Root", depth: 0))
    }
}
