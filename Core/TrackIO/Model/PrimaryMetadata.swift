//
//  PrimaryMetadata.swift
//  Aural
//
//  Copyright © 2023 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Foundation

///
/// A container for all metadata required for a track to be displayed within the playlist.
///
/// This is considered the most essential type of metadata and is loaded immediately when a track is added to the playlist.
///
/// The artist / album / genre fields help the playlist categorize tracks into groups also participate in searching and sorting.
///
struct PrimaryMetadata {
    
//    var fileType: String?
//    var audioFormat: String?
    
    var title: String?
    var artist: String?
    var albumArtist: String?
    var album: String?
    var genre: String?
    var year: Int?
    
    var composer: String?
    var conductor: String?
    var performer: String?
    var lyricist: String?
    
    var trackNumber: Int?
    var totalTracks: Int?
    
    var discNumber: Int?
    var totalDiscs: Int?
    
    var duration: Double = 0
    var durationIsAccurate: Bool = false
    
    var isProtected: Bool?
    
    var chapters: [Chapter] = []
    
    var bpm: Int?
    
    var lyrics: String?
    
    var auxiliaryMetadata: [String: MetadataEntry] = [:]
    
    var art: CoverArt?
    
    init() {}
    
    init(persistentState: PrimaryMetadataPersistentState) {
        
        self.title = persistentState.title
        self.artist = persistentState.artist
        self.album = persistentState.album
        self.albumArtist = persistentState.albumArtist
        self.genre = persistentState.genre
        self.year = persistentState.year
        
        self.trackNumber = persistentState.trackNumber
        self.totalTracks = persistentState.totalTracks
        
        self.discNumber = persistentState.discNumber
        self.totalDiscs = persistentState.totalDiscs
        
        self.duration = persistentState.duration ?? 0
        self.isProtected = persistentState.isProtected
        
        self.chapters = (persistentState.chapters ?? []).enumerated().compactMap {Chapter.init(persistentState: $1, index: $0)}
    }
}
