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
    @discardableResult func enqueueToPlayNow(tracks: [Track], clearQueue: Bool) -> IndexSet
    
    // Library (grouped views) / Favorites / History
    @discardableResult func enqueueToPlayNow(groups: [Group], tracks: [Track], clearQueue: Bool) -> IndexSet
    
    // Library (playlist files)
    @discardableResult func enqueueToPlayNow(playlistFiles: [ImportedPlaylist], tracks: [Track], clearQueue: Bool) -> IndexSet
    
    // Library (Managed Playlist)
    @discardableResult func enqueueToPlayNow(playlist: Playlist, clearQueue: Bool) -> IndexSet
    
    // Tune Browser
    @discardableResult func enqueueToPlayNow(fileSystemItems: [FileSystemItem], clearQueue: Bool) -> IndexSet
    
    // MARK: Play Next ---------------------------------------------------------------
    
    // Inserts tracks immediately after the current track, i.e. "Play Next"
    
    @discardableResult func enqueueToPlayNext(tracks: [Track]) -> IndexSet
    
    @discardableResult func enqueueToPlayNext(groups: [Group], tracks: [Track]) -> IndexSet
    
    @discardableResult func enqueueToPlayNext(playlistFiles: [ImportedPlaylist], tracks: [Track]) -> IndexSet
    
    @discardableResult func enqueueToPlayNext(playlist: Playlist) -> IndexSet
    
    @discardableResult func enqueueToPlayNext(fileSystemItems: [FileSystemItem]) -> IndexSet
    
    // Moves tracks immediately after the current track, i.e. "Play Next"
    @discardableResult func moveTracksToPlayNext(from indices: IndexSet) -> IndexSet
    
    // MARK: Play Later ---------------------------------------------------------------
    
    @discardableResult func enqueueToPlayLater(tracks: [Track]) -> IndexSet
    
    @discardableResult func enqueueToPlayLater(groups: [Group], tracks: [Track]) -> IndexSet
    
    @discardableResult func enqueueToPlayLater(playlistFiles: [ImportedPlaylist], tracks: [Track]) -> IndexSet
    
    @discardableResult func enqueueToPlayLater(playlist: Playlist) -> IndexSet
    
    @discardableResult func enqueueToPlayLater(fileSystemItems: [FileSystemItem]) -> IndexSet
}

extension PlayQueueDelegateProtocol {
    
    func loadTracks(from files: [URL], autoplay: Bool) {
        loadTracks(from: files, atPosition: nil, clearQueue: false, autoplay: autoplay)
    }
    
    func loadTracks(from files: [URL], clearQueue: Bool, autoplay: Bool) {
        loadTracks(from: files, atPosition: nil, clearQueue: clearQueue, autoplay: autoplay)
    }
}
