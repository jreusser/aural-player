import Foundation

class PlayQueue: PlayQueueProtocol, PersistentModelObject {
    
    var trackList: TrackList = TrackList()
    
    var tracks: [Track] {
        trackList.tracks
    }
    
    // MARK: Accessor functions

    var size: Int {trackList.size}

    var duration: Double {
        trackList.reduce(0.0, {(totalSoFar: Double, track: Track) -> Double in totalSoFar + track.duration})
    }

    // Stores the currently playing track, if there is one
    var currentTrack: Track? {
        
        guard let index = curTrackIndex else {return nil}
        return trackList[index]
    }
    
    var curTrackIndex: Int? = nil

    subscript(_ index: Int) -> Track? {
        trackList[index]
    }

    func indexOfTrack(_ track: Track) -> Int?  {
        trackList.indexOfTrack(track)
    }

    var summary: (size: Int, totalDuration: Double) {(size, duration)}
    
    var repeatMode: RepeatMode = .defaultMode
    var shuffleMode: ShuffleMode = .defaultMode
    
    // Contains a pre-computed shuffle sequence, when shuffleMode is .on
    lazy var shuffleSequence: ShuffleSequence = ShuffleSequence()

    // MARK: Mutator functions ------------------------------------------------------------------------

    func enqueueTracks(_ newTracks: [Track]) -> ClosedRange<Int> {
        trackList.addTracks(newTracks)
    }

    func enqueueTracksAtHead(_ newTracks: [Track], clearQueue: Bool) -> ClosedRange<Int> {
        
        if clearQueue {
            
            trackList.removeAllTracks()
            return enqueueTracks(newTracks)
            
        } else {
            
            if let playingTrackIndex = curTrackIndex {
                curTrackIndex = playingTrackIndex + newTracks.count
            }

            return trackList.insertTracks(newTracks, at: 0)
        }
    }

    func enqueueTracksAfterCurrentTrack(_ newTracks: [Track]) -> ClosedRange<Int> {

        let insertionPoint = (curTrackIndex ?? -1) + 1
        return trackList.insertTracks(newTracks, at: insertionPoint)
    }
    
    func insertTracks(_ newTracks: [Track], at insertionIndex: Int) -> ClosedRange<Int> {
        
        trackList.insertTracks(newTracks, at: insertionIndex)
        return insertionIndex...(insertionIndex + newTracks.lastIndex)
    }

    func removeTracks(at indexes: IndexSet) -> [Track] {

        let removedTracks = trackList.removeTracks(at: indexes)

        if let playingTrackIndex = curTrackIndex {

            // Playing track removed
            if indexes.contains(playingTrackIndex) {
                stop()

            } else {

                // Compute how many tracks above (i.e. <) playingTrackIndex were removed ... this will determine the adjustment to the playing track index.
                curTrackIndex = playingTrackIndex - (indexes.filter {$0 < playingTrackIndex}.count)
            }
        }

        return removedTracks
    }

    func removeAllTracks() {
        
        trackList.removeAllTracks()
        stop()
    }

    func moveTracksUp(from indices: IndexSet) -> [TrackMoveResult] {
        doMoveTracks {trackList.moveTracksUp(from: indices)}
    }

    func moveTracksDown(from indices: IndexSet) -> [TrackMoveResult] {
        doMoveTracks {trackList.moveTracksDown(from: indices)}
    }

    func moveTracksToTop(from indices: IndexSet) -> [TrackMoveResult] {
        doMoveTracks {trackList.moveTracksToTop(from: indices)}
    }

    func moveTracksToBottom(from indices: IndexSet) -> [TrackMoveResult] {
        doMoveTracks {trackList.moveTracksToBottom(from: indices)}
    }

    func moveTracks(from sourceIndexes: IndexSet, to dropIndex: Int) -> [TrackMoveResult] {
        doMoveTracks {trackList.moveTracks(from: sourceIndexes, to: dropIndex)}
    }

    private func doMoveTracks(_ moveOperation: () -> [TrackMoveResult]) -> [TrackMoveResult] {

        let moveResults = moveOperation()

        // If the playing track was moved, update the index of the playing track within the sequence
        
        if let playingTrackIndex = curTrackIndex,
           let newPlayingTrackIndex = moveResults.first(where: {$0.sourceIndex == playingTrackIndex})?.destinationIndex {
            
            curTrackIndex = newPlayingTrackIndex
        }

        return moveResults
    }
    
    var persistentState: PlayQueuePersistentState {
        .init(playQueue: self)
    }
}
