//
//  TrackList+TrackIO.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import Foundation

// TODO: How to deal with duplicate tracks ? (track is loaded individually and as part of a playlist)

// TODO: *********** How about using an OrderedSet<Track> to collect the tracks ?

// What if a track exists in a different track list ? (Play Queue / Library). Should we have a global track registry ?
// What about notifications / errors ? Return a result ?
// Create a track load session and a batch class
// How to deal with 2 simultaneous sessions on startup ? Play queue / Library / Custom playlists ? Adjust batch size accordingly ?

extension TrackList: TrackListFileSystemLoadingProtocol {
    
    func loadTracksAsync(from files: [URL], atPosition insertionIndex: Int?) {
        
        _isBeingModified.setTrue()
        
        preTrackLoad()
        
        session = FileReadSession(trackList: self, insertionIndex: insertionIndex)
        batch = TrackLoadBatch(ofSize: TrackReader.highPriorityQueue.maxConcurrentOperationCount, insertionIndex: insertionIndex)
        
        // Move to a background thread to unblock the main thread.
        DispatchQueue.global(qos: trackLoadQoS).async {
            
            defer {self._isBeingModified.setFalse()}
            
            self.readFiles(files)
            
            if self.batch.fileCount > 0 {
                self.flushBatch()
            }
            
            // Unblock this thread because the track list may perform a time consuming task in response to this callback.
            self.postTrackLoad()
            
            // Cleanup
            self.session = nil
            self.batch = nil
        }
    }
    
    func readFiles(_ files: [URL], isRecursiveCall: Bool = false) {
        
        for file in files {

            // Always resolve sym links and aliases before reading the file
            let resolvedFile = file.resolvedURL

            // TODO: Check if file exists, pass a parm to determine whether or not to check (check only if coming
            // from Favs, Bookms, or History).
        
            if !isRecursiveCall {session.addHistoryItem(resolvedFile)}

            if resolvedFile.isDirectory {

                // Directory

                // TODO: This is sorting by filename ... do we want this or something else ? User-configurable "add ordering" ?
                if let dirContents = resolvedFile.children {
                    readFiles(dirContents.sorted(by: {$0.lastPathComponent < $1.lastPathComponent}), isRecursiveCall: true)
                }

            } else {
        
                // Track or Playlist
                if resolvedFile.isSupportedAudioFile {
                    readAudioFile(resolvedFile)
                    
                } else if resolvedFile.isSupportedPlaylistFile {
                    readPlaylistFile(resolvedFile)
                }
            }
        }
    }
    
    func readAudioFile(_ resolvedFile: URL) {
        
        let trackInList: Track? = findTrack(forFile: resolvedFile)
        let track = trackInList ?? Track(resolvedFile)
        
        let fileRead: FileRead = FileRead(track: track, 
                                          result: trackInList != nil ? .existsInTrackList : .addedToTrackList)
        
        // True means batch is full and needs to be flushed.
        if batch.append(fileRead: fileRead) {
            flushBatch()
        }
    }
    
    func readPlaylistFile(_ playlistFile: URL) {
        
        if let loadedPlaylist = PlaylistIO.loadPlaylist(fromFile: playlistFile) {
            loadedPlaylist.tracks.filter {$0.isSupportedAudioFile}.forEach(readAudioFile(_:))
        }
        
        // TODO: else mark error in session ??? What to do with playlists with 0 tracks ???
    }
    
    func flushBatch() {
        
        let tracksToRead = batch.tracksToRead
        
        TrackReader.highPriorityQueue.addOperations(tracksToRead.map {track in
            
            BlockOperation {
                trackReader.loadPrimaryMetadata(for: track)
            }
            
        }, waitUntilFinished: true)
        batch.markReadErrors()
        
        let newIndices = acceptBatch(batch)
        postBatchLoad(indices: newIndices)
        
        if batch.counter == 0, let firstRead = batch.firstSuccessfulRead, let indexOfTrack = indexOfTrack(firstRead.track) {
            firstTrackLoaded(atIndex: indexOfTrack)
        }
        
        batch.clear()
    }
}
