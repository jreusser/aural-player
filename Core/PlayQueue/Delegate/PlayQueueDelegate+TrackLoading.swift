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

extension PlayQueueDelegate: TrackLoaderReceiver {
    
    func allFileReadsCompleted(files: [URL]) {
        // TODO: Send out notif to UI (done adding)
    }
    
    func addTracks(from files: [URL], atPosition position: Int?) {
        trackLoader.loadMetadata(ofType: .primary, from: files, into: self, at: position)
    }

    func computeDuration(for files: [URL]) {

    }

    func shouldLoad(file: URL) -> Bool {
        
        // TODO: Should check if we already have a track for this file,
        // then simply duplicate it instead of re-reading the file.

//        if let trackInLibrary = self.library.findTrackByFile(file) {
//
//            _ = playQueue.enqueue([trackInLibrary])
//            return false
//        }

        return true
    }

    func acceptBatch(_ batch: FileMetadataBatch) {

        let tracks = batch.orderedMetadata.map {(file, metadata) -> Track in
            
            let track = Track(file, fileMetadata: metadata)

            do {
                try self.trackReader.computePlaybackContext(for: track)
            } catch {}

            return track
        }
        
        let indices: ClosedRange<Int>
        
        if let insertionIndex = batch.insertionIndex {
            indices = playQueue.insertTracks(tracks, at: insertionIndex)
            
        } else {
            indices = playQueue.enqueueTracks(tracks)
        }
        
        messenger.publish(PlayQueueTracksAddedNotification(trackIndices: indices))
    }
}
