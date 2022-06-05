//
//  FileSystemLoader.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import Foundation

// TODO: How to deal with duplicate tracks ? (track is loaded individually and as part of a playlist)

// TODO: *********** How about using an OrderedSet<Track> to collect the tracks ?

// What if a track exists in a different track list ? (Play Queue / Library). Should we have a global track registry ?
// What about notifications / errors ? Return a result ?
// Create a track load session and a batch class
// How to deal with 2 simultaneous sessions on startup ? Play queue / Library / Custom playlists ? Adjust batch size accordingly ?
class FileSystemLoader {
    
    let priority: FileLoaderPriority
    
    private var session: FileSystemReadSession!
    private var batch: FileSystemMetadataBatch!
    var blockOpFunction: ((URL) -> BlockOperation)!
    
    private let queue: OperationQueue = OperationQueue()
    
    init(priority: FileLoaderPriority) {
        
        self.priority = priority
        
        queue.maxConcurrentOperationCount = priority.concurrentOpCount
        queue.underlyingQueue = DispatchQueue.global(qos: .userInteractive)
        queue.qualityOfService = .userInteractive
    }
    
    // TODO: Allow the caller to specify a "sort order" for the files, eg. by file path ???
    func loadMetadata(from files: [URL], into receiver: FileSystemLoaderReceiver,
                      observer: FileSystemLoaderObserver, completionHandler: VoidFunction? = nil) {
        
        observer.preTrackLoad()
        
        session = FileSystemReadSession(receiver: receiver, observer: observer)
        batch = FileSystemMetadataBatch(ofSize: queue.maxConcurrentOperationCount)
        
        blockOpFunction = {file in BlockOperation {
            
            var fileMetadata = FileMetadata()
            
            do {
                fileMetadata.primary = try fileReader.getPrimaryMetadata(for: file)
                
            } catch {
                fileMetadata.validationError = error as? DisplayableError
            }
            
            self.batch.setMetadata(fileMetadata, for: file)
        }}
        
        // Move to a background thread to unblock the main thread.
        DispatchQueue.global(qos: .userInteractive).async {
            
            defer {completionHandler?()}
            
            self.readFiles(files)
            
            if self.batch.fileCount > 0 {
                self.flushBatch()
            }
            
            // Cleanup
            self.session = nil
            self.batch = nil
            self.blockOpFunction = nil
            
            // Unblock this thread because the track list may perform a time consuming task in response to this callback.
            observer.postTrackLoad()
        }
    }
    
    /*
     Adds a bunch of files synchronously.
     
     The autoplayOptions argument encapsulates all autoplay options.
     
     The progress argument indicates current progress.
     */
    private func readFiles(_ files: [URL], isRecursiveCall: Bool = false) {
        
        for file in files {
            
            // Playlists might contain broken file references
            guard file.exists else {

                session.addError(FileNotFoundError(file))
                continue
            }

            // Always resolve sym links and aliases before reading the file
            let resolvedFile = file.resolvedURL

            if file.isDirectory {

                // Directory.
                batch.append(file: resolvedFile, isTrack: false)

            } else {

                // Single file - playlist or track
                let fileExtension = resolvedFile.pathExtension.lowercased()

                if SupportedTypes.playlistExtensions.contains(fileExtension) {
                    
                    // Playlist.
                    batch.append(file: resolvedFile, isTrack: false)
                    
                } else if SupportedTypes.allAudioExtensions.contains(fileExtension) {
                    
                    // Track
                    
                    // True means batch is full and needs to be flushed.
                    if batch.append(file: resolvedFile, isTrack: true) {
                        flushBatch()
                    }
                }
            }
        }
    }
    
    func flushBatch() {
        
        queue.addOperations(batch.tracks.map(blockOpFunction), waitUntilFinished: true)
        
        session.batchCompleted(batch.files)
        let newIndices = session.receiver.acceptBatch(batch)
        session.observer.postBatchLoad(indices: newIndices)
        
        batch.clear()
    }
}
