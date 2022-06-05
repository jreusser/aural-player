//
//  FileSystemLoaderSupport.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import Foundation

protocol FileSystemLoaderReceiver {
    
    func acceptBatch(_ batch: FileSystemMetadataBatch) -> IndexSet
}

protocol FileSystemLoaderObserver {
    
    func preTrackLoad()
    
    func postTrackLoad()
    
    func postBatchLoad(indices: IndexSet)
}

class FileSystemReadSession {

    var files: [URL] = []
    let receiver: FileSystemLoaderReceiver
    let observer: FileSystemLoaderObserver
    
    // Progress
    var filesProcessed: Int = 0
    var errors: [DisplayableError] = []
    
    init(receiver: FileSystemLoaderReceiver, observer: FileSystemLoaderObserver) {
        
        self.receiver = receiver
        self.observer = observer
    }
    
    func addError(_ error: DisplayableError) {
        errors.append(error)
    }
    
    func batchCompleted(_ batchFiles: [URL]) {
        files.append(contentsOf: batchFiles)
    }
}

class FileSystemMetadataBatch {
    
    let size: Int
    var files: [URL] = []
    var tracks: [URL] = []
    var metadata: ConcurrentMap<URL, FileMetadata> = ConcurrentMap()
    
    var fileCounter: Int = 0

    private var trackCount: Int = 0
    
    var orderedMetadata: [(file: URL, metadata: FileMetadata)] {files.map {(file: $0, metadata: self.metadata[$0]!)}}
    
    var fileCount: Int {files.count}
    
    var indices: IndexSet {
        
        let minIndex = fileCounter - files.count
        return IndexSet(minIndex..<fileCounter)
    }
    
    init(ofSize size: Int) {
        self.size = size
    }
    
    @discardableResult func append(file: URL, isTrack: Bool) -> Bool {
        
        files.append(file)
        fileCounter.increment()
        
        if isTrack {
            tracks.append(file)
        }
        
        trackCount += isTrack ? 1 : 0
        return trackCount == size
    }
    
    func setMetadata(_ metadata: FileMetadata, for file: URL) {
        self.metadata[file] = metadata
    }
    
    func clear() {
        
        files.removeAll()
        tracks.removeAll()
        metadata.removeAll()
        
        trackCount = 0
    }
}
