//
//  ImportedPlaylist.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import Foundation

class ImportedPlaylist: TrackList, PlaylistProtocol, UserManagedObject, TrackLoaderObserver {

    var file: URL
    var name: String
    
    var key: String {

        get {name}
        set {name = newValue}
    }

    let userDefined: Bool = true
    
    init(file: URL, tracks: [Track]) {
        
        self.file = file
        self.name = file.nameWithoutExtension
        
        super.init()
        addTracks(tracks)
        
        print("Read playlist: '\(name)' with \(self.size) tracks")
    }
    
    func loadTracks(from files: [URL], atPosition position: Int?) {}
    
    func preTrackLoad() {}
    
    func postTrackLoad() {}
    
    func postBatchLoad(indices: IndexSet) {}
}
