import Foundation

class PlayQueue: TrackListWrapper, PlayQueueProtocol, PersistentModelObject {
    
    // MARK: Accessor functions

    // Stores the currently playing track, if there is one
    var currentTrack: Track? {
        
        guard let index = curTrackIndex else {return nil}
        return trackList[index]
    }
    
    var curTrackIndex: Int? = nil

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
    
    override func insertTracks(_ newTracks: [Track], at insertionIndex: Int) -> ClosedRange<Int> {
        
        let indices = super.insertTracks(newTracks, at: insertionIndex)
        
        // Check if the new tracks were inserted above (<) or below (>) the playing track index.
        if let playingTrackIndex = curTrackIndex, insertionIndex <= playingTrackIndex {
            curTrackIndex = playingTrackIndex + newTracks.count
        }
        
        return indices
    }
    
    override func removeTracks(at indexes: IndexSet) -> [Track] {

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

    override func removeAllTracks() {
        
        super.removeAllTracks()
        stop()
    }

    override func moveTracksUp(from indices: IndexSet) -> [TrackMoveResult] {
        doMoveTracks {super.moveTracksUp(from: indices)}
    }

    override func moveTracksDown(from indices: IndexSet) -> [TrackMoveResult] {
        doMoveTracks {super.moveTracksDown(from: indices)}
    }

    override func moveTracksToTop(from indices: IndexSet) -> [TrackMoveResult] {
        doMoveTracks {super.moveTracksToTop(from: indices)}
    }

    override func moveTracksToBottom(from indices: IndexSet) -> [TrackMoveResult] {
        doMoveTracks {super.moveTracksToBottom(from: indices)}
    }

    override func moveTracks(from sourceIndexes: IndexSet, to dropIndex: Int) -> [TrackMoveResult] {
        doMoveTracks {super.moveTracks(from: sourceIndexes, to: dropIndex)}
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
