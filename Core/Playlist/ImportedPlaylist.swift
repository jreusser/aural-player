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
    
    init(fileSystemPlaylist: FileSystemPlaylist) {
        
        self.file = fileSystemPlaylist.file
        self.name = fileSystemPlaylist.file.nameWithoutExtension
        
        super.init()
        
        var tracksToAdd: [Track] = []
        
        for file in fileSystemPlaylist.tracks {
            
            if let track = library.findTrack(forFile: file) {
                tracksToAdd.append(track)
                
            } else {
                
                print("No metadata for: \(file.absoluteString)\nPath: \(file.path)\n\n")
                
                var fileMetadata = FileMetadata()

                do {
                    fileMetadata.primary = try fileReader.getPrimaryMetadata(for: file)
                } catch {
                    fileMetadata.validationError = error as? DisplayableError
                }
                
                let track = Track(file, fileMetadata: fileMetadata)
                tracksToAdd.append(track)
            }
        }
        
        addTracks(tracksToAdd)
    }
    
    func loadTracks(from files: [URL], atPosition position: Int?) {}
    
    func preTrackLoad() {}
    
    func postTrackLoad() {}
    
    func postBatchLoad(indices: IndexSet) {}
}
