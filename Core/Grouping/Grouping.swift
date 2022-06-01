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

fileprivate let groupSortByName: GroupComparator = {g1, g2 in
    
    let name1 = g1.name
    let name2 = g2.name
    
    let unknown1 = name1.starts(with: "<Unknown ")
    let unknown2 = name2.starts(with: "<Unknown ")
    
    if unknown1 && !unknown2 {
        return false
    } else if !unknown1 && unknown2 {
        return true
    }
    
    return name1 < name2
}

fileprivate let artistsKeyFunction: KeyFunction = {track in
    track.artist ?? "<Unknown Artist>"
}

fileprivate let albumsKeyFunction: KeyFunction = {track in
    track.album ?? "<Unknown Album>"
}

fileprivate let genresKeyFunction: KeyFunction = {track in
    track.genre ?? "<Unknown Genre>"
}

fileprivate let decadesKeyFunction: KeyFunction = {track in
    
    guard let year = track.year else {return "<Unknown Decade>"}
    
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
    let groupSortOrder: GroupComparator
    let trackSortOrder: TrackComparator
    
    init(keyFunction: @escaping KeyFunction, depth: Int = 0, subGroupingFunction: GroupingFunction? = nil, groupSortOrder: @escaping GroupComparator, trackSortOrder: @escaping TrackComparator) {
        
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
    
    static func fromFunctions(_ functions: [(keyFunction: KeyFunction, groupSortFunction: GroupComparator, trackSortFunction: TrackComparator)]) -> GroupingFunction {
        
        if functions.count == 1 {
            return GroupingFunction(keyFunction: functions[0].keyFunction, depth: 1, groupSortOrder: functions[0].groupSortFunction, trackSortOrder: functions[0].trackSortFunction)
        }
        
        var childIndex: Int = functions.lastIndex
        var parentIndex: Int = childIndex - 1
        
        var child = GroupingFunction(keyFunction: functions[childIndex].keyFunction,
                                 depth: childIndex + 1,
                                 groupSortOrder: functions[childIndex].groupSortFunction,
                                 trackSortOrder: functions[childIndex].trackSortFunction)
        
        var parent = GroupingFunction(keyFunction: functions[parentIndex].keyFunction,
                                  depth: parentIndex + 1,
                                  subGroupingFunction: child,
                                  groupSortOrder: functions[parentIndex].groupSortFunction,
                                  trackSortOrder: functions[parentIndex].trackSortFunction)
        
        parentIndex.decrement()
        childIndex.decrement()
        
        while parentIndex >= 0 {
            
            child = parent
            parent = GroupingFunction(keyFunction: functions[parentIndex].keyFunction,
                                      depth: parentIndex + 1,
                                      subGroupingFunction: child,
                                      groupSortOrder: functions[parentIndex].groupSortFunction,
                                      trackSortOrder: functions[parentIndex].trackSortFunction)
            
            parentIndex.decrement()
            childIndex.decrement()
        }
        
        return parent
    }
}

class Grouping {
    
    let name: String
    let function: GroupingFunction
    let rootGroup: Group
    
    static let defaultGroupSortOrder: GroupComparator = groupSortByName
    
    /// The user-specified custom sort order. (Will override the default sort order.)
    var sortOrder: GroupedTrackListSort? = nil {
        
        didSet {
            sortSubgroups(in: rootGroup, accordingTo: self.function)
        }
    }
    
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
            
            for subGroup in group.subGroups.values {
                subGroupTracks(in: subGroup, by: subGroupingFunction)
            }
        }
    }
    
    func findParent(forTrack track: Track) -> Group? {
        
        var function: GroupingFunction? = self.function
        var parent: Group? = rootGroup
        
        while let theFunction = function, let theParent = parent, theFunction.canSubGroup(group: theParent) {
            
            let groupName = theFunction.keyFunction(track)
            
            parent = theParent.findSubGroup(named: groupName)
            function = function?.subGroupingFunction
        }
        
        return parent
    }
    
    func removeTracks(_ tracksToRemove: [Track]) {
        
        for track in tracksToRemove {
            findParent(forTrack: track)?.removeTracks([track])
        }
    }
    
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
    
    /// Tracks were cropped in this grouping.
    func cropTracks(_ tracksToKeep: [Track]) {
        
        removeAllTracks()
        addTracks(tracksToKeep)
    }
    
    fileprivate func sortSubgroups(in parentGroup: Group, accordingTo function: GroupingFunction) {
        
        parentGroup.sortSubGroups(by: sortOrder?.groupSort?.comparator ?? function.groupSortOrder)
        
        if let subGroupingFunction = function.subGroupingFunction {
            
            for subGroup in parentGroup.subGroups.values {
                sortSubgroups(in: subGroup, accordingTo: subGroupingFunction)
            }
            
        } else {
            
            // Sort tracks at the last level
            for subGroup in parentGroup.subGroups.values {
                subGroup.sortTracks(by: sortOrder?.trackSort?.comparator ?? function.trackSortOrder)
            }
        }
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
        
        super.init(name: "Albums", function: GroupingFunction.fromFunctions([(albumsKeyFunction, Self.defaultGroupSortOrder, trackNumberAscendingComparator),
                                                                             (albumDiscsKeyFunction, Self.defaultGroupSortOrder, trackNumberAscendingComparator)]),
        rootGroup: AlbumsRootGroup(name: "Albums-Root", depth: 0))
    }
}

class GenresGrouping: Grouping {
    
    init() {
        
        super.init(name: "Genres", function: GroupingFunction.fromFunctions([(genresKeyFunction, Self.defaultGroupSortOrder, trackArtistAlbumDiscTrackNumberComparator),
                                                                              (artistsKeyFunction, Self.defaultGroupSortOrder, trackAlbumDiscAndTrackNumberAscendingComparator)]),
                   rootGroup: GenresRootGroup(name: "Genres-Root", depth: 0))
    }
}

class DecadesGrouping: Grouping {
    
    init() {
        
        super.init(name: "Decades", function: GroupingFunction.fromFunctions([(decadesKeyFunction, Self.defaultGroupSortOrder, trackArtistAlbumDiscTrackNumberComparator),
                                                                              (artistsKeyFunction, Self.defaultGroupSortOrder, trackAlbumDiscAndTrackNumberAscendingComparator)]),
                   rootGroup: DecadesRootGroup(name: "Decades-Root", depth: 0))
    }
}
