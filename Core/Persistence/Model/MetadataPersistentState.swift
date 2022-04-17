//
//  MetadataPersistentState.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import Foundation

struct MetadataPersistentState: Codable {
    
    let metadata: [URL: PrimaryMetadataPersistentState]
}

struct PrimaryMetadataPersistentState: Codable {
    
    let title: String?
    let artist: String?
    let albumArtist: String?
    let album: String?
    let genre: String?
    
    let trackNumber: Int?
    let totalTracks: Int?
    
    let discNumber: Int?
    let totalDiscs: Int?
    
    let duration: Double?
    let isProtected: Bool?
    
    init(metadata: PrimaryMetadata) {
        
        self.title = metadata.title
        self.artist = metadata.artist
        self.album = metadata.album
        self.albumArtist = metadata.albumArtist
        self.genre = metadata.genre
        
        self.trackNumber = metadata.trackNumber
        self.totalTracks = metadata.totalTracks
        
        self.discNumber = metadata.discNumber
        self.totalDiscs = metadata.totalDiscs
        
        self.duration = metadata.duration
        self.isProtected = metadata.isProtected
    }
}
