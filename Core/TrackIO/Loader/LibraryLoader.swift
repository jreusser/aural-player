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
    var playlists: ConcurrentMap<URL, FileSystemPlaylist> = ConcurrentMap()
    var playlistFiles: [URL] = []
    
    var blockOpFunction: ((URL) -> BlockOperation)!
    
    private lazy var messenger: Messenger = .init(for: self)
    
    private let queue: OperationQueue = OperationQueue()
    
    init() {
        
        self.priority = .highest
        self.qOS = .userInteractive
        
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
            self.messenger.publish(.library_startedAddingTracks, payload: LibraryBuildStats(filesToRead: self.totalFiles, playlistsToRead: self.totalPlaylists))
            
            self.queue.waitUntilAllOperationsAreFinished()
            
            var tracks: [Track] = []
            for (url, fileMetadata) in self.metadata.map {
                tracks.append(Track(url, fileMetadata: fileMetadata))
            }
            
            library.addTracks(tracks)
            
            self.readPlaylists()
            
            self.messenger.publish(.library_doneAddingTracks)
            
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
            
            // Always resolve sym links and aliases before reading the file
            let resolvedFile = file.resolvedURL

            if resolvedFile.isDirectory {

                // Directory
                
                if let dirContents = resolvedFile.children {
                    readFiles(dirContents, isRecursiveCall: true)
                }

            } else {

                // Single file - playlist or track
                let fileExtension = resolvedFile.pathExtension.lowercased()

                if SupportedTypes.playlistExtensions.contains(fileExtension) {
                    
                    totalPlaylists.increment()
                    playlistFiles.append(resolvedFile)
                    
                } else if SupportedTypes.allAudioExtensions.contains(fileExtension) {
                    
                    // True means batch is full and needs to be flushed.
                    totalFiles.increment()
                    queue.addOperation(blockOpFunction(resolvedFile))
                }
            }
        }
    }
    
    private func readPlaylists() {
        
        // TODO: Read metadata in batches.
        // Skip files that don't exist.
        
        for playlistFile in playlistFiles {
            
            queue.addOperation {
                
                if let loadedPlaylist = PlaylistIO.loadPlaylist(fromFile: playlistFile) {
                    self.playlists[playlistFile] = loadedPlaylist
                }
                
                self.playlistsRead.increment()
            }
        }
        
        queue.waitUntilAllOperationsAreFinished()
        
        var playlistsToAdd: [ImportedPlaylist] = []
        for (_, plst) in self.playlists.map {
            playlistsToAdd.append(ImportedPlaylist(fileSystemPlaylist: plst))
        }
        
        library.addPlaylists(playlistsToAdd)
    }
    
    private func blockOp(metadataType: MetadataType) -> ((URL) -> BlockOperation) {
        
        return {file in BlockOperation {
            
            var fileMetadata = FileMetadata()

            do {
                fileMetadata.primary = try fileReader.getPrimaryMetadata(for: file)
            } catch {
                fileMetadata.validationError = error as? DisplayableError
            }

            self.metadata[file] = fileMetadata
            self.filesRead.increment()
        }}
    }
}

struct LibraryBuildStats {
    
    let filesToRead: Int
    let playlistsToRead: Int
}
