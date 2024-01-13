//
//  FileSystemItem.swift
//  Aural
//
//  Copyright © 2023 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//

import Foundation
import OrderedCollections

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
    
    var children: OrderedDictionary<URL, FileSystemItem> = OrderedDictionary()
    var childrenLoaded: AtomicBool = AtomicBool(value: false)
    
    func setChildren(_ children: [FileSystemItem]) {
        
        self.children.removeAll()
        
        for child in children {
            self.children[child.url] = child
        }
    }
    
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

            children.sortValues(by: ascending ? {$0.name < $1.name} : {$0.name > $1.name})
            
        case .title:

            children.sortValues(by: {

                let title0: String = $0.metadata?.primary?.title ?? ""
                let title1: String = $1.metadata?.primary?.title ?? ""

                return ascending ? title0 < title1 : title0 > title1
            })

        case .artist:

            children.sortValues(by: {

                let artist0: String = $0.metadata?.primary?.artist ?? ""
                let artist1: String = $1.metadata?.primary?.artist ?? ""

                return ascending ? artist0 < artist1 : artist0 > artist1
            })

        case .album:

            children.sortValues(by: {

                let album0: String = $0.metadata?.primary?.album ?? ""
                let album1: String = $1.metadata?.primary?.album ?? ""

                return ascending ? album0 < album1 : album0 > album1
            })

        case .genre:

            children.sortValues(by: {

                let genre0: String = $0.metadata?.primary?.genre ?? ""
                let genre1: String = $1.metadata?.primary?.genre ?? ""

                return ascending ? genre0 < genre1 : genre0 > genre1
            })
            
        case .format:
            
            children.sortValues(by: {
                
                let metadata0: AudioInfo? = $0.metadata?.auxiliary?.audioInfo
                let metadata1: AudioInfo? = $1.metadata?.auxiliary?.audioInfo
                
                let format0: String = metadata0?.codec ?? metadata0?.format ?? ""
                let format1: String = metadata1?.codec ?? metadata1?.format ?? ""
                
                return ascending ? format0 < format1 : format0 > format1
            })
            
        case .duration:
            
            children.sortValues(by: {
                
                let duration0: Double = $0.metadata?.primary?.duration ?? 0
                let duration1: Double = $1.metadata?.primary?.duration ?? 0
                
                return ascending ? duration0 < duration1 : duration0 > duration1
            } )
            
        case .year:
            
            children.sortValues(by: {
                
                let year0: Int = $0.metadata?.primary?.year ?? 0
                let year1: Int = $1.metadata?.primary?.year ?? 0
                
                return ascending ? year0 < year1 : year0 > year1
            } )
            
        case .trackNumber:
            
            children.sortValues(by: {
                
                let trackNum0: Int = $0.metadata?.primary?.trackNumber ?? 0
                let trackNum1: Int = $1.metadata?.primary?.trackNumber ?? 0
                
                return ascending ? trackNum0 < trackNum1 : trackNum0 > trackNum1
            } )
            
        case .type:
            
            children.sortValues(by: {ascending ? $0.type < $1.type : $0.type > $1.type})
        }
    }
    
    func toTrack() -> Track? {
        isTrack ? Track(url, fileMetadata: metadata) : nil
    }
}

extension FileSystemItem: FileSystemLoaderReceiver {

    func acceptBatch(_ batch: FileSystemMetadataBatch) -> IndexSet {
        
        for (file, metadata) in batch.metadata.map {
            children[file]?.metadata = metadata
        }
        
        // TODO: Sorting ??? To maintain a user-specified sort order.
        
        return batch.indices
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
