//
//  LibraryLoader.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import Foundation

class LibraryLoader {
    
    let priority: FileLoaderPriority
    let qOS: DispatchQoS.QoSClass
    
    var totalFiles: Int = 0
    var totalPlaylists: Int = 0
    
    var filesRead: AtomicIntCounter = .init()
    var playlistsRead: AtomicIntCounter = .init()
    
    var progress: Double {
        Double(filesRead.value + playlistsRead.value) * 100 / Double(totalFiles + totalPlaylists)
    }
    
    var metadata: ConcurrentMap<URL, FileMetadata> = ConcurrentMap()
    
    var blockOpFunction: ((URL) -> BlockOperation)!
    
    private lazy var messenger: Messenger = .init(for: self)
    
    private let queue: OperationQueue = OperationQueue()
    
    init() {
        
        self.priority = .medium
        self.qOS = .utility
        
        queue.maxConcurrentOperationCount = priority.concurrentOpCount
        queue.underlyingQueue = DispatchQueue.global(qos: qOS)
        queue.qualityOfService = .userInteractive
    }
    
    // TODO: Allow the caller to specify a "sort order" for the files, eg. by file path ???
    func loadMetadata(ofType type: MetadataType, from files: [URL], completionHandler: VoidFunction? = nil) {
        
        blockOpFunction = blockOp(metadataType: type)
        
        // Move to a background thread to unblock the main thread.
        DispatchQueue.global(qos: qOS).async {
            
            defer {completionHandler?()}
            
            self.readFiles(files)
            self.messenger.publish(.library_startedAddingTracks)
            
            print("Detected \(self.totalFiles) files and \(self.totalPlaylists) playlists. Now reading ...")
            
            self.queue.waitUntilAllOperationsAreFinished()
            self.messenger.publish(.library_doneAddingTracks)
            
            print("Finished reading.")
            
            // Cleanup
            self.blockOpFunction = nil
            self.metadata.removeAll()
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
//            guard file.exists else {
//
////                session.addError(FileNotFoundError(file))
//                continue
//            }

            // Always resolve sym links and aliases before reading the file
//            let resolvedFile = file.resolvedURL
//            let resolvedFile = file

            if file.isDirectory {

                // Directory
                
                if let dirContents = file.children {
                    readFiles(dirContents.sorted(by: {$0.lastPathComponent < $1.lastPathComponent}), isRecursiveCall: true)
                }

            } else {

                // Single file - playlist or track
                let fileExtension = file.pathExtension.lowercased()

                if SupportedTypes.playlistExtensions.contains(fileExtension) {
                    
//                    if let loadedPlaylist = PlaylistIO.loadPlaylist(fromFile: resolvedFile) {
//                        readFiles(loadedPlaylist.tracks, isRecursiveCall: true)
                        totalPlaylists.increment()
//                    }
                    
                } else if SupportedTypes.allAudioExtensions.contains(fileExtension) {
                    
                    // True means batch is full and needs to be flushed.
                    totalFiles.increment()
                    queue.addOperation(blockOpFunction(file))
                }
            }
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

            self.metadata[file] = fileMetadata
            self.filesRead.increment()
        }}
    }
    
    func flushBatch() {
        
//        queue.addOperations(batch.files.map(blockOpFunction), waitUntilFinished: true)
//        
//        session.batchCompleted(batch.files)
//        let newIndices = session.trackList.acceptBatch(batch)
//        session.observer.postBatchLoad(indices: newIndices)
//        
//        batch.clear()
    }
}
