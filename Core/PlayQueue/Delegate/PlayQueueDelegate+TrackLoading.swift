//
//  PlayQueueDelegate+TrackLoading.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import Foundation

extension PlayQueueDelegate {
    
    func addTracks(from files: [URL], atPosition position: Int?) {
//        trackLoader.loadMetadata(ofType: .primary, from: files, into: self)
    }

    func computeDuration(for files: [URL]) {

    }

    func shouldLoad(file: URL) -> Bool {

//        if let trackInLibrary = self.library.findTrackByFile(file) {
//
//            _ = playQueue.enqueue([trackInLibrary])
//            return false
//        }

        return true
        // TODO: Should check if we already have a track for this file,
        // then simply duplicate it instead of re-reading the file.
    }

//    func acceptBatch(_ batch: FileMetadataBatch) {
//
////        let tracks = batch.orderedMetadata.map {(file, metadata) in Track(file, fileMetadata: metadata)}
//        let tracks = batch.orderedMetadata.map {(file, metadata) -> Track in
//            let track = Track(file, fileMetadata: metadata)
//
//            do {
//                try self.trackReader.computePlaybackContext(for: track)
//            } catch {}
//
//            return track
//        }
//
//
//        let indices = playQueue.enqueue(tracks)
//        Messenger.publish(PlayQueueTracksAddedNotification(trackIndices: indices))
//    }
}
