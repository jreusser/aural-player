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

class FileSystemTree: Destroyable {
    
    let root: FileSystemFolderItem
    
    var rootURL: URL {root.url}
    
    lazy var messenger: Messenger = .init(for: self)
    
    private var itemCache: [URL: FileSystemItem] = [:]
    
    func itemExists(forURL url: URL) -> Bool {
        itemCache[url] != nil
    }
    
    init?(sourceFolderURL: URL) {
        
        guard sourceFolderURL.exists else {return nil}
        root = FileSystemFolderItem(url: sourceFolderURL)
        
//        messenger.subscribe(to: .tuneBrowser_fileAdded, handler: folderChanged(_:))
//        messenger.subscribe(to: .tuneBrowser_fileDeleted, handler: folderChanged(_:))
    }
    
    func destroy() {
//        self.observer = nil
    }
    
//    private func getChildren(of item: FileSystemItem) -> [FileSystemItem] {
//        
//        switch item.type {
//            
//        case .folder:
//            
//            guard item.url.hasDirectoryPath, let dirContents = item.url.children else {return []}
//            
//            return dirContents.map {FileSystemItem.create(forURL: $0)}
//            .filter {$0.type != .unsupported}
//            .sorted(by: {$0.name.lowercased() < $1.name.lowercased()})
//            
//        case .playlist:
//            
//            guard let playlist = PlaylistIO.loadPlaylist(fromFile: item.url) else {return []}
//            return playlist.tracks.map {FileSystemItem.create(forURL: $0)}
//            
//        default:
//            
//            return []
//        }
//    }
//    
//    private let loadLock: ExclusiveAccessSemaphore = .init()
//    
//    func loadChildren(of item: FileSystemItem, force: Bool) {
//        
//        loadLock.executeAfterWait {
//            
//            if !force, item.childrenLoaded.value {return}
//            
//            if force {
//                print("Force-loading children of '\(item.path)'")
//            }
//            
//            item.childrenLoaded.setValue(true)
//            
//            DispatchQueue.global(qos: .userInteractive).async {
//                
//                item.setChildren(self.getChildren(of: item))
//                
//                if item.children.isEmpty {return}
//                
//                self.observedItem = item
//                
//                self.metadataLoader.loadMetadata(from: item.children.keys.elements,
//                                                 into: item, observer: self)
//            }
//        }
//    }
    
    func sort(by sortField: FileSystemSortField, ascending: Bool) {
//        root?.sortChildren(by: sortField, ascending: ascending)
    }
    
    // MARK: Notification handling ---------------------------------------------
    
//    private func folderChanged(_ notif: FileSystemFolderChangedNotification) {
//        
//        guard let theRoot = self.root else {return}
//        
//        let folder = notif.affectedURL.parentDir
//        print("\nFolder changed: \(folder.path)")
//        
//        var components: [String] = []
//        var parent: URL = folder
//        
//        while parent != FilesAndPaths.musicDir {
//            
//            components.append(parent.lastPathComponent)
//            parent = parent.parentDir
//        }
//        
//        print("\n\nGot Components: \(components)")
//        var curItem: FileSystemItem = theRoot
//        
//        for component in components {
//            
//            let targetURL = curItem.url.appendingPathComponent(component)
//            guard let child = curItem.children[targetURL] else {
//                
//                print("Child '\(component)' not found under: '\(curItem.url.path)'")
//                return
//            }
//            
//            curItem = child
//        }
//        
//        loadChildren(of: curItem, force: true)
//        messenger.publish(FileSystemItemUpdatedNotification(item: curItem))
//    }
}

//extension FileSystemTree: FileSystemLoaderObserver {
//    
//    func preTrackLoad() {
//    }
//    
//    func postTrackLoad() {
//    }
//    
//    func postBatchLoad(indices: IndexSet) {
//        
//        DispatchQueue.main.async {
//            self.observer?.itemsAdded(to: self.observedItem, at: indices)
//        }
//    }
//}

enum FileSystemSortField {
    
    case name, title, artist, album, genre, format, duration, year, type, trackNumber
}
