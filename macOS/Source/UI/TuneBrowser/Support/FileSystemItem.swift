//
//  FileSystemItem.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Foundation

class FileSystemItem {
    
    private static var itemCache: [URL: FileSystemItem] = [:]
    private static let itemLock: ExclusiveAccessSemaphore = ExclusiveAccessSemaphore()
    
    static func create(forURL url: URL) -> FileSystemItem {
        
        itemLock.produceValueAfterWait {
            
            if let item = itemCache[url] {
                return item
            }
            
            let item = FileSystemItem(url: url)
            itemCache[url] = item
            
            return item
        }
    }
    
    let url: URL
    let path: String
    let name: String
    let fileExtension: String
    let type: FileSystemItemType
    
    var children: [FileSystemItem] = []
    var childrenLoaded: AtomicBool = AtomicBool(value: false)
    
    var isDirectory: Bool {type == .folder}
    
    var isPlaylist: Bool {type == .playlist}
    
    var isTrack: Bool {type == .track}
    
    var metadata: FileMetadata?
    
    fileprivate lazy var messenger = Messenger(for: self)
    
    private init(url: URL, metadata: FileMetadata? = nil) {
        
        self.url = url
        self.fileExtension = url.lowerCasedExtension
        self.path = url.path
        self.name = url.lastPathComponent
        
        if url.isDirectory {
            self.type = .folder
            
        } else if SupportedTypes.allAudioExtensions.contains(fileExtension) {
            self.type = .track
            
        } else if SupportedTypes.playlistExtensions.contains(fileExtension) {
            self.type = .playlist
            
        } else {
            self.type = .unsupported
        }
        
        self.metadata = metadata
    }
    
    func sortChildren(by sortField: FileSystemSortField, ascending: Bool) {
        
        switch sortField {
        
        case .name:
            
            children.sort(by: ascending ? {$0.name < $1.name} : {$0.name > $1.name})
            
        case .title:
            
            children.sort(by: {
                
                let title0: String = $0.metadata?.primary?.title ?? ""
                let title1: String = $1.metadata?.primary?.title ?? ""
                
                return ascending ? title0 < title1 : title0 > title1
            })
            
        case .artist:
            
            children.sort(by: {
                
                let artist0: String = $0.metadata?.primary?.artist ?? ""
                let artist1: String = $1.metadata?.primary?.artist ?? ""
                
                return ascending ? artist0 < artist1 : artist0 > artist1
            })
            
        case .album:
            
            children.sort(by: {
                
                let album0: String = $0.metadata?.primary?.album ?? ""
                let album1: String = $1.metadata?.primary?.album ?? ""
                
                return ascending ? album0 < album1 : album0 > album1
            })
            
        case .genre:
            
            children.sort(by: {
                
                let genre0: String = $0.metadata?.primary?.genre ?? ""
                let genre1: String = $1.metadata?.primary?.genre ?? ""
                
                return ascending ? genre0 < genre1 : genre0 > genre1
            })
            
        case .format:
            
            children.sort(by: {
                
                let metadata0: AudioInfo? = $0.metadata?.auxiliary?.audioInfo
                let metadata1: AudioInfo? = $1.metadata?.auxiliary?.audioInfo
                
                let format0: String = metadata0?.codec ?? metadata0?.format ?? ""
                let format1: String = metadata1?.codec ?? metadata1?.format ?? ""
                
                return ascending ? format0 < format1 : format0 > format1
            })
            
        case .duration:
            
            children.sort(by:   {
                
                let duration0: Double = $0.metadata?.primary?.duration ?? 0
                let duration1: Double = $1.metadata?.primary?.duration ?? 0
                
                return ascending ? duration0 < duration1 : duration0 > duration1
            } )
            
        case .year:
            
            children.sort(by:   {
                
                let year0: Int = $0.metadata?.primary?.year ?? 0
                let year1: Int = $1.metadata?.primary?.year ?? 0
                
                return ascending ? year0 < year1 : year0 > year1
            } )
            
        case .type:
            
            children.sort(by: {ascending ? $0.type < $1.type : $0.type > $1.type})
        }
    }
}

extension FileSystemItem: TrackLoaderReceiver {
    
    func hasTrack(forFile file: URL) -> Bool {
        false
    }
    
    func acceptBatch(_ batch: FileMetadataBatch) -> IndexSet {
        
        let children = batch.orderedMetadata.map {(file, metadata) -> FileSystemItem in
            FileSystemItem(url: file, metadata: metadata)
        }
        
        self.children.append(contentsOf: children)
        
        // TODO: Sorting ??? To maintain a user-specified sort order.
        
        return .empty
    }
}

extension FileSystemItem: TrackLoaderObserver {
    
    func preTrackLoad() {
//        messenger.publish(.playQueue_startedAddingTracks)
    }
    
    func postTrackLoad() {
//        messenger.publish(.playQueue_doneAddingTracks)
    }
    
    func postBatchLoad(indices: IndexSet) {
        messenger.publish(.fileSystem_childrenAddedToItem, payload: self)
    }
}

enum FileSystemItemType: Int, Comparable {
    
    case folder = 1
    case track = 2
    case playlist = 3
    case unsupported = 4
    
    static func < (lhs: FileSystemItemType, rhs: FileSystemItemType) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
}
