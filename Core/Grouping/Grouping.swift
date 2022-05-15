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

typealias GroupingFunction = (Track) -> String

extension Dictionary {
    
    mutating func append<T>(_ element: T, forKey key: Key) where Value == [T] {
        self[key, default: []].append(element)
    }
}

class Grouping {
    
    var name: String
    let keyFunction: GroupingFunction
    let subGrouping: Grouping?
    
    init(name: String, keyFunction: @escaping GroupingFunction, subGrouping: Grouping? = nil) {
        
        self.name = name
        self.keyFunction = keyFunction
        self.subGrouping = subGrouping
    }
    
    func applyTo(trackList: TrackList) -> [Group] {
        
        let groups = groupTracks(trackList.tracks, accordingTo: self)
        
        if let subGrouping = self.subGrouping {
            return subGroup(groups, accordingTo: subGrouping)
        }
        
        return groups
    }
    
    private func groupTracks(_ tracks: [Track], accordingTo grouping: Grouping) -> [Group] {
        
        var kvMap: [String: [Track]] = [:]
    
        for track in tracks {
            kvMap.append(track, forKey: grouping.keyFunction(track))
        }
        
        return kvMap.map {key, value in
            
            if grouping is AlbumsGrouping {
                return AlbumGroup(name: key, tracks: value)
            }
            
            return Group(name: key, tracks: value)
        }
    }
    
    // Recursive sub-grouping function.
    private func subGroup(_ groups: [Group], accordingTo grouping: Grouping) -> [Group] {
        
        var newGroups: [Group] = []
        
        for group in groups {
            
            let subGroups = groupTracks(Array(group.tracks), accordingTo: grouping)
            newGroups.append(Group(name: group.name, subGroups: subGroups))
        }
        
        if let subGrouping = grouping.subGrouping {
            return subGroup(newGroups, accordingTo: subGrouping)
        }
        
        return newGroups
    }
}

class ArtistsGrouping: Grouping {
    
    init(subGroupByAlbum: Bool = true) {
        super.init(name: "Artists", keyFunction: {track in track.artist ?? "<Unknown>"}, subGrouping: subGroupByAlbum ? AlbumsGrouping() : nil)
    }
}

class AlbumsGrouping: Grouping {
    
    init() {
        super.init(name: "Albums") {track in track.album ?? "<Unknown>"}
    }
}

class GenresGrouping: Grouping {
    
    init(subGroupByArtist: Bool = true, subGroupByAlbum: Bool = true) {
        
        let keyFunction: GroupingFunction = {track in track.genre ?? "<Unknown>"}
        
        switch (subGroupByArtist, subGroupByAlbum) {
            
        case (true, true):
            
            super.init(name: "Genres", keyFunction: keyFunction, subGrouping: ArtistsGrouping())
            
        case (true, false):
            
            super.init(name: "Genres", keyFunction: keyFunction, subGrouping: ArtistsGrouping(subGroupByAlbum: false))
            
        case (false, true):
        
            super.init(name: "Genres", keyFunction: keyFunction, subGrouping: AlbumsGrouping())
            
        case (false, false):
        
            super.init(name: "Genres", keyFunction: keyFunction)
        }
    }
}

class DecadesGrouping: Grouping {
    
    init() {
        
        super.init(name: "Decades") {track in
            
            guard let year = track.year else {return "<Unknown>"}
            
            let decade = year - (year % 10)
            return "\(decade)'s"
        }
    }
}
