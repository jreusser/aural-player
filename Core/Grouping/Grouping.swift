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

fileprivate let albumsKeyFunction: KeyFunction = {track in
    track.album ?? "<Unknown>"
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
    
    init(name: String, function: GroupingFunction) {

        self.name = name
        self.function = function
    }
    
    var groups: OrderedDictionary<String, Group> = OrderedDictionary()
    
    var numberOfGroups: Int {groups.count}
    
    func group(at index: Int) -> Group {
        groups.values[index]
    }
    
    fileprivate func doCreateGroup(named groupName: String, atDepth depth: Int) -> Group {
        Group(name: groupName, depth: depth)
    }
    
    func findOrCreateGroup(named groupName: String) -> Group {
        
        if let group = groups[groupName] {
            return group
        }
        
        let newGroup = doCreateGroup(named: groupName, atDepth: 1)
        groups[groupName] = newGroup
        return newGroup
    }
    
    func addTracks(_ newTracks: [Track]) {
        groupTracks(newTracks, by: self.function)
    }
    
    @inlinable
    @inline(__always)
    func categorizeTracksByGroupName(_ tracks: [Track], keyFunction: KeyFunction) -> [String: [Track]] {
        
        var tracksByGroupName: [String: [Track]] = [:]
        
        for track in tracks {
            tracksByGroupName[keyFunction(track), default: []].append(track)
        }
        
        return tracksByGroupName
    }
    
    fileprivate func groupTracks(_ tracks: [Track], by function: GroupingFunction) {
        
        let tracksByGroupName = categorizeTracksByGroupName(tracks, keyFunction: function.keyFunction)
        
        for (groupName, tracks) in tracksByGroupName {
        
            // Top-level groups
            
            let group = findOrCreateGroup(named: groupName)
            group.addTracks(tracks)
            
            if function.subGroupingFunction == nil {
                group.sortTracks(by: function.trackSortOrder)
            }
            
            groups[groupName] = group
        }
        
        // Sort by group name in ascending order.
        groups.sort(by: {kvPair1, kvPair2 in
            function.groupSortOrder(kvPair1.value, kvPair2.value)
        })
        
        if let subGroupingFunction = function.subGroupingFunction {
            
            for group in groups.values {
                subGroupTracks(in: group, by: subGroupingFunction)
            }
        }
    }
    
    fileprivate func subGroupTracks(in group: Group, by function: GroupingFunction) {
        
        let tracksByGroupName = categorizeTracksByGroupName(group.tracks, keyFunction: function.keyFunction)
        
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
    
    func remove(tracks: [GroupedTrack], andGroups groups: [Group]) {}
    
    func removeAllTracks() {}
}

extension Grouping: Hashable {
    
    static func == (lhs: Grouping, rhs: Grouping) -> Bool {
        lhs.name == rhs.name
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(name)
    }
}

class AlbumsGrouping: Grouping {
    
    init() {
        
        super.init(name: "Albums", function: GroupingFunction.fromFunctions([(albumsKeyFunction, groupSortByName, trackNumberAscendingComparator),
                                                                             (albumDiscsKeyFunction, groupSortByName, trackNumberAscendingComparator)]))
    }
    
    override fileprivate func doCreateGroup(named groupName: String, atDepth depth: Int) -> Group {
        
        switch depth {
            
        case 2:
            
            return AlbumDiscGroup(name: groupName, depth: depth)
            
        default:
            
            return AlbumGroup(name: groupName, depth: depth)
        }
    }
}
