//
//  TrackIOSupport.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import Foundation
import OrderedCollections

class TrackLoadBatch {
    
    var counter: Int = 0
    
    let size: Int
    var tracks: OrderedDictionary<URL, FileRead> = OrderedDictionary()
    
    // TODO: Are some errors harmless and should we ignore them ???
    var firstSuccessfulRead: FileRead? {
        tracks.values.first(where: {$0.result != .error})
    }
    
    var tracksToRead: [Track] {
        tracks.values.filter {$0.result != .existsInTrackList}.map {$0.track}
    }
    
    var insertionIndex: Int?
    
    var trackListIndices: ClosedRange<Int> {
        
        if let startIndex = insertionIndex {
            return startIndex...(startIndex + tracks.count - 1)
        }
        
        return 0...(tracks.count - 1)
    }
    
    var fileCount: Int {tracks.count}
    
    init(ofSize size: Int, insertionIndex: Int?) {
        
        self.size = size
        self.insertionIndex = insertionIndex
    }
    
    func append(fileRead: FileRead) -> Bool {
        
        tracks[fileRead.track.file] = fileRead
        return tracks.count == size
    }
    
    func markReadErrors() {
        
        for fileRead in self.tracks.values {
            
            if fileRead.track.validationError != nil {
                fileRead.result = .error
            }
        }
    }
    
    func clear() {
        
        if let index = self.insertionIndex {
            self.insertionIndex = index + tracks.count
        }
        
        tracks.removeAll()
        counter.increment()
    }
}

class FileRead {
    
    let track: Track
    var result: FileReadResult
    
    // TODO: Add a field for fileMetadata.validationError ???
    
    init(track: Track, result: FileReadResult) {
        
        self.track = track
        self.result = result
    }
}

enum FileReadResult {
    
    case existsInTrackList, addedToTrackList, error
}

class FileReadSession {

    let trackList: TrackList
    let insertionIndex: Int?
    
    // For history
    var historyItems: [URL] = []
    
    // Progress
    var filesProcessed: Int = 0
    var errors: [DisplayableError] = []
    
    init(trackList: TrackList, insertionIndex: Int?) {
        
        self.trackList = trackList
        self.insertionIndex = insertionIndex
    }
    
    func addHistoryItem(_ item: URL) {
        historyItems.append(item)
    }
    
    func addError(_ error: DisplayableError) {
        errors.append(error)
    }
}
