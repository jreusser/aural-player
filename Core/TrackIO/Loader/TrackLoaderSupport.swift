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
    
    func shouldLoad(file: URL) -> Bool
    
    func acceptBatch(_ batch: FileMetadataBatch)
    
    func allFileReadsCompleted(files: [URL])
}

class FileReadSession {

    let metadataType: MetadataType
    var files: [URL] = []
    let trackList: TrackLoaderReceiver
    let insertionIndex: Int?
    
    // For history
    var historyItems: [URL] = []
    
    // Progress
    var filesProcessed: Int = 0
    var errors: [DisplayableError] = []
    
    init(metadataType: MetadataType, trackList: TrackLoaderReceiver, insertionIndex: Int?) {
        
        self.metadataType = metadataType
        self.trackList = trackList
        self.insertionIndex = insertionIndex
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
