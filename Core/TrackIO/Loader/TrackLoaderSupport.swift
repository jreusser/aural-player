//
//  TrackLoaderSupport.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import Foundation
import OrderedCollections

typealias FileReadSessionCompletionHandler = ([URL]) -> Void

/// The **TrackList** that accepts the loaded tracks.
protocol TrackLoaderReceiver {
    
    func hasTrack(forFile file: URL) -> Bool
    
    func indexOfTrack(forFile file: URL) -> Int?
    
    func firstFileLoaded(file: URL, atIndex index: Int)
    
    func acceptBatch(_ batch: FileMetadataBatch) -> IndexSet
}

/// Any observer that wants to know about the loaded tracks.
protocol TrackLoaderObserver {
    
    func preTrackLoad()
    
    func postTrackLoad()
    
    func postBatchLoad(indices: IndexSet)
}

class FileRead {
    
    let file: URL
    var result: FileReadResult
    var indexOfFileInTrackList: Int?
    
    // TODO: Add a field for fileMetadata.validationError ???
    
    init(file: URL, result: FileReadResult, indexOfFileInTrackList: Int? = nil) {
        
        self.file = file
        self.result = result
        self.indexOfFileInTrackList = indexOfFileInTrackList
    }
}

enum FileReadResult {
    
    case existsInTrackList, addedToTrackList, error
}

class FileReadSession {

    let metadataType: MetadataType
    var files: OrderedDictionary<URL, FileRead> = OrderedDictionary()
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
    
    func batchCompleted(_ batchFiles: OrderedDictionary<URL, FileRead>) {
        
        for (file, fileRead) in batchFiles {
            self.files[file] = fileRead
        }
    }
}

class FileMetadataBatch {
    
    var counter: Int = 0
    
    let size: Int
    var files: OrderedDictionary<URL, FileRead> = OrderedDictionary()
    
    // TODO: Are some errors harmless and should we ignore them ???
    var firstSuccessfullyLoadedFile: FileRead? {
        files.values.first(where: {$0.result != .error})
    }
    
    var filesToRead: [URL] {
        files.filter {$0.value.result != .existsInTrackList}.map {$0.key}
    }
    
    var metadata: ConcurrentMap<URL, FileMetadata> = ConcurrentMap()
    var insertionIndex: Int?
    
    var trackListIndices: ClosedRange<Int> {
        
        if let startIndex = insertionIndex {
            return startIndex...(startIndex + files.count - 1)
        }
        
        return 0...(files.count - 1)
    }
    
    var orderedMetadata: [(file: URL, metadata: FileMetadata)] {files.keys.compactMap {(file) -> (URL, FileMetadata)? in
        
        guard let fileMetadata = self.metadata[file] else {return nil}
        return (file: file, metadata: fileMetadata)
    }}
    
    var fileCount: Int {files.count}
    
    init(ofSize size: Int, insertionIndex: Int?) {
        
        self.size = size
        self.insertionIndex = insertionIndex
    }
    
    func append(file: FileRead) -> Bool {
        
        files[file.file] = file
        return files.count == size
    }
    
    func setMetadata(_ metadata: FileMetadata, for file: URL) {
        self.metadata[file] = metadata
    }
    
    func markReadErrors() {
        
        for (file, fileMetadata) in self.metadata.map {
            
            if fileMetadata.validationError != nil {
                files[file]?.result = .error
            }
        }
    }
    
    func clear() {
        
        if let index = self.insertionIndex {
            self.insertionIndex = index + files.count
        }
        
        files.removeAll()
        metadata.removeAll()
        
        counter.increment()
    }
}
