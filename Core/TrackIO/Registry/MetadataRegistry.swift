//
//  MetadataRegistry.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import Foundation

class MetadataRegistry: PersistentModelObject {
    
    private let registry: ConcurrentMap<URL, PrimaryMetadata> = ConcurrentMap()
    
    init(persistentState: MetadataPersistentState?) {
        
        for entry in persistentState?.metadata ?? [:] {
            registry[entry.key] = PrimaryMetadata(persistentState: entry.value)
        }
    }
    
    subscript(_ key: URL) -> PrimaryMetadata? {
        
        get {
            registry[key]
        }
        
        set {
            registry[key] = newValue
        }
    }
    
    var persistentState: MetadataPersistentState {
        
        var map: [URL: PrimaryMetadataPersistentState] = [:]
        
        for (file, metadata) in registry.map {
            map[file] = PrimaryMetadataPersistentState(metadata: metadata)
        }
        
        return MetadataPersistentState(metadata: map)
    }
}
