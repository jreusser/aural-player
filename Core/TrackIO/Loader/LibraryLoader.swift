//
//  LibraryLoader.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
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
    var startedReadingFiles: Bool = false
    
//    var progress: LibraryBuildStats? {
//        startedReadingFiles ? .init(filesToRead: totalFiles, playlistsToRead: totalPlaylists, filesRead: filesRead.value, playlistsRead: playlistsRead.value) : nil
//    }
    
    var metadata: ConcurrentMap<URL, FileMetadata> = ConcurrentMap()
    var playlists: ConcurrentMap<URL, FileSystemPlaylist> = ConcurrentMap()
    var playlistFiles: [URL] = []
    
    var blockOpFunction: ((URL) -> BlockOperation)!
    
    private lazy var messenger: Messenger = .init(for: self)
    
    private let queue: OperationQueue = OperationQueue()
    
    init() {
        
//        self.priority = .medium
//        self.qOS = .utility
        
        self.priority = .highest
        self.qOS = .userInteractive
        
        queue.maxConcurrentOperationCount = priority.concurrentOpCount
        queue.underlyingQueue = DispatchQueue.global(qos: qOS)
        queue.qualityOfService = .userInteractive
    }
    
    // TODO: Allow the caller to specify a "sort order" for the files, eg. by file path ???
    func loadMetadata(ofType type: MetadataType, from files: [URL], completionHandler: VoidFunction? = nil) {
        
        blockOpFunction = fileReadBlockOp()
        
        // Move to a background thread to unblock the main thread.
        DispatchQueue.global(qos: qOS).async {
            
            defer {completionHandler?()}
            
            self.messenger.publish(.library_startedReadingFileSystem)
            
            self.readFiles(files)
            self.startedReadingFiles = true
            
            self.messenger.publish(.library_startedAddingTracks)
            
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
            self.startedReadingFiles = false
        }
    }
    
    /*
     Adds a bunch of files synchronously.
     
     The autoplayOptions argument encapsulates all autoplay options.
     
     The progress argument indicates current progress.
     */
    private func readFiles(_ files: [URL]) {
        
        for file in files {
            
            // Always resolve sym links and aliases before reading the file
            let resolvedFile = file.resolvedURL

            if resolvedFile.isDirectory {

                // Directory
                
                if let dirContents = resolvedFile.children {
                    readFiles(dirContents)
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
        
        // MARK: Step 1 - Load all playlist files ------------------------
        
        for playlistFile in playlistFiles {
            
            queue.addOperation {
                
                if let loadedPlaylist = PlaylistIO.loadPlaylist(fromFile: playlistFile) {
                    self.playlists[playlistFile] = loadedPlaylist
                }
                
                self.playlistsRead.increment()
                print("PlaylistsRead: \(self.playlistsRead.value)")
            }
        }
        
        if queue.operationCount > 0 {
            queue.waitUntilAllOperationsAreFinished()
        }
        
        // MARK: Step 2 - Load metadata for all files referenced by the playlists (if not already present as Tracks in Library) ------------------------
        
        self.metadata.removeAll()
        
        for plst in self.playlists.map.values {
            
            for file in plst.tracks {
                
                if !library.hasTrack(forFile: file) {
                    queue.addOperation(fileReadBlockOp()(file))
                }
            }
        }
        
        if queue.operationCount > 0 {
            queue.waitUntilAllOperationsAreFinished()
        }
        
        // MARK: Step 3 - Add all playlists to the Library ------------------------
        
        var playlistsToAdd: [ImportedPlaylist] = []
        for plst in self.playlists.map.values {
            
            var plstTracks: [Track] = []
            
            for file in plst.tracks {
                
                if let track = library.findTrack(forFile: file) {
                    plstTracks.append(track)
                    
                } else {
                    plstTracks.append(Track(file, fileMetadata: self.metadata[file]))
                }
            }
            
            playlistsToAdd.append(ImportedPlaylist(file: plst.file, tracks: plstTracks))
        }
        
        library.addPlaylists(playlistsToAdd)
    }
    
    private func fileReadBlockOp() -> ((URL) -> BlockOperation) {
        
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
    
    // TODO: Implement this !
    private func playlistReadBlockOp() -> ((URL) -> BlockOperation) {
        
        return {file in BlockOperation {
            
            var fileMetadata = FileMetadata()

            do {
                fileMetadata.primary = try fileReader.getPrimaryMetadata(for: file)
            } catch {
                fileMetadata.validationError = error as? DisplayableError
            }

            self.metadata[file] = fileMetadata
            self.playlistsRead.increment()
        }}
    }
}

struct LibraryBuildStats {
    
    let filesToRead: Int
    let playlistsToRead: Int
    
    let filesRead: Int
    let playlistsRead: Int
    
    var progressPercentage: Double {
        Double(filesRead + playlistsRead) * 100 / Double(filesToRead + playlistsToRead)
    }
}
