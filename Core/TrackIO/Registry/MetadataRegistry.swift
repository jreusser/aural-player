//
//  MetadataRegistry.swift
//  Aural
//
//  Copyright © 2023 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import Foundation

class MetadataRegistry: PersistentModelObject {
    
    private let registry: ConcurrentMap<URL, PrimaryMetadata> = ConcurrentMap()
    private let opQueue: OperationQueue = .init(opCount: System.physicalCores, qos: .userInteractive)
    lazy var messenger: Messenger = Messenger(for: self)
    
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
    
    func loadMetadataForFiles(files: Set<URL>, completionHandler: @escaping () -> ()) {
        
        print("MetadataRegistry: Reading \(files.count) files ...")
        
        DispatchQueue.global(qos: .userInteractive).async {
            
            for file in files {
                
                self.opQueue.addOperation {
                    
                    if let metadata = try? fileReader.getPrimaryMetadata(for: file) {
                        self.registry[file] = metadata
                    }
                }
            }
            
            print("MetadataRegistry: Waiting to finish reading \(self.opQueue.operationCount) files ...")
            
            self.opQueue.waitUntilAllOperationsAreFinished()
            
            print("MetadataRegistry: Done reading files!")
            completionHandler()
        }
    }
}
