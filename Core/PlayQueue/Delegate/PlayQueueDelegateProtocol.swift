import Foundation

protocol PlayQueueDelegateProtocol: TrackListProtocol, SequencingProtocol {
    
    func initialize(fromPersistentState persistentState: PlayQueuePersistentState?, appLaunchFiles: [URL])
    
    var currentTrack: Track? {get}
    
    var currentTrackIndex: Int? {get}
    
    // MARK: Mutating functions ---------------------------------------------------------------
    
    // Tracks loaded directly from the file system (either Finder or on startup)
    func loadTracks(from files: [URL], atPosition position: Int?, clearQueue: Bool, autoplay: Bool)
    
    // MARK: Play Now ---------------------------------------------------------------
    
    // Library (Tracks view) / Managed Playlists / Favorites / Bookmarks / History
    func enqueueToPlayNow(tracks: [Track], clearQueue: Bool) -> IndexSet
    
    // Library (grouped views) / Favorites / History
    func enqueueToPlayNow(groups: [Group], tracks: [Track], clearQueue: Bool) -> IndexSet
    
    // Library (playlist files)
    func enqueueToPlayNow(playlistFiles: [ImportedPlaylist], tracks: [Track], clearQueue: Bool) -> IndexSet
    
    // Library (Managed Playlist)
    func enqueueToPlayNow(playlist: Playlist, clearQueue: Bool) -> IndexSet
    
    // Tune Browser
    func enqueueToPlayNow(fileSystemItems: [FileSystemItem], clearQueue: Bool) -> IndexSet
    
    // MARK: Play Next ---------------------------------------------------------------
    
    // Inserts tracks immediately after the current track, i.e. "Play Next"
    
    func enqueueToPlayNext(tracks: [Track]) -> IndexSet
    
    func enqueueToPlayNext(groups: [Group], tracks: [Track]) -> IndexSet
    
    func enqueueToPlayNext(playlistFiles: [ImportedPlaylist], tracks: [Track]) -> IndexSet
    
    func enqueueToPlayNext(playlist: Playlist) -> IndexSet
    
    func enqueueToPlayNext(fileSystemItems: [FileSystemItem]) -> IndexSet
    
    // Moves tracks immediately after the current track, i.e. "Play Next"
    func moveTracksToPlayNext(from indices: IndexSet) -> IndexSet
    
    // MARK: Play Later ---------------------------------------------------------------
    
    func enqueueToPlayLater(tracks: [Track]) -> IndexSet
    
    func enqueueToPlayLater(groups: [Group], tracks: [Track]) -> IndexSet
    
    func enqueueToPlayLater(playlistFiles: [ImportedPlaylist], tracks: [Track]) -> IndexSet
    
    func enqueueToPlayLater(playlist: Playlist) -> IndexSet
    
    func enqueueToPlayLater(fileSystemItems: [FileSystemItem]) -> IndexSet
}

extension PlayQueueDelegateProtocol {
    
    func loadTracks(from files: [URL], autoplay: Bool) {
        loadTracks(from: files, atPosition: nil, clearQueue: false, autoplay: autoplay)
    }
    
    func loadTracks(from files: [URL], clearQueue: Bool, autoplay: Bool) {
        loadTracks(from: files, atPosition: nil, clearQueue: clearQueue, autoplay: autoplay)
    }
}
