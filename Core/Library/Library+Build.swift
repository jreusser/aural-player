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

fileprivate var totalFiles: Int = 0
fileprivate var totalPlaylists: Int = 0

fileprivate var filesRead: AtomicIntCounter = .init()
fileprivate var playlistsRead: AtomicIntCounter = .init()
fileprivate var startedReadingFiles: Bool = false

fileprivate var metadata: ConcurrentMap<URL, FileMetadata> = ConcurrentMap()
fileprivate var playlists: ConcurrentMap<URL, FileSystemPlaylist> = ConcurrentMap()
fileprivate var playlistFiles: [URL] = []

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

extension Library {
    
    var progress: LibraryBuildStats? {
        
        startedReadingFiles ? .init(filesToRead: totalFiles, playlistsToRead: totalPlaylists, filesRead: filesRead.value, playlistsRead: playlistsRead.value) : nil
    }
    
    func buildLibrary() {
        
        _isBeingModified.setValue(true)
        
        removeAllTracks()
        _playlists.removeAll()
        fileSystemTrees.removeAll()
        
        for folder in sourceFolders {
            buildTree(forSourceFolder: folder)
        }
    }
    
    fileprivate func buildTree(forSourceFolder folder: URL) {
        
        let tree = FileSystemTree()
        
    }
    
    fileprivate func buildFolder(_ folder: URL, inTree tree: FileSystemTree, under parentFolder: FileSystemItem?) {
        
    }
    
    fileprivate func readAudioFile(_ file: URL) {
        
    }
    
    fileprivate func readPlaylistFile(_ file: URL) {
        
    }
}
