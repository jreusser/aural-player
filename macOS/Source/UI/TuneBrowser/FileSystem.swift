//
//  FileSystem.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

class FileSystem {
    
    private let opQueue: OperationQueue = OperationQueue()
    private let concurrentOpCount = (Double(SystemUtils.numberOfActiveCores) * 1.5).roundedInt
    
    var root: FileSystemItem = FileSystemItem.create(forURL: FilesAndPaths.musicDir) {
        
        didSet {
            loadMetadata(forChildrenOf: root)
        }
    }
    
    var rootURL: URL {
        
        get {root.url}
        set(newURL) {root = FileSystemItem.create(forURL: newURL)}
    }
    
    private lazy var messenger = Messenger(for: self)
    
    init() {
        
        opQueue.maxConcurrentOperationCount = concurrentOpCount
        opQueue.underlyingQueue = DispatchQueue.global(qos: .utility)
        opQueue.qualityOfService = .utility
    }
    
    func loadMetadata(forChildrenOf item: FileSystemItem) {
        
        if item.metadataLoadedForChildren {
            return
        }
        
        DispatchQueue.global(qos: .userInitiated).async {

            item.metadataLoadedForChildren = true

            // We need to load metadata only for supported tracks (ignore folders, playlists, or unsupported files).
            for child in item.children.filter({$0.isTrack}) {

                if let cachedMetadata = metadataRegistry[child.url] {

                    var metadata = FileMetadata()
                    child.metadata = metadata

                    var playlistMetadata = PrimaryMetadata()

                    playlistMetadata.title = cachedMetadata.title

                    playlistMetadata.artist = cachedMetadata.artist
                    playlistMetadata.albumArtist = cachedMetadata.albumArtist
//                    playlistMetadata.performer = track.performer

                    playlistMetadata.album = cachedMetadata.album
                    playlistMetadata.genre = cachedMetadata.genre

                    playlistMetadata.duration = cachedMetadata.duration

                    playlistMetadata.trackNumber = cachedMetadata.trackNumber
                    playlistMetadata.totalTracks = cachedMetadata.totalTracks
                    playlistMetadata.discNumber = cachedMetadata.discNumber
                    playlistMetadata.totalDiscs = cachedMetadata.totalDiscs

                    metadata.primary = playlistMetadata

                    // Bool return value indicates whether any metadata was loaded.
                    var concurrentAsyncOps: [() -> Bool] = []
                    
                    concurrentAsyncOps.append {[weak child] in
                        
                        guard let theChild = child else {return false}
                        metadata.auxiliary = fileReader.getAuxiliaryMetadata(for: theChild.url)
                        return true
                    }
                    
                    concurrentAsyncOps.append {[weak child] in
                        
                        guard let theChild = child else {return false}
                        metadata.coverArt = fileReader.getArt(for: theChild.url)?.image
                        return metadata.coverArt != nil
                    }

                    if concurrentAsyncOps.isNonEmpty {

                        self.opQueue.addOperation {[weak child] in

                            guard let theChild = child else {return}

                            var needToNotify: Bool = false

                            for op in concurrentAsyncOps {
                                needToNotify = op() || needToNotify
                            }

                            if needToNotify {
                                self.messenger.publish(.fileSystem_fileMetadataLoaded, payload: theChild)
                            }
                        }

                    } else {
                        self.messenger.publish(.fileSystem_fileMetadataLoaded, payload: child)
                    }

                    continue
                }

                self.opQueue.addOperation {[weak self, weak child] in

                    guard let theChild = child else {return}

                    theChild.metadata = fileReader.getAllMetadata(for: theChild.url)
                    self?.messenger.publish(.fileSystem_fileMetadataLoaded, payload: theChild)
                }
            }
        }
    }
    
    func sort(by sortField: FileSystemSortField, ascending: Bool) {
        root.sortChildren(by: sortField, ascending: ascending)
    }
}

enum FileSystemSortField {
    
    case name, title, artist, album, genre, format, duration, year, type
}
