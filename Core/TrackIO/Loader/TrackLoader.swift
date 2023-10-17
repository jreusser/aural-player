//
//  TrackLoader.swift
//  Aural
//
//  Copyright © 2023 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import Foundation

typealias VoidFunction = () -> Void

enum FileLoaderPriority: Int, CaseIterable {
    
    private static let opCounts: [FileLoaderPriority: Int] = {
        
        let physicalCores: Int = System.physicalCores
        let activeCores: Int = SystemUtils.numberOfActiveCores
        
        return [
            
            .low: max(physicalCores / 2, 2),
            
            .medium: max(3, physicalCores),
            
            .high: max(4, activeCores),
            
            .highest: max(4, (Double(activeCores) * 1.5).roundedInt)
        ]
    }()
    
    case low, medium, high, highest
    
    var concurrentOpCount: Int {
        Self.opCounts[self]!
    }
}

// TODO: How to deal with duplicate tracks ? (track is loaded individually and as part of a playlist)

// TODO: *********** How about using an OrderedSet<Track> to collect the tracks ?

// What if a track exists in a different track list ? (Play Queue / Library). Should we have a global track registry ?
// What about notifications / errors ? Return a result ?
// Create a track load session and a batch class
// How to deal with 2 simultaneous sessions on startup ? Play queue / Library / Custom playlists ? Adjust batch size accordingly ?
class TrackLoader {
    
    let priority: FileLoaderPriority
    let qOS: DispatchQoS.QoSClass
    
    private var session: FileReadSession!
    private var batch: FileMetadataBatch!
    var blockOpFunction: ((URL) -> BlockOperation)!
    
    private let queue: OperationQueue = OperationQueue()
    
    init(priority: FileLoaderPriority, qOS: DispatchQoS.QoSClass) {
        
        self.priority = priority
        self.qOS = qOS
        
        queue.maxConcurrentOperationCount = priority.concurrentOpCount
        queue.underlyingQueue = DispatchQueue.global(qos: qOS)
        queue.qualityOfService = .userInteractive
    }
    
    // TODO: Allow the caller to specify a "sort order" for the files, eg. by file path ???
    func loadMetadata(ofType type: MetadataType, from files: [URL], into trackReceiver: TrackLoaderReceiver, at insertionIndex: Int? = nil,
                      observer: TrackLoaderObserver, completionHandler: VoidFunction? = nil) {
        
        observer.preTrackLoad()
        
        session = FileReadSession(metadataType: type, trackList: trackReceiver, insertionIndex: insertionIndex, observer: observer)
        batch = FileMetadataBatch(ofSize: queue.maxConcurrentOperationCount, insertionIndex: insertionIndex)
        blockOpFunction = blockOp(metadataType: type)
        
        // Move to a background thread to unblock the main thread.
        DispatchQueue.global(qos: qOS).async {
            
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
    
    private func blockOp(metadataType: MetadataType) -> ((URL) -> BlockOperation) {
        
        return {file in BlockOperation {
            
            var fileMetadata = FileMetadata()

            do {

                switch metadataType {

                case .primary:

                    fileMetadata.primary = try fileReader.getPrimaryMetadata(for: file)

                case .playback:

                    fileMetadata.playback = try fileReader.getPlaybackMetadata(for: file)
                    
                default:
                    
                    return
                }

            } catch {
                fileMetadata.validationError = error as? DisplayableError
            }

            self.batch.setMetadata(fileMetadata, for: file)
        }}
    }
    
    /*
     Adds a bunch of files synchronously.
     
     The autoplayOptions argument encapsulates all autoplay options.
     
     The progress argument indicates current progress.
     */
    private func readFiles(_ files: [URL], isRecursiveCall: Bool = false) {
        
        for file in files {
            
            // Always resolve sym links and aliases before reading the file
            let resolvedFile = file.resolvedURL
            
            if file.isDirectory {

                // Directory
                if !isRecursiveCall {session.addHistoryItem(resolvedFile)}
                
                if let dirContents = file.children {
                    readFiles(dirContents.sorted(by: {$0.lastPathComponent < $1.lastPathComponent}), isRecursiveCall: true)
                }

            } else {

                // Single file - playlist or track
                let fileExtension = resolvedFile.lowerCasedExtension

                if SupportedTypes.playlistExtensions.contains(fileExtension) {
                    
                    // Playlist
                    if !isRecursiveCall {session.addHistoryItem(resolvedFile)}
                    
                    if let loadedPlaylist = PlaylistIO.loadPlaylist(fromFile: resolvedFile) {
                        readPlaylistFiles(loadedPlaylist.tracks)
                    }
                    
                } else if SupportedTypes.allAudioExtensions.contains(fileExtension),
                          !session.trackList.hasTrack(forFile: resolvedFile) {
                    
                    // Track
                    if !isRecursiveCall {session.addHistoryItem(resolvedFile)}
                    
                    // True means batch is full and needs to be flushed.
                    if batch.append(file: resolvedFile) {
                        flushBatch()
                    }
                }
            }
        }
    }
    
    private func readPlaylistFiles(_ files: [URL]) {
        
        for resolvedFile in files {
            
            // Assume this is a resolved file
            
            // Playlists might contain broken file references
            guard resolvedFile.exists else {
                
                session.addError(FileNotFoundError(resolvedFile))
                continue
            }
            
            let fileExtension = resolvedFile.lowerCasedExtension
            
            if SupportedTypes.allAudioExtensions.contains(fileExtension),
               !session.trackList.hasTrack(forFile: resolvedFile),
               batch.append(file: resolvedFile) {
                
                // Track
                // True means batch is full and needs to be flushed.
                flushBatch()
            }
        }
    }
    
    func flushBatch() {
        
        queue.addOperations(batch.files.map(blockOpFunction), waitUntilFinished: true)
        
        session.batchCompleted(batch.files)
        let newIndices = session.trackList.acceptBatch(batch)
        session.observer.postBatchLoad(indices: newIndices)
        
        batch.clear()
    }
}
