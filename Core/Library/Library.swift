//
//  Library.swift
//  Aural
//
//  Copyright © 2023 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import Foundation
import OrderedCollections

protocol LibraryProtocol: TrackListProtocol {
    
    var homeFolder: URL {get set}
    
    func buildLibrary()
    
    var buildProgress: LibraryBuildProgress {get}
    
    // TODO:
    var playlists: [ImportedPlaylist] {get}
    
    var numberOfPlaylists: Int {get}
    
    var numberOfTracksInPlaylists: Int {get}
    
    var durationOfTracksInPlaylists: Double {get}
    
    func addPlaylists(_ playlists: [ImportedPlaylist])
    
    func playlist(atIndex index: Int) -> ImportedPlaylist?
}

struct LibraryBuildProgress {
    
    let isBeingModified: Bool
    let startedReadingFiles: Bool
    let buildStats: LibraryBuildStats?
}

class Library: GroupedSortedTrackList, LibraryProtocol {
    
    override var displayName: String {"The Library"}
    
    var homeFolder: URL
    
    /// A map to quickly look up playlists by (absolute) file path (used when adding playlists, to prevent duplicates)
    /// // TODO:
    var _playlists: OrderedDictionary<URL, ImportedPlaylist> = OrderedDictionary()
    
    var playlists: [ImportedPlaylist] {
        Array(_playlists.values)
    }
    
    var numberOfPlaylists: Int {
        _playlists.count
    }
    
    var numberOfTracksInPlaylists: Int {
        _playlists.values.reduce(0, {(totalSoFar: Int, playlist: ImportedPlaylist) -> Int in totalSoFar + playlist.size})
    }
    
    var durationOfTracksInPlaylists: Double {
        _playlists.values.reduce(0.0, {(totalSoFar: Double, playlist: ImportedPlaylist) -> Double in totalSoFar + playlist.duration})
    }
    
    func addPlaylists(_ playlists: [ImportedPlaylist]) {
        
        for playlist in playlists {
            _playlists[playlist.file] = playlist
        }
    }
    
    func playlist(atIndex index: Int) -> ImportedPlaylist? {
        
        guard (0..._playlists.lastIndex).contains(index) else {return nil}
        return _playlists.elements.values[index]
    }
    
    init(persistentState: LibraryPersistentState?) {
        
//        self.homeFolder = FilesAndPaths.musicDir.appendingPathComponent("Timo", isDirectory: true).appendingPathComponent("Fury In The Slaughterhouse", isDirectory: true)
//        self.homeFolder = persistentState?.homeFolder ?? FilesAndPaths.musicDir
        self.homeFolder = FilesAndPaths.musicDir.appendingPathComponent("Timo", isDirectory: true)
        
        super.init(sortOrder: TrackListSort(fields: [.artist, .album, .discNumberAndTrackNumber], order: .ascending),
                   withGroupings: [ArtistsGrouping(), AlbumsGrouping(), GenresGrouping(), DecadesGrouping()])
    }
    
//    private lazy var loader: TrackLoader = TrackLoader(priority: .high, qOS: .utility)
    private lazy var loader: LibraryLoader = LibraryLoader()
    private lazy var messenger = Messenger(for: self)
    
    var buildProgress: LibraryBuildProgress {
        
        if !_isBeingModified.value {
            return .init(isBeingModified: false, startedReadingFiles: false, buildStats: nil)
        }
        
        return .init(isBeingModified: true, startedReadingFiles: loader.startedReadingFiles, buildStats: loader.progress)
    }
    
    var artistsGrouping: ArtistsGrouping {
        groupings[0] as! ArtistsGrouping
    }
    
    var albumsGrouping: AlbumsGrouping {
        groupings[1] as! AlbumsGrouping
    }
    
    var genresGrouping: GenresGrouping {
        groupings[2] as! GenresGrouping
    }
    
    var decadesGrouping: DecadesGrouping {
        groupings[3] as! DecadesGrouping
    }
    
    func loadTracks(from files: [URL], atPosition position: Int?) {
        
        _isBeingModified.setValue(true)
        
        loader.loadMetadata(ofType: .primary, from: files) {[weak self] in
            self?._isBeingModified.setValue(false)
        }
    }
    
    func buildLibrary() {
        
        removeAllTracks()
        loadTracks(from: [homeFolder], atPosition: nil)
    }
    
    override func acceptBatch(_ batch: FileMetadataBatch) -> IndexSet {
        
        let tracks = batch.orderedMetadata.map {(file, metadata) -> Track in
            Track(file, fileMetadata: metadata)
        }
        
        return addTracks(tracks)
    }
}

extension Library: TrackLoaderObserver {
    
    func preTrackLoad() {
        messenger.publish(.library_startedAddingTracks)
    }
    
    func postTrackLoad() {
        messenger.publish(.library_doneAddingTracks)
    }
    
    func postBatchLoad(indices: IndexSet) {
        messenger.publish(LibraryTracksAddedNotification(trackIndices: indices))
    }
}

extension Library: PersistentModelObject {
    
    var persistentState: LibraryPersistentState {
        .init(homeFolder: self.homeFolder)
    }
}
