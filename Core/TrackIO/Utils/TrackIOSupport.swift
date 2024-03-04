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

class TrackLoadSession {
    
    private let loader: TrackListFileSystemLoadingProtocol
    let urls: [URL]
    private(set) var tracks: OrderedDictionary<URL, TrackRead> = OrderedDictionary()
    private(set) var insertionIndex: Int?
    
    private let queue: OperationQueue
    private let batchSize: Int
    
    // Progress
    private(set) var errors: [DisplayableError] = []
    
    private var triggeredFirstReadCallback: Bool = false
    
    init(forLoader loader: TrackListFileSystemLoadingProtocol, withPriority priority: DispatchQoS.QoSClass, urls: [URL], insertionIndex: Int?) {
        
        self.loader = loader
        self.urls = urls
        self.insertionIndex = insertionIndex
        
        switch priority {
            
        case .userInitiated, .userInteractive:
            self.queue = TrackReader.highPriorityQueue
            
        case .utility:
            self.queue = TrackReader.mediumPriorityQueue
            
        case .background:
            self.queue = TrackReader.lowPriorityQueue
            
        default:
            self.queue = TrackReader.mediumPriorityQueue
        }
        
        self.batchSize = self.queue.maxConcurrentOperationCount
        
        loader.preTrackLoad()
    }
    
    var trackListIndices: ClosedRange<Int> {
        
        if let startIndex = insertionIndex {
            return startIndex...(startIndex + tracks.count - 1)
        }
        
        return 0...(tracks.count - 1)
    }
    
    var tracksCount: Int {tracks.count}
    
    func readTrack(forFile file: URL) {
        
        guard tracks[file] == nil else {return}
        
        let trackInList: Track? = loader.findTrack(forFile: file)
        let track = trackInList ?? Track(file)
        
        let trackRead: TrackRead = TrackRead(track: track,
                                             result: trackInList != nil ? .existsInTrackList : .addedToTrackList)
        
        tracks[trackRead.track.file] = trackRead
        
        if tracks.count == batchSize {
            processBatch()
        }
    }
    
    func processBatch() {
        
        let tracksToRead = tracks.values.filter {$0.result != .existsInTrackList}.map {$0.track}
        
        queue.addOperations(tracksToRead.map {track in
            
            BlockOperation {
                trackReader.loadPrimaryMetadata(for: track)
            }
            
        }, waitUntilFinished: true)
        markBatchReadErrors()
        
        loader.postBatchLoad(indices: loader.acceptBatch(fromSession: self))
        
        // For Autoplay
        if !triggeredFirstReadCallback, 
            let firstRead = tracks.values.first(where: {$0.result != .error}),
            let indexOfTrack = loader.indexOfTrack(firstRead.track) {

            loader.firstTrackLoaded(atIndex: indexOfTrack)
            triggeredFirstReadCallback = true
        }
        
        clearBatch()
    }
    
    func addError(_ error: DisplayableError) {
        errors.append(error)
    }
    
    private func markBatchReadErrors() {
        
        for trackRead in self.tracks.values {
            
            if trackRead.track.validationError != nil {
                trackRead.result = .error
            }
        }
    }
    
    func clearBatch() {
        
        if let index = self.insertionIndex {
            self.insertionIndex = index + tracks.count
        }
        
        tracks.removeAll()
    }
    
    func allTracksRead() {
        
        if !tracks.isEmpty {
            processBatch()
        }
        
        loader.postTrackLoad()
    }
}

class TrackRead {
    
    let track: Track
    var result: TrackReadResult
    
    // TODO: Add a field for track.validationError ???
    
    init(track: Track, result: TrackReadResult) {
        
        self.track = track
        self.result = result
    }
}

enum TrackReadResult {
    
    case existsInTrackList, addedToTrackList, error
}
