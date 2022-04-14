import Foundation

struct PlayQueueTrackAddResult {
    
    let track: Track
    
    // Index of the added track, within the play queue
    let index: Int
}

class PlayQueueDelegate: PlayQueueDelegateProtocol {

    let playQueue: PlayQueueProtocol

    var tracks: [Track] {playQueue.tracks}

    var size: Int {playQueue.size}

    var duration: Double {playQueue.duration}

    var summary: (size: Int, totalDuration: Double) {playQueue.summary}
    
    private let trackAddQueue: OperationQueue = OperationQueue()
    private let trackUpdateQueue: OperationQueue = OperationQueue()

    let trackReader: TrackReader

    private var addSession: TrackAddSession<PlayQueueTrackAddResult>!

    private let concurrentAddOpCount = (Double(SystemUtils.numberOfActiveCores) * 1.5).roundedInt

    let trackLoader: TrackLoader = TrackLoader()

    var isBeingModified: Bool {addSession != nil}
    
    lazy var messenger: Messenger = .init(for: self)
    
    private let persistentTracks: [URL]?

    init(playQueue: PlayQueueProtocol, trackReader: TrackReader, persistentState: PlayQueuePersistentState?) {

        self.playQueue = playQueue
        self.trackReader = trackReader
        
        self.persistentTracks = persistentState?.tracks?.map {URL(fileURLWithPath: $0)}
     
        _ = setRepeatMode(persistentState?.repeatMode ?? .defaultMode)
        _ = setShuffleMode(persistentState?.shuffleMode ?? .defaultMode)
        
        // Subscribe to notifications
        messenger.subscribe(to: .application_launched, handler: appLaunched(_:))
        messenger.subscribe(to: .application_reopened, handler: appReopened(_:))
    }
    
    func hasTrack(_ track: Track) -> Bool {
        playQueue.hasTrack(track)
    }
    
    func hasTrackForFile(_ file: URL) -> Bool {
        playQueue.hasTrackForFile(file)
    }
    
    func findTrackByFile(_ file: URL) -> Track? {
        playQueue.findTrackByFile(file)
    }

    func indexOfTrack(_ track: Track) -> Int? {
        return playQueue.indexOfTrack(track)
    }

    subscript(_ index: Int) -> Track? {
        playQueue[index]
    }

//    func search(_ searchQuery: SearchQuery) -> SearchResults {
//        return playQueue.search(searchQuery)
//    }

    func enqueueToPlayLater(_ newTracks: [Track]) -> ClosedRange<Int> {

        let indices = playQueue.enqueueTracks(newTracks)
        messenger.publish(PlayQueueTracksAddedNotification(trackIndices: indices))
        return indices
    }

    func enqueueToPlayNow(_ newTracks: [Track], clearQueue: Bool) -> ClosedRange<Int> {

        let indices = playQueue.enqueueTracksAtHead(newTracks, clearQueue: clearQueue)
        messenger.publish(PlayQueueTracksAddedNotification(trackIndices: indices))
        return indices
    }

    func enqueueToPlayNext(_ newTracks: [Track]) -> ClosedRange<Int> {

        let indices = playQueue.enqueueTracksAfterCurrentTrack(newTracks)
        messenger.publish(PlayQueueTracksAddedNotification(trackIndices: indices))
        return indices
    }
    
    func insertTracks(_ newTracks: [Track], at insertionIndex: Int) -> ClosedRange<Int> {
        playQueue.insertTracks(newTracks, at: insertionIndex)
    }

    func removeTracks(at indices: IndexSet) -> [Track] {

        let removedTracks = playQueue.removeTracks(at: indices)

        messenger.publish(.playQueue_tracksRemoved,
                          payload: TrackRemovalResults(tracks: removedTracks, indices: indices))

        return removedTracks
    }

    func moveTracksUp(from indices: IndexSet) -> [TrackMoveResult] {
        return playQueue.moveTracksUp(from: indices)
    }

    func moveTracksToTop(from indices: IndexSet) -> [TrackMoveResult] {
        return playQueue.moveTracksToTop(from: indices)
    }

    func moveTracksDown(from indices: IndexSet) -> [TrackMoveResult] {
        return playQueue.moveTracksDown(from: indices)
    }

    func moveTracksToBottom(from indices: IndexSet) -> [TrackMoveResult] {
        return playQueue.moveTracksToBottom(from: indices)
    }

    func moveTracks(from sourceIndices: IndexSet, to dropIndex: Int) -> [TrackMoveResult] {
        return playQueue.moveTracks(from: sourceIndices, to: dropIndex)
    }

    func export(to file: URL) {

        // Perform asynchronously, to unblock the main thread
        DispatchQueue.global(qos: .userInitiated).async {
            PlaylistIO.savePlaylist(tracks: self.tracks, toFile: file)
        }
    }

    func removeAllTracks() {
        playQueue.removeAllTracks()
    }

//    func sort(_ sort: Sort) -> SortResults {
//        playQueue.sort(sort)
//    }
//
//    func sort(by comparator: (Track, Track) -> Bool) {
//        playQueue.sort(by: comparator)
//    }
    
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
    
    // MARK: Notification handling ---------------------------------------------------------------
    
    func appLaunched(_ filesToOpen: [URL]) {
        
        // Check if any launch parameters were specified
        if filesToOpen.isNonEmpty {
            
            // Launch parameters  specified, override playlist saved state and add file paths in params to playlist
//            addTracks(from: filesToOpen, AutoplayOptions(true), userAction: false)
            addTracks(from: filesToOpen)

        } else if let files = self.persistentTracks {

            // No launch parameters specified, load playlist saved state if "Remember state from last launch" preference is selected
//            addFiles_async(tracks, AutoplayOptions(playbackPreferences.autoplayOnStartup), userAction: false, reorderGroupingPlaylists: true)
            addTracks(from: files)
        }
            
//        } else if playlistPreferences.playlistOnStartup == .loadFile,
//                  let playlistFile: URL = playlistPreferences.playlistFile {
//
//            addFiles_async([playlistFile], AutoplayOptions(playbackPreferences.autoplayOnStartup), userAction: false)
//
//        } else if playlistPreferences.playlistOnStartup == .loadFolder,
//                  let folder: URL = playlistPreferences.tracksFolder {
//
//            addFiles_async([folder], AutoplayOptions(playbackPreferences.autoplayOnStartup), userAction: false)
//        }
    }
    
    func appReopened(_ notification: AppReopenedNotification) {
        
        // When a duplicate notification is sent, don't autoplay ! Otherwise, always autoplay.
//        addTracks(from: notification.filesToOpen, AutoplayOptions(!notification.isDuplicateNotification))
        addTracks(from: notification.filesToOpen)
    }
}
