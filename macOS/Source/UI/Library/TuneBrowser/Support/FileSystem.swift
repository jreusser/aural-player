//
//  FileSystem.swift
//  Aural
//
//  Copyright © 2023 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

protocol FileSystemUIObserver {
    
    func itemsAdded(to item: FileSystemItem, at indices: IndexSet)
}

class FileSystem {
    
    private let metadataLoader: FileSystemLoader = FileSystemLoader(priority: .medium)
    
    let observer: FileSystemUIObserver
    var observedItem: FileSystemItem!
    
    init(observer: FileSystemUIObserver) {
        self.observer = observer
    }
    
    var root: FileSystemItem? = nil {
        
        didSet {
            
            if let theRoot = root {
                loadChildren(of: theRoot)
            }
        }
    }
    
    var rootURL: URL? {
        
        get {root?.url}
        
        set(newURL) {
            
            if let theURL = newURL {
                root = FileSystemItem.create(forURL: theURL)
            }
        }
    }
    
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
            
            if item.childrenLoaded.value {return}
            
            item.childrenLoaded.setValue(true)
            
            DispatchQueue.global(qos: .userInteractive).async {
                
                item.setChildren(self.getChildren(of: item))
                
                if item.children.isEmpty {return}
                
                self.observedItem = item
                
                self.metadataLoader.loadMetadata(from: item.children.keys.elements,
                                                 into: item, observer: self)
            }
        }
    }
    
    func sort(by sortField: FileSystemSortField, ascending: Bool) {
        root?.sortChildren(by: sortField, ascending: ascending)
    }
}

extension FileSystem: FileSystemLoaderObserver {
    
    func preTrackLoad() {
    }
    
    func postTrackLoad() {
    }
    
    func postBatchLoad(indices: IndexSet) {
        
        DispatchQueue.main.async {
            self.observer.itemsAdded(to: self.observedItem, at: indices)
        }
    }
}

enum FileSystemSortField {
    
    case name, title, artist, album, genre, format, duration, year, type, trackNumber
}
