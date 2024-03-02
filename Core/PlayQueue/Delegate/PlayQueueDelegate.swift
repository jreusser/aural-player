import Foundation
import OrderedCollections

struct PlayQueueTrackAddResult {
    
    let track: Track
    
    // Index of the added track, within the play queue
    let index: Int
}

class PlayQueueDelegate: PlayQueueDelegateProtocol, PersistentModelObject {
    
    // Recently played items
    var recentItems: OrderedDictionary<CompositeKey, HistoryItem> = OrderedDictionary()
    
    var lastPlaybackPosition: Double = 0
    
    var lastPlayedItem: TrackHistoryItem? {
        recentItems.values.reversed().first(where: {$0 is TrackHistoryItem}) as? TrackHistoryItem
    }
    
    var displayName: String {playQueue.displayName}
    
    let playQueue: PlayQueueProtocol

    var tracks: [Track] {playQueue.tracks}

    var size: Int {playQueue.size}

    var duration: Double {playQueue.duration}

    var summary: (size: Int, totalDuration: Double) {playQueue.summary}
    
    var isBeingModified: Bool {playQueue.isBeingModified}
    
    var currentTrack: Track? {playQueue.currentTrack}
    
    var currentTrackIndex: Int? {playQueue.currentTrackIndex}
    
    lazy var messenger: Messenger = .init(for: self)
    
