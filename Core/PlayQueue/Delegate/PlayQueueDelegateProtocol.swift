import Foundation

protocol PlayQueueDelegateProtocol: TrackListProtocol, SequencingProtocol {
    
    func initialize(fromPersistentState persistentState: PlayQueuePersistentState?, appLaunchFiles: [URL])
    
    var currentTrack: Track? {get}
    
    var currentTrackIndex: Int? {get}
    
    // MARK: Mutating functions ---------------------------------------------------------------
    
    // Tracks loaded directly from the file system (either Finder or on startup)
    func loadTracks(from files: [URL], atPosition position: Int?, clearQueue: Bool, autoplay: Bool)
    
    // Adds tracks to the end of the queue, i.e. "Play Now" or "Play Later"
    func enqueueTracks(_ newTracks: [Track], clearQueue: Bool) -> IndexSet
    
    // Library (Tracks view) / Managed Playlists / Favorites / Bookmarks / History
    func enqueueToPlayNow(tracks: [Track], clearQueue: Bool) -> IndexSet
    
    // Library (grouped views) / Favorites / History
    func enqueueToPlayNow(groups: [Group], tracks: [Track], clearQueue: Bool) -> IndexSet
    
    // Library (playlist files)
    func enqueueToPlayNow(playlistFiles: [ImportedPlaylist], tracks: [Track], clearQueue: Bool) -> IndexSet
    
    // Library (Managed Playlist)
    func enqueueToPlayNow(playlist: Playlist, clearQueue: Bool) -> IndexSet
    
    // Tune Browser
    func enqueueToPlayNow(folders: [FileSystemFolderItem], tracks: [FileSystemTrackItem], playlistFiles: [FileSystemPlaylistItem], clearQueue: Bool) -> IndexSet
    
    // Inserts tracks immediately after the current track, i.e. "Play Next"
    func enqueueTracksToPlayNext(_ newTracks: [Track]) -> IndexSet
    
    // Moves tracks immediately after the current track, i.e. "Play Next"
    func moveTracksToPlayNext(from indices: IndexSet) -> IndexSet
}

extension PlayQueueDelegateProtocol {
    
    func loadTracks(from files: [URL], autoplay: Bool) {
        loadTracks(from: files, atPosition: nil, clearQueue: false, autoplay: autoplay)
    }
    
    func loadTracks(from files: [URL], clearQueue: Bool, autoplay: Bool) {
        loadTracks(from: files, atPosition: nil, clearQueue: clearQueue, autoplay: autoplay)
    }
}
