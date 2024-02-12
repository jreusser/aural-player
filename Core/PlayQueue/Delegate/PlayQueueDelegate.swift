import Foundation

struct PlayQueueTrackAddResult {
    
    let track: Track
    
    // Index of the added track, within the play queue
    let index: Int
}

class PlayQueueDelegate: PlayQueueDelegateProtocol {
    
    var displayName: String {playQueue.displayName}
    
    let playQueue: PlayQueueProtocol

    var tracks: [Track] {playQueue.tracks}

    var size: Int {playQueue.size}

    var duration: Double {playQueue.duration}

    var summary: (size: Int, totalDuration: Double) {playQueue.summary}
    
    private let trackAddQueue: OperationQueue = OperationQueue()
    private let trackUpdateQueue: OperationQueue = OperationQueue()

    private var addSession: TrackAddSession<PlayQueueTrackAddResult>!

    private let concurrentAddOpCount = (Double(SystemUtils.numberOfActiveCores) * 1.5).roundedInt

    var isBeingModified: Bool {addSession != nil}
    
    var currentTrack: Track? {playQueue.currentTrack}
    
    var currentTrackIndex: Int? {playQueue.currentTrackIndex}
    
    lazy var messenger: Messenger = .init(for: self)
    
    init(playQueue: PlayQueueProtocol, persistentState: PlayQueuePersistentState?) {

        self.playQueue = playQueue
        
        _ = setRepeatMode(persistentState?.repeatMode ?? .defaultMode)
        _ = setShuffleMode(persistentState?.shuffleMode ?? .defaultMode)
        
        // Subscribe to notifications
        messenger.subscribe(to: .application_reopened, handler: appReopened(_:))
    }
    
    func hasTrack(_ track: Track) -> Bool {
        playQueue.hasTrack(track)
    }
    
    func hasTrack(forFile file: URL) -> Bool {
        playQueue.hasTrack(forFile: file)
    }
    
    func findTrack(forFile file: URL) -> Track? {
        playQueue.findTrack(forFile: file)
    }

    func indexOfTrack(_ track: Track) -> Int? {
        playQueue.indexOfTrack(track)
    }

    subscript(_ index: Int) -> Track? {
        playQueue[index]
    }
    
    subscript(indices: IndexSet) -> [Track] {
        playQueue[indices]
    }

    func search(_ searchQuery: SearchQuery) -> SearchResults {
        playQueue.search(searchQuery)
    }
    
    func loadTracks(from files: [URL], atPosition position: Int? = nil) {
        playQueue.loadTracks(from: files, atPosition: position)
    }
    
    func loadTracks(from files: [URL], atPosition position: Int? = nil, clearQueue: Bool = false, autoplay: Bool = false) {
        playQueue.loadTracks(from: files, atPosition: position, clearQueue: clearQueue, autoplay: autoplay)
    }
    
    func addTracks(_ newTracks: [Track]) -> IndexSet {
        
        let indices = playQueue.addTracks(newTracks)
        messenger.publish(PlayQueueTracksAddedNotification(trackIndices: indices))
        return indices
    }

    func enqueueTracks(_ newTracks: [Track], clearQueue: Bool) -> IndexSet {

        let indices = playQueue.enqueueTracks(newTracks, clearQueue: clearQueue)
        messenger.publish(PlayQueueTracksAddedNotification(trackIndices: indices))
        return indices
    }

    func enqueueTracksToPlayNext(_ newTracks: [Track]) -> IndexSet {

        let indices = playQueue.enqueueTracksAfterCurrentTrack(newTracks)
        messenger.publish(PlayQueueTracksAddedNotification(trackIndices: indices))
        return indices
    }
    
    func insertTracks(_ newTracks: [Track], at insertionIndex: Int) -> IndexSet {
        
        let indices = playQueue.insertTracks(newTracks, at: insertionIndex)
        messenger.publish(PlayQueueTracksAddedNotification(trackIndices: indices))
        return indices
    }

