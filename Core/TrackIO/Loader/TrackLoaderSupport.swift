//
//  TrackLoaderSupport.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import Foundation

typealias FileReadSessionCompletionHandler = ([URL]) -> Void

protocol TrackLoaderReceiver {
    
    func hasTrack(forFile file: URL) -> Bool
    
    func acceptBatch(_ batch: FileMetadataBatch) -> IndexSet
}

protocol TrackLoaderObserver {
    
    func preTrackLoad()
    
    func postTrackLoad()
    
    func postBatchLoad(indices: IndexSet)
}

class FileReadSession {

    let metadataType: MetadataType
    var files: [URL] = []
    let trackList: TrackLoaderReceiver
    let insertionIndex: Int?
    let observer: TrackLoaderObserver
    
    // For history
    var historyItems: [URL] = []
    
    // Progress
    var filesProcessed: Int = 0
    var errors: [DisplayableError] = []
    
    init(metadataType: MetadataType, trackList: TrackLoaderReceiver, insertionIndex: Int?, observer: TrackLoaderObserver) {
        
        self.metadataType = metadataType
        self.trackList = trackList
        self.insertionIndex = insertionIndex
        self.observer = observer
    }
    
    func addHistoryItem(_ item: URL) {
        historyItems.append(item)
    }
    
    func addError(_ error: DisplayableError) {
        errors.append(error)
    }
    
    func batchCompleted(_ batchFiles: [URL]) {
        files.append(contentsOf: batchFiles)
    }
}

class FileMetadataBatch {
    
    let size: Int
    var files: [URL] = []
    var metadata: ConcurrentMap<URL, FileMetadata> = ConcurrentMap()
    var insertionIndex: Int?
    
    var trackListIndices: ClosedRange<Int> {
        
        if let startIndex = insertionIndex {
            return startIndex...(startIndex + files.count - 1)
        }
        
        return 0...1
    }
    
    var orderedMetadata: [(file: URL, metadata: FileMetadata)] {files.map {(file: $0, metadata: self.metadata[$0]!)}}
    
    var fileCount: Int {files.count}
    
    init(ofSize size: Int, insertionIndex: Int?) {
        
        self.size = size
        self.insertionIndex = insertionIndex
    }
    
    func append(file: URL) -> Bool {
        
        files.append(file)
        return files.count == size
    }
    
    func setMetadata(_ metadata: FileMetadata, for file: URL) {
        self.metadata[file] = metadata
    }
    
    func clear() {
        
        files.removeAll()
        metadata.removeAll()
        
        if let index = self.insertionIndex {
            self.insertionIndex = index + files.count
        }
    }
}
