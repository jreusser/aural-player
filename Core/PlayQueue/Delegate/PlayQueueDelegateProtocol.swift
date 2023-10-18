import Foundation

protocol PlayQueueDelegateProtocol: TrackListProtocol, SequencingProtocol {
    
    var currentTrack: Track? {get}
    
    var currentTrackIndex: Int? {get}
    
    // MARK: Mutating functions ---------------------------------------------------------------
    
    func loadTracks(from files: [URL], atPosition position: Int?, clearQueue: Bool, autoplay: Bool)
    
    // Adds tracks to the end of the queue, i.e. "Play Now" or "Play Later"
    func enqueueTracks(_ newTracks: [Track], clearQueue: Bool) -> IndexSet

    // Inserts tracks immediately after the current track, i.e. "Play Next"
    func enqueueTracksToPlayNext(_ newTracks: [Track]) -> IndexSet
    
    // Moves tracks immediately after the current track, i.e. "Play Next"
    func moveTracksToPlayNext(from indices: IndexSet) -> IndexSet
    
    // MARK: Sequencing functions ---------------------------------------------------------------
    
    // Returns the current repeat and shuffle modes
    var repeatAndShuffleModes: (repeatMode: RepeatMode, shuffleMode: ShuffleMode) {get}
    
    // Toggles between repeat modes. See RepeatMode for more details. Returns the new repeat and shuffle mode after performing the toggle operation.
    func toggleRepeatMode() -> (repeatMode: RepeatMode, shuffleMode: ShuffleMode)
    
    // Toggles between shuffle modes. See ShuffleMode for more details. Returns the new repeat and shuffle mode after performing the toggle operation.
    func toggleShuffleMode() -> (repeatMode: RepeatMode, shuffleMode: ShuffleMode)
    
    // Sets the repeat mode to a specific value. Returns the new repeat and shuffle mode after performing the toggle operation.
    func setRepeatMode(_ repeatMode: RepeatMode) -> (repeatMode: RepeatMode, shuffleMode: ShuffleMode)
    
    // Sets the shuffle mode to a specific value. Returns the new repeat and shuffle mode after performing the toggle operation.
    func setShuffleMode(_ shuffleMode: ShuffleMode) -> (repeatMode: RepeatMode, shuffleMode: ShuffleMode)
}

extension PlayQueueDelegateProtocol {
    
    func loadTracks(from files: [URL], autoplay: Bool) {
        loadTracks(from: files, atPosition: nil, clearQueue: false, autoplay: autoplay)
    }
    
    func loadTracks(from files: [URL], clearQueue: Bool, autoplay: Bool) {
        loadTracks(from: files, atPosition: nil, clearQueue: clearQueue, autoplay: autoplay)
    }
}
