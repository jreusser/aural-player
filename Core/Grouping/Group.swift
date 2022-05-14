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

class Group {
    
    let name: String
    var tracks: OrderedSet<Track>
    var subGroups: [Group]
    
    init(name: String, tracks: [Track]) {
        
        self.name = name
        self.tracks = OrderedSet<Track>(tracks)
        self.subGroups = []
    }
    
    init(name: String, subGroups: [Group]) {
        
        self.name = name
        self.tracks = []
        self.subGroups = subGroups
    }
    
    func addTracks(_ tracksMap: [(Int, Track)]) {
        
        for (index, track) in tracksMap {
            
            if index >= tracks.count {
                tracks.append(track)
            } else {
                tracks.insert(track, at: index)
            }
        }
    }
    
    func removeTracks(_ tracksToRemove: [Track]) {
        
        tracksToRemove.forEach {
            tracks.remove($0)
        }
    }
}
