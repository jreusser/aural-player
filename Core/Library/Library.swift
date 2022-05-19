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

protocol LibraryProtocol: TrackListProtocol {
    
}

class Library: GroupedTrackList, LibraryProtocol {
    
    init() {
        super.init(withGroupings: [ArtistsGrouping(), AlbumsGrouping(), GenresGrouping(), DecadesGrouping()])
    }
    
    private lazy var loader: TrackLoader = TrackLoader()
    private lazy var messenger = Messenger(for: self)
    
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
