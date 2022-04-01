import Foundation

class PlayQueue: PlayQueueProtocol {
    
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
        trackList.indexOf(track)
    }

    var summary: (size: Int, totalDuration: Double) {(size, duration)}
    
    var repeatMode: RepeatMode = .defaultMode
    var shuffleMode: ShuffleMode = .defaultMode
    
    // Contains a pre-computed shuffle sequence, when shuffleMode is .on
    lazy var shuffleSequence: ShuffleSequence = ShuffleSequence()

    // MARK: Mutator functions ------------------------------------------------------------------------

    func enqueueTracks(_ newTracks: [Track]) -> ClosedRange<Int> {
        trackList.add(newTracks)
    }

    func enqueueTracksAtHead(_ newTracks: [Track]) -> ClosedRange<Int> {

        trackList.insert(newTracks, at: 0)

        if let playingTrackIndex = curTrackIndex {
            curTrackIndex = playingTrackIndex + newTracks.count
        }

        return 0...newTracks.lastIndex
    }

    func enqueueTracksAfterCurrentTrack(_ newTracks: [Track]) -> ClosedRange<Int> {

        let insertionPoint = (curTrackIndex ?? -1) + 1
        trackList.insert(newTracks, at: insertionPoint)

        return insertionPoint...(insertionPoint + newTracks.lastIndex)
    }

    func removeTracks(at indexes: IndexSet) -> [Track] {

        let removedTracks = trackList.remove(at: indexes)

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
        
        trackList.removeAll()
        stop()
    }

    func moveTracksUp(from indices: IndexSet) -> [TrackMoveResult] {
        return doMoveTracks {trackList.moveUp(from: indices)}
    }

    func moveTracksDown(from indices: IndexSet) -> [TrackMoveResult] {
        return doMoveTracks {trackList.moveDown(from: indices)}
    }

    func moveTracksToTop(from indices: IndexSet) -> [TrackMoveResult] {
        return doMoveTracks {trackList.moveToTop(from: indices)}
    }

    func moveTracksToBottom(from indices: IndexSet) -> [TrackMoveResult] {
        return doMoveTracks {trackList.moveToBottom(from: indices)}
    }

    func dropTracks(at sourceIndexes: IndexSet, to dropIndex: Int) -> [TrackMoveResult] {
        return doMoveTracks {trackList.dragAndDropItems(sourceIndexes, dropIndex)}
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
}
