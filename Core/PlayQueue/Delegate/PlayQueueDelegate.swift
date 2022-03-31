import Foundation

class PlayQueueDelegate: PlayQueueDelegateProtocol {

    private let playQueue: PlayQueueProtocol

    var tracks: [Track] {playQueue.tracks}

    var size: Int {playQueue.size}

    var duration: Double {playQueue.duration}

    var summary: (size: Int, totalDuration: Double) {playQueue.summary}
    
    private let trackAddQueue: OperationQueue = OperationQueue()
    private let trackUpdateQueue: OperationQueue = OperationQueue()

    private let trackReader: TrackReader

//    private var addSession: TrackAddSession<PlayQueueTrackAddResult>!
//
//    private let concurrentAddOpCount = roundedInt(Double(SystemUtils.numberOfActiveCores) * 1.5)

//    let trackLoader: TrackLoader = TrackLoader()

//    var isBeingModified: Bool {addSession != nil}
    var isBeingModified: Bool {false}

//    init(playQueue: PlayQueueProtocol, trackReader: TrackReader, persistentStateOnStartup: PlayQueueState) {
    init(playQueue: PlayQueueProtocol, trackReader: TrackReader) {

        self.playQueue = playQueue
        self.trackReader = trackReader
    }

    func indexOfTrack(_ track: Track) -> Int? {
        return playQueue.indexOfTrack(track)
    }

    subscript(_ index: Int) -> Track? {
        playQueue[index]
    }

    func search(_ searchQuery: SearchQuery) -> SearchResults {
        return playQueue.search(searchQuery)
    }

    func enqueueToPlayLater(_ tracks: [Track]) -> ClosedRange<Int> {

        let indices = playQueue.enqueueTracks(tracks)
//        Messenger.publish(PlayQueueTracksAddedNotification(trackIndices: indices))
        return indices
    }

    func enqueueToPlayNow(_ tracks: [Track]) -> ClosedRange<Int> {

        let indices = playQueue.enqueueTracksAtHead(tracks)
//        Messenger.publish(PlayQueueTracksAddedNotification(trackIndices: indices))
        return indices
    }

    func enqueueToPlayNext(_ tracks: [Track]) -> ClosedRange<Int> {

        let indices = playQueue.enqueueTracksAfterCurrentTrack(tracks)
//        Messenger.publish(PlayQueueTracksAddedNotification(trackIndices: indices))
        return indices
    }

    func removeTracks(_ indices: IndexSet) -> [Track] {

        let removedTracks = playQueue.removeTracks(at: indices)

//        Messenger.publish(.playQueue_tracksRemoved,
//                          payload: TrackRemovalResults(flatPlaylistResults: indices, tracks: removedTracks))

        return removedTracks
    }

    func moveTracksUp(_ indices: IndexSet) -> [TrackMoveResult] {
        return playQueue.moveTracksUp(from: indices)
    }

    func moveTracksToTop(_ indices: IndexSet) -> [TrackMoveResult] {
        return playQueue.moveTracksToTop(from: indices)
    }

    func moveTracksDown(_ indices: IndexSet) -> [TrackMoveResult] {
        return playQueue.moveTracksDown(from: indices)
    }

    func moveTracksToBottom(_ indices: IndexSet) -> [TrackMoveResult] {
        return playQueue.moveTracksToBottom(from: indices)
    }

    func dropTracks(_ sourceIndices: IndexSet, _ dropIndex: Int) -> [TrackMoveResult] {
        return playQueue.dropTracks(at: sourceIndices, to: dropIndex)
    }

    func export(to file: URL) {

        // Perform asynchronously, to unblock the main thread
        DispatchQueue.global(qos: .userInitiated).async {
            PlaylistIO.savePlaylist(tracks: self.tracks, toFile: file)
        }
    }

    func clear() {
        playQueue.removeAllTracks()
    }

    func sort(_ sort: Sort) {
        _ = playQueue.sort(sort)
    }

    func sort(by comparator: (Track, Track) -> Bool) {
        playQueue.sort(by: comparator)
    }
}
