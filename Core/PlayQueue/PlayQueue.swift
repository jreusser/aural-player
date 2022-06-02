import Foundation

class PlayQueue: TrackList, PlayQueueProtocol, PersistentModelObject {
    
    override var displayName: String {"The Play Queue"}
    
    // MARK: Accessor functions

    // Stores the currently playing track, if there is one
    var currentTrack: Track? {
        
        guard let index = currentTrackIndex else {return nil}
        return self[index]
    }
    
    var currentTrackIndex: Int? = nil

    var repeatMode: RepeatMode = .defaultMode
    var shuffleMode: ShuffleMode = .defaultMode
    
    // Contains a pre-computed shuffle sequence, when shuffleMode is .on
    lazy var shuffleSequence: ShuffleSequence = ShuffleSequence()
    
    private lazy var loader: TrackLoader = TrackLoader(priority: .highest)
    
    private lazy var messenger = Messenger(for: self)

    // MARK: Mutator functions ------------------------------------------------------------------------
    
    private var autoplay: AtomicBool = AtomicBool(value: false)
    
    func loadTracks(from files: [URL], atPosition position: Int?) {
        loadTracks(from: files, atPosition: position, usingLoader: loader, observer: self)
    }
    
    func loadTracks(from files: [URL], atPosition position: Int?, autoplay: Bool = false) {
        
        if autoplay {
            self.autoplay.setValue(true)
        }
        
        loadTracks(from: files, atPosition: position, usingLoader: loader, observer: self)
    }
    
    override func acceptBatch(_ batch: FileMetadataBatch) -> IndexSet {
        
        let indices = super.acceptBatch(batch)
        
        if autoplay.value, let indexOfTrackToPlay = indices.min() {
            
            autoplay.setValue(false)
            messenger.publish(TrackPlaybackCommandNotification(index: indexOfTrackToPlay))
        }
        
        return indices
    }
    
    func enqueueTracks(_ newTracks: [Track]) -> IndexSet {
        addTracks(newTracks)
    }
    
    func enqueueTracks(_ newTracks: [Track], clearQueue: Bool) -> IndexSet {
        
        if clearQueue {
            removeAllTracks()
        }
        
        return enqueueTracks(newTracks)
    }

    func enqueueTracksAfterCurrentTrack(_ newTracks: [Track]) -> IndexSet {
        
        guard let curTrackIndex = self.currentTrackIndex else {
            return enqueueTracks(newTracks)
        }
        
        var insertionIndex = curTrackIndex + 1

        for track in newTracks {
            
            if let sourceIndex = indexOfTrack(track) {
                _tracks.removeAndInsertItem(sourceIndex, insertionIndex.getAndIncrement())
            } else {
                insertTracks([track], at: insertionIndex.getAndIncrement())
            }
        }
        
        return IndexSet(curTrackIndex...(insertionIndex - 1))
    }
    
    override func insertTracks(_ newTracks: [Track], at insertionIndex: Int) -> IndexSet {
        
        let indices = super.insertTracks(newTracks, at: insertionIndex)
        
        // Check if the new tracks were inserted above (<) or below (>) the playing track index.
        if let playingTrackIndex = currentTrackIndex, insertionIndex <= playingTrackIndex {
            currentTrackIndex = playingTrackIndex + newTracks.count
        }
        
        return indices
    }
    
    override func removeTracks(at indexes: IndexSet) -> [Track] {

        let removedTracks = super.removeTracks(at: indexes)

        if let playingTrackIndex = currentTrackIndex {

            // Playing track removed
            if indexes.contains(playingTrackIndex) {
                stop()

            } else {

                // Compute how many tracks above (i.e. <) playingTrackIndex were removed ... this will determine the adjustment to the playing track index.
                currentTrackIndex = playingTrackIndex - (indexes.filter {$0 < playingTrackIndex}.count)
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

        let playingTrack = currentTrack
        let moveResults = moveOperation()

        // If the playing track was moved, update the index of the playing track within the sequence
        
        // TODO: Looking up index of the playing track is not very efficient ... this should be calculated
        // from the move results ... and move results need to be improved to include the rows which were
        // indirectly affected by the move (cascaded up / down).
        
        if let playingTrack = playingTrack,
           let newPlayingTrackIndex = indexOfTrack(playingTrack) {
            
            currentTrackIndex = newPlayingTrackIndex
        }

        return moveResults
    }
    
    override func sort(_ sort: TrackListSort) {
        
        let playingTrack = currentTrack
        super.sort(sort)
        
        if let playingTrack = playingTrack,
           let newPlayingTrackIndex = indexOfTrack(playingTrack) {
            
            currentTrackIndex = newPlayingTrackIndex
        }
    }
    
    var persistentState: PlayQueuePersistentState {
        .init(playQueue: self)
    }
}

extension PlayQueue: TrackLoaderObserver {
    
    func preTrackLoad() {
        messenger.publish(.playQueue_startedAddingTracks)
    }
    
    func postTrackLoad() {
        
        messenger.publish(.playQueue_doneAddingTracks)
        
        // Make sure this is reset after track load.
        autoplay.setValue(false)
    }
    
    func postBatchLoad(indices: IndexSet) {
        messenger.publish(PlayQueueTracksAddedNotification(trackIndices: indices))
    }
}