    init(playQueue: PlayQueueProtocol, persistentState: PlayQueuePersistentState?) {

        self.playQueue = playQueue
        
        _ = setRepeatMode(persistentState?.repeatMode ?? .defaultMode)
        _ = setShuffleMode(persistentState?.shuffleMode ?? .defaultMode)
        
        // Subscribe to notifications
        messenger.subscribe(to: .Application.reopened, handler: appReopened(_:))
        messenger.subscribe(to: .Player.trackTransitioned, handler: trackPlayed(_:))
        messenger.subscribe(to: .Application.willExit, handler: appWillExit)
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
    
    // MARK: Play Now ---------------------------------------------------------------

    // Library (Tracks view) / Managed Playlists / Favorites / Bookmarks / History
    @discardableResult func enqueueToPlayNow(tracks: [Track], clearQueue: Bool) -> IndexSet {
        
        tracksEnqueued(tracks)
        return doEnqueueToPlayNow(tracks: tracks, clearQueue: clearQueue)
    }
    
    // Library (grouped views) / Favorites / History
    @discardableResult func enqueueToPlayNow(groups: [Group], tracks: [Track], clearQueue: Bool) -> IndexSet {
        
        groupsAndTracksEnqueued(groups: groups, tracks: tracks)
        return doEnqueueToPlayNow(tracks: groups.flatMap {$0.tracks} + tracks, clearQueue: clearQueue)
    }
    
    // Library (playlist files)
    @discardableResult func enqueueToPlayNow(playlistFiles: [ImportedPlaylist], tracks: [Track], clearQueue: Bool) -> IndexSet {
        
        playlistFilesAndTracksEnqueued(playlistFiles: playlistFiles, tracks: tracks)
        return doEnqueueToPlayNow(tracks: playlistFiles.flatMap {$0.tracks} + tracks, clearQueue: clearQueue)
    }
    
    // Library (Managed Playlist)
    @discardableResult func enqueueToPlayNow(playlist: Playlist, clearQueue: Bool) -> IndexSet {
        
        playlistEnqueued(playlist)
        return doEnqueueToPlayNow(tracks: playlist.tracks, clearQueue: clearQueue)
    }
    
    // Tune Browser
    @discardableResult func enqueueToPlayNow(fileSystemItems: [FileSystemItem], clearQueue: Bool) -> IndexSet {
        
        fileSystemItemsEnqueued(fileSystemItems)
        return doEnqueueToPlayNow(tracks: fileSystemItems.flatMap {$0.tracks}, clearQueue: clearQueue)
    }
    
    @discardableResult func doEnqueueToPlayNow(tracks: [Track], clearQueue: Bool) -> IndexSet {
        
        let indices = playQueue.enqueueTracks(tracks, clearQueue: clearQueue)
        messenger.publish(PlayQueueTracksAddedNotification(trackIndices: indices))
        
        if let trackToPlay = tracks.first {
            playbackDelegate.play(track: trackToPlay, .defaultParams())
        }
            
        return indices
    }
    
    // MARK: Play Next ---------------------------------------------------------------
    
    @discardableResult func enqueueToPlayNext(tracks: [Track]) -> IndexSet {
        
        tracksEnqueued(tracks)
        return doEnqueueToPlayNext(tracks: tracks)
    }
    
    @discardableResult func enqueueToPlayNext(groups: [Group], tracks: [Track]) -> IndexSet {
        
        groupsAndTracksEnqueued(groups: groups, tracks: tracks)
        return doEnqueueToPlayNext(tracks: groups.flatMap {$0.tracks} + tracks)
    }
    
    @discardableResult func enqueueToPlayNext(playlistFiles: [ImportedPlaylist], tracks: [Track]) -> IndexSet {
        
        playlistFilesAndTracksEnqueued(playlistFiles: playlistFiles, tracks: tracks)
        return doEnqueueToPlayNext(tracks: playlistFiles.flatMap {$0.tracks} + tracks)
    }
    
    @discardableResult func enqueueToPlayNext(playlist: Playlist) -> IndexSet {
        
        playlistEnqueued(playlist)
        return doEnqueueToPlayNext(tracks: playlist.tracks)
    }
    
    @discardableResult func enqueueToPlayNext(fileSystemItems: [FileSystemItem]) -> IndexSet {
        
        fileSystemItemsEnqueued(fileSystemItems)
        return doEnqueueToPlayNext(tracks: fileSystemItems.flatMap {$0.tracks})
    }
    
    @discardableResult private func doEnqueueToPlayNext(tracks: [Track]) -> IndexSet {
        
        let indices = playQueue.enqueueTracksAfterCurrentTrack(tracks)
        messenger.publish(PlayQueueTracksAddedNotification(trackIndices: indices))
        return indices
    }
    
    // MARK: Play Later ---------------------------------------------------------------
    
    @discardableResult func enqueueToPlayLater(tracks: [Track]) -> IndexSet {
        
        tracksEnqueued(tracks)
        return doEnqueueToPlayLater(tracks: tracks)
    }
    
    @discardableResult func enqueueToPlayLater(groups: [Group], tracks: [Track]) -> IndexSet {
        
        groupsAndTracksEnqueued(groups: groups, tracks: tracks)
        return doEnqueueToPlayLater(tracks: groups.flatMap {$0.tracks} + tracks)
    }
    
    @discardableResult func enqueueToPlayLater(playlistFiles: [ImportedPlaylist], tracks: [Track]) -> IndexSet {
        
        playlistFilesAndTracksEnqueued(playlistFiles: playlistFiles, tracks: tracks)
        return doEnqueueToPlayLater(tracks: playlistFiles.flatMap {$0.tracks} + tracks)
    }
    
    @discardableResult func enqueueToPlayLater(playlist: Playlist) -> IndexSet {
        
        playlistEnqueued(playlist)
        return doEnqueueToPlayLater(tracks: playlist.tracks)
    }
    
    @discardableResult func enqueueToPlayLater(fileSystemItems: [FileSystemItem]) -> IndexSet {
        
        fileSystemItemsEnqueued(fileSystemItems)
        return doEnqueueToPlayLater(tracks: fileSystemItems.flatMap {$0.tracks})
    }
    
    @discardableResult private func doEnqueueToPlayLater(tracks: [Track]) -> IndexSet {
        
        let indices = playQueue.addTracks(tracks)
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
            messenger.publish(.PlayQueue.playingTrackRemoved, payload: thePlayingTrack)
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
    
    // MARK: Notification handling ---------------------------------------------------------------
    
    func appReopened(_ notification: AppReopenedNotification) {
        
        // When a duplicate notification is sent, don't autoplay ! Otherwise, always autoplay.
//        addTracks(from: notification.filesToOpen, AutoplayOptions(!notification.isDuplicateNotification))
        loadTracks(from: notification.filesToOpen)
    }
    
    var persistentState: PlayQueuePersistentState {
        
        let repeatAndShuffleModes = playQueue.repeatAndShuffleModes
        return .init(tracks: tracks.map {$0.file}, repeatMode: repeatAndShuffleModes.repeatMode, shuffleMode: repeatAndShuffleModes.shuffleMode,
                     history: self.historyPersistentState)
    }
    
    var historyPersistentState: HistoryPersistentState {
        
        let recentItems = recentItems.values.compactMap(HistoryItemPersistentState.init)
        return HistoryPersistentState(recentItems: recentItems, lastPlaybackPosition: lastPlaybackPosition)
    }
}
