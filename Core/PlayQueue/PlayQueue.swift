import Foundation

class PlayQueue: TrackList, PlayQueueProtocol, TrackLoaderObserver, PersistentModelObject {
    
    // MARK: Accessor functions

    // Stores the currently playing track, if there is one
    var currentTrack: Track? {
        
        guard let index = curTrackIndex else {return nil}
        return self[index]
    }
    
    var curTrackIndex: Int? = nil

    var repeatMode: RepeatMode = .defaultMode
    var shuffleMode: ShuffleMode = .defaultMode
    
    // Contains a pre-computed shuffle sequence, when shuffleMode is .on
    lazy var shuffleSequence: ShuffleSequence = ShuffleSequence()
    
    private lazy var loader: TrackLoader = TrackLoader()
    
    private lazy var messenger = Messenger(for: self)

    // MARK: Mutator functions ------------------------------------------------------------------------
    
    func loadTracks(from files: [URL], atPosition position: Int?) {
        loadTracks(from: files, atPosition: position, usingLoader: loader, observer: self)
    }
    
    func preTrackLoad() {
        messenger.publish(.playQueue_startedAddingTracks)
    }
    
    func postTrackLoad() {
        messenger.publish(.playQueue_doneAddingTracks)
    }
    
    func postBatchLoad(indices: ClosedRange<Int>) {
        messenger.publish(PlayQueueTracksAddedNotification(trackIndices: indices))
    }

    func enqueueTracks(_ newTracks: [Track]) -> ClosedRange<Int> {
        addTracks(newTracks)
    }
    
    func enqueueTracks(_ newTracks: [Track], clearQueue: Bool) -> ClosedRange<Int> {
        
        if clearQueue {
            removeAllTracks()
        }
        
        return enqueueTracks(newTracks)
    }

    func enqueueTracksAfterCurrentTrack(_ newTracks: [Track]) -> ClosedRange<Int> {

        if let curTrackIndex = self.curTrackIndex, curTrackIndex != tracks.lastIndex {
            return insertTracks(newTracks, at: curTrackIndex + 1)
        }
        
        return enqueueTracks(newTracks)
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

        let removedTracks = super.removeTracks(at: indexes)

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