    func removeTracks(at indices: IndexSet) -> [Track] {
        
        if let playingTrackIndex = playQueue.currentTrackIndex, indices.contains(playingTrackIndex) {
            messenger.publish(.Player.stop)
        }
        
        return playQueue.removeTracks(at: indices)
    }
    
    func cropTracks(at indices: IndexSet) {
        playQueue.cropTracks(at: indices)
    }
    
    func cropTracks(_ tracks: [Track]) {
        playQueue.cropTracks(tracks)
    }

    func moveTracksUp(from indices: IndexSet) -> [TrackMoveResult] {
        playQueue.moveTracksUp(from: indices)
    }

    func moveTracksToTop(from indices: IndexSet) -> [TrackMoveResult] {
        playQueue.moveTracksToTop(from: indices)
    }

    func moveTracksDown(from indices: IndexSet) -> [TrackMoveResult] {
        playQueue.moveTracksDown(from: indices)
    }

    func moveTracksToBottom(from indices: IndexSet) -> [TrackMoveResult] {
        playQueue.moveTracksToBottom(from: indices)
    }

    func moveTracks(from sourceIndices: IndexSet, to dropIndex: Int) -> [TrackMoveResult] {
        playQueue.moveTracks(from: sourceIndices, to: dropIndex)
    }
    
    func moveTracksToPlayNext(from indices: IndexSet) -> IndexSet {
        playQueue.moveTracksAfterCurrentTrack(from: indices)
    }

    func removeAllTracks() {
        
        let playingTrack: Track? = playQueue.currentTrack
        playQueue.removeAllTracks()
        
        if let thePlayingTrack = playingTrack {
            messenger.publish(.playQueue_playingTrackRemoved, payload: thePlayingTrack)
        }
    }

    func sort(_ sort: TrackListSort) {
        playQueue.sort(sort)
    }

    func sort(by comparator: (Track, Track) -> Bool) {
        playQueue.sort(by: comparator)
    }
    
    func exportToFile(_ file: URL) {
        playQueue.exportToFile(file)
    }
    
    // MARK: Sequencing functions ---------------------------------------------------------------
    
    var repeatAndShuffleModes: (repeatMode: RepeatMode, shuffleMode: ShuffleMode) {
        playQueue.repeatAndShuffleModes
    }
    
    func toggleRepeatMode() -> (repeatMode: RepeatMode, shuffleMode: ShuffleMode) {
        playQueue.toggleRepeatMode()
    }
    
    func toggleShuffleMode() -> (repeatMode: RepeatMode, shuffleMode: ShuffleMode) {
        playQueue.toggleShuffleMode()
    }
    
    func setRepeatMode(_ repeatMode: RepeatMode) -> (repeatMode: RepeatMode, shuffleMode: ShuffleMode) {
        playQueue.setRepeatMode(repeatMode)
    }
    
    func setShuffleMode(_ shuffleMode: ShuffleMode) -> (repeatMode: RepeatMode, shuffleMode: ShuffleMode) {
        playQueue.setShuffleMode(shuffleMode)
    }
    
    func start() -> Track? {
        playQueue.start()
    }
    
    func stop() {
        playQueue.stop()
    }
    
    func subsequent() -> Track? {
        playQueue.subsequent()
    }
    
    func previous() -> Track? {
        playQueue.previous()
    }
    
    func next() -> Track? {
        playQueue.next()
    }
    
    func peekSubsequent() -> Track? {
        playQueue.peekSubsequent()
    }
    
    func peekPrevious() -> Track? {
        playQueue.peekPrevious()
    }
    
    func peekNext() -> Track? {
        playQueue.peekNext()
    }
    
    func select(trackAt index: Int) -> Track? {
        playQueue.select(trackAt: index)
    }
    
    func selectTrack(_ track: Track) -> Track? {
        playQueue.selectTrack(track)
    }
    
    // MARK: Notification handling ---------------------------------------------------------------
    
    func appReopened(_ notification: AppReopenedNotification) {
        
        // When a duplicate notification is sent, don't autoplay ! Otherwise, always autoplay.
//        addTracks(from: notification.filesToOpen, AutoplayOptions(!notification.isDuplicateNotification))
        loadTracks(from: notification.filesToOpen)
    }
}
