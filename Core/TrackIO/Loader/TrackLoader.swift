//
//  TrackLoader.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import Foundation

// TODO: How to deal with duplicate tracks ? (track is loaded individually and as part of a playlist)
// What if a track exists in a different track list ? (Play Queue / Library). Should we have a global track registry ?
// What about notifications / errors ? Return a result ?
// Create a track load session and a batch class
// How to deal with 2 simultaneous sessions on startup ? Play queue / Library / Custom playlists ? Adjust batch size accordingly ?
class TrackLoader {
    
    private let fileReader: FileReader = FileReader()
    
    private var session: FileReadSession!
    private var batch: FileMetadataBatch!
    var blockOpFunction: ((URL) -> BlockOperation)!
    
    func blockOp(metadataType: MetadataType) -> ((URL) -> BlockOperation) {
        
        return {file in BlockOperation {
            
//            let fileMetadata = FileMetadata()
//
//            do {
//
//                switch metadataType {
//
//                case .primary:
//
//                    fileMetadata.primary = try self.fileReader.getPrimaryMetadata(for: file)
//
//                case .playback:
//
//                    fileMetadata.playback = try self.fileReader.getPlaybackMetadata(file: file)
//                }
//
//            } catch {
//                fileMetadata.validationError = error as? DisplayableError
//            }
//
//            self.batch.setMetadata(fileMetadata, for: file)
        }}
    }
    
    private let queue: OperationQueue = OperationQueue()
    private let concurrentAddOpCount = (Double(SystemUtils.numberOfActiveCores) * 1.5).roundedInt
    
    init() {
        
        queue.maxConcurrentOperationCount = concurrentAddOpCount
        queue.underlyingQueue = DispatchQueue.global(qos: .userInteractive)
        queue.qualityOfService = .userInteractive
    }
    
    // TODO: Allow the caller to specify a "sort order" for the files, eg. by file path ???
    func loadMetadata(ofType type: MetadataType, from files: [URL], into trackList: TrackListProtocol, completionHandler: FileReadSessionCompletionHandler? = nil) {
        
        session = FileReadSession(metadataType: type, trackList: trackList)
        batch = FileMetadataBatch(ofSize: concurrentAddOpCount)
        blockOpFunction = blockOp(metadataType: type)
        
        // Move to a background thread to unblock the main thread
        DispatchQueue.global(qos: .userInteractive).async {
            
            self.readFiles(files)
            
            if self.batch.fileCount > 0 {
                self.flushBatch()
            }
            
            let sessionFiles = self.session.files
            
            // Cleanup
            self.session = nil
            self.batch = nil
            self.blockOpFunction = nil
            
            // Unblock this thread because the track list may perform a time consuming task in response to this callback.
            if let theCompletionHandler = completionHandler {
                
                DispatchQueue.global(qos: .userInteractive).async {
                    theCompletionHandler(sessionFiles)
                }
            }
        }
    }
    
    /*
     Adds a bunch of files synchronously.
     
     The autoplayOptions argument encapsulates all autoplay options.
     
     The progress argument indicates current progress.
     */
    private func readFiles(_ files: [URL], _ isRecursiveCall: Bool = false) {
        
        for file in files {
            
            // Playlists might contain broken file references
            guard file.exists else {

                session.addError(FileNotFoundError(file))
                continue
            }

            // Always resolve sym links and aliases before reading the file
            let resolvedFile = file.resolvedURL

            if file.isDirectory {

                // Directory
                if !isRecursiveCall {session.addHistoryItem(resolvedFile)}
                
                if let dirContents = file.children {
                    readFiles(dirContents.sorted(by: {$0.lastPathComponent < $1.lastPathComponent}), true)
                }

            } else {

                // Single file - playlist or track
                let fileExtension = resolvedFile.pathExtension.lowercased()

                if SupportedTypes.playlistExtensions.contains(fileExtension) {
                    
                    // Playlist
                    if !isRecursiveCall {session.addHistoryItem(resolvedFile)}
                    
                    if let loadedPlaylist = PlaylistIO.loadPlaylist(fromFile: resolvedFile) {
                        readFiles(loadedPlaylist.tracks, true)
                    }
                    
                } else if SupportedTypes.allAudioExtensions.contains(fileExtension),
                          session.trackList.shouldLoad(file: resolvedFile) {
                    
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
    
    func flushBatch() {
        
        queue.addOperations(batch.files.map(blockOpFunction), waitUntilFinished: true)
        
        session.batchCompleted(batch.files)
        session.trackList.acceptBatch(batch)
        
        batch.clear()
    }
}
