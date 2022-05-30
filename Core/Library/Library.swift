//
//  Library.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import Foundation

protocol LibraryProtocol: TrackListProtocol {}

class Library: GroupedSortedTrackList, LibraryProtocol {
    
    override var displayName: String {"The Library"}
    
    init() {
        
//        super.init(sortOrder: TrackListSort(fields: [.artist, .album, .discNumberAndTrackNumber], order: .ascending),
//                   withGroupings: [ArtistsGrouping(), AlbumsGrouping(), GenresGrouping(), DecadesGrouping()])
        
        super.init(sortOrder: TrackListSort(fields: [.artist, .album, .discNumberAndTrackNumber], order: .ascending),
                   withGroupings: [ArtistsGrouping(), AlbumsGrouping(), DecadesGrouping()])
    }
    
    private lazy var loader: TrackLoader = TrackLoader(priority: .highest)
    private lazy var messenger = Messenger(for: self)
    
    var artistsGrouping: ArtistsGrouping {
        groupings[0] as! ArtistsGrouping
    }
    
    var albumsGrouping: AlbumsGrouping {
        groupings[1] as! AlbumsGrouping
    }
    
    var decadesGrouping: DecadesGrouping {
        groupings[2] as! DecadesGrouping
    }
    
    func loadTracks(from files: [URL], atPosition position: Int?) {
        loadTracks(from: files, atPosition: position, usingLoader: loader, observer: self)
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
        .init(library: self)
    }
}
