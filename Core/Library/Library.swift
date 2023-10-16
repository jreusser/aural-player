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
    
    var buildProgress: Double {get}
    
    // TODO:
    var playlists: [ImportedPlaylist] {get}
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
    
    init(persistentState: LibraryPersistentState?) {
        
        self.homeFolder = persistentState?.homeFolder ?? FilesAndPaths.musicDir
        
        super.init(sortOrder: TrackListSort(fields: [.artist, .album, .discNumberAndTrackNumber], order: .ascending),
                   withGroupings: [ArtistsGrouping(), AlbumsGrouping(), GenresGrouping(), DecadesGrouping()])
    }
    
//    private lazy var loader: TrackLoader = TrackLoader(priority: .high, qOS: .utility)
    private lazy var loader: LibraryLoader = LibraryLoader()
    private lazy var messenger = Messenger(for: self)
    
    var buildProgress: Double {
        loader.progress
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
//        loadTracks(from: files, atPosition: position, usingLoader: loader, observer: self)
        loader.loadMetadata(ofType: .primary, from: files)
    }
    
    func buildLibrary() {
        
        removeAllTracks()
        loadTracks(from: [homeFolder])
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
