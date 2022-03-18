//
//  TrackListIterator.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import Foundation

struct TrackListIterator: IteratorProtocol {

    private let trackList: TrackList
    private var cursor: Int
    
    typealias Element = Track
    
    init(trackList: TrackList) {
        
        self.trackList = trackList
        self.cursor = 0
    }
    
    mutating func next() -> Track? {
        
        defer {cursor.increment()}
        return trackList[cursor]
    }
}
