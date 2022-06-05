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
    
    private let metadataLoader: FileSystemLoader = FileSystemLoader(priority: .medium)
    
    var root: FileSystemItem = FileSystemItem.create(forURL: FilesAndPaths.musicDir.appendingPathComponent("Ambient").appendingPathComponent("The Sushi Club")) {
        
        didSet {
            loadChildren(of: root)
        }
    }
    
    var rootURL: URL {
        
        get {root.url}
        set(newURL) {root = FileSystemItem.create(forURL: newURL)}
    }
    
    private lazy var messenger = Messenger(for: self)
    
    private func getChildren(of item: FileSystemItem) -> [FileSystemItem] {
        
        switch item.type {
            
        case .folder:
            
            guard item.url.hasDirectoryPath, let dirContents = item.url.children else {return []}
            
            return dirContents.map {FileSystemItem.create(forURL: $0)}
            .filter {$0.type != .unsupported}
            .sorted(by: {$0.name.lowercased() < $1.name.lowercased()})
            
        case .playlist:
            
            guard let playlist = PlaylistIO.loadPlaylist(fromFile: item.url) else {return []}
            return playlist.tracks.map {FileSystemItem.create(forURL: $0)}
            
        default:
            
            return []
        }
    }
    
    private let loadLock: ExclusiveAccessSemaphore = .init()
    
    func loadChildren(of item: FileSystemItem) {
        
        loadLock.executeAfterWait {
            
            if item.childrenLoaded.value {
                return
            }
            
            item.childrenLoaded.setValue(true)
            
            DispatchQueue.global(qos: .userInteractive).async {
                
                item.setChildren(self.getChildren(of: item))
                
                if item.children.isEmpty {return}
                
                self.metadataLoader.loadMetadata(from: item.children.keys.elements,
                                                 into: item, observer: item)
            }
        }
    }
    
    func sort(by sortField: FileSystemSortField, ascending: Bool) {
        root.sortChildren(by: sortField, ascending: ascending)
    }
}

enum FileSystemSortField {
    
    case name, title, artist, album, genre, format, duration, year, type, trackNumber
}
