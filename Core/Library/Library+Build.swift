//
//  Library+Build.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import Foundation
import OrderedCollections

fileprivate var totalFiles: Int = 0
fileprivate var totalPlaylists: Int = 0

fileprivate var filesRead: AtomicIntCounter = .init()
fileprivate var playlistsRead: AtomicIntCounter = .init()
fileprivate var startedReadingFiles: Bool = false

fileprivate var metadata: ConcurrentMap<URL, FileMetadata> = ConcurrentMap()
fileprivate var fileSystemPlaylists: ConcurrentMap<URL, FileSystemPlaylist> = ConcurrentMap()
fileprivate var fsItems: OrderedDictionary<URL, FileSystemItem> = OrderedDictionary()

fileprivate var blockOpFunction: ((URL) -> BlockOperation)!

fileprivate let highPriorityQueue: OperationQueue = {
    
    let activeCores: Int = SystemUtils.numberOfActiveCores
    return OperationQueue(opCount: max(4, (Double(activeCores) * 1.5).roundedInt),
                   qos: .userInteractive)
}()

fileprivate let lowPriorityQueue: OperationQueue = {
    
    let physicalCores: Int = System.physicalCores
    return OperationQueue(opCount: max(physicalCores / 2, 2),
                   qos: .utility)
}()

fileprivate var chosenQueue: OperationQueue!

extension Library {
    
    var progress: LibraryBuildStats? {
        
        startedReadingFiles ?
            .init(filesToRead: totalFiles, playlistsToRead: totalPlaylists, filesRead: filesRead.value, playlistsRead: playlistsRead.value) :
        nil
    }
    
    func buildLibrary(immediate: Bool) {
        
        chosenQueue = immediate ? highPriorityQueue : lowPriorityQueue
        
        _isBeingModified.setValue(true)
        
        removeAllTracks()
        _playlists.removeAll()
        fileSystemTrees.removeAll()
        
        for folder in sourceFolders {
            buildTree(forSourceFolder: folder)
        }
        
        chosenQueue.waitUntilAllOperationsAreFinished()
        
        for playlist in self.playlists {
            
            guard let fsPlaylist = fileSystemPlaylists[playlist.file] else {continue}
            var tracksToAdd: [Track] = []
            var trackItemsToAdd: [FileSystemTrackItem] = []
            
            for file in fsPlaylist.tracks {
                
                let trackForFile: Track
                
                if let track = self._tracks[file] {
                    
                    trackForFile = track
                    tracksToAdd.append(track)
                    
                } else {
                    
                    let newTrack = Track(file)
                    trackForFile = newTrack
                    tracksToAdd.append(newTrack)
                    
                    chosenQueue.addOperation {
                        newTrack.setPrimaryMetadata(from: self.metadata(forFile: file))
                    }
                }
                
                if let trackItem = fsItems[file] as? FileSystemTrackItem {
                    trackItemsToAdd.append(trackItem)
                    
                } else {
                    
                    let newTrackItem = FileSystemTrackItem(track: trackForFile)
                    trackItemsToAdd.append(newTrackItem)
                }
            }
            
            playlist.addTracks(tracksToAdd)
            
            if let fsItemForPlaylist = fsItems[playlist.file] as? FileSystemPlaylistItem {
                
                for trackItem in trackItemsToAdd {
                    fsItemForPlaylist.addChild(trackItem)
                }
            }
        }
        
        chosenQueue.waitUntilAllOperationsAreFinished()
    }
    
    fileprivate func buildTree(forSourceFolder folder: URL) {
        
        guard let tree = FileSystemTree(sourceFolderURL: folder) else {return}
        fileSystemTrees[folder] = tree
        
        buildFolder(tree.root)
    }
    
    fileprivate func buildFolder(_ folder: FileSystemFolderItem) {
        
        guard let children = folder.url.children else {return}
        let supportedChildren = children.filter {$0.isDirectory || $0.isSupportedFile}
        
        for child in supportedChildren {
            
            if child.isDirectory {
                
                let childFolder = FileSystemFolderItem(url: child)
                folder.addChild(childFolder)
                
                buildFolder(childFolder)
                
            } else if child.isSupportedAudioFile {
                readAudioFile(child, under: folder)
                
            } else if child.isSupportedPlaylistFile {
                readPlaylistFile(child, under: folder)
            }
        }
    }
    
    fileprivate func readAudioFile(_ file: URL, under folder: FileSystemFolderItem) {
        
        let newTrack = Track(file)
        let childTrack = FileSystemTrackItem(track: newTrack)
        folder.addChild(childTrack)
        fsItems[file] = childTrack
        
        addTracks([newTrack])
        
        chosenQueue.addOperation {
            
            newTrack.setPrimaryMetadata(from: self.metadata(forFile: file))
            filesRead.increment()
        }
    }
    
    private func metadata(forFile file: URL) -> FileMetadata {
        
        var fileMetadata = FileMetadata()
        
        do {
            fileMetadata.primary = try fileReader.getPrimaryMetadata(for: file)
        } catch {
            fileMetadata.validationError = error as? DisplayableError
        }
        
        return fileMetadata
    }
    
    fileprivate func readPlaylistFile(_ file: URL, under folder: FileSystemFolderItem) {
        
        let newPlaylist = ImportedPlaylist(file: file, tracks: [])
        let childPlaylist = FileSystemPlaylistItem(playlist: newPlaylist)
        folder.addChild(childPlaylist)
        fsItems[file] = childPlaylist
        
        addPlaylists([newPlaylist])
        
        chosenQueue.addOperation {
            
            if let loadedPlaylist = PlaylistIO.loadPlaylist(fromFile: file) {
                fileSystemPlaylists[file] = loadedPlaylist
            }
            
            playlistsRead.increment()
            print("PlaylistsRead: \(playlistsRead.value)")
        }
    }
}
