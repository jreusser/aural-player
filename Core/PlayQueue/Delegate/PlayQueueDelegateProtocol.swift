import Foundation

protocol PlayQueueDelegateProtocol {
    
    var tracks: [Track] {get}
    var size: Int {get}
    var duration: Double {get}
    
    // Whether or not tracks are being added to the play queue (which could be time consuming)
    var isBeingModified: Bool {get}
    
    subscript(_ index: Int) -> Track? {get}
    
    func indexOfTrack(_ track: Track) -> Int?
    
    var summary: (size: Int, totalDuration: Double) {get}
    
    func search(_ searchQuery: SearchQuery) -> SearchResults
    
    // MARK: Mutating functions ---------------------------------------------------------------
    
    func addTracks(from files: [URL], atPosition position: Int?)
    
    // Adds tracks to the end of the queue, i.e. "Play Later"
    func enqueueToPlayLater(_ tracks: [Track]) -> ClosedRange<Int>
    
    // Adds tracks to the beginning of the queue, i.e. "Play Now"
    func enqueueToPlayNow(_ tracks: [Track]) -> ClosedRange<Int>

    // Inserts tracks immediately after the current track, i.e. "Play Next"
    func enqueueToPlayNext(_ tracks: [Track]) -> ClosedRange<Int>
    
    func removeTracks(_ indices: IndexSet) -> [Track]

    func moveTracksUp(_ indices: IndexSet) -> [TrackMoveResult]
    
    func moveTracksToTop(_ indices: IndexSet) -> [TrackMoveResult]
    
    func moveTracksDown(_ indices: IndexSet) -> [TrackMoveResult]
    
    func moveTracksToBottom(_ indices: IndexSet) -> [TrackMoveResult]
    
    func dropTracks(_ sourceIndices: IndexSet, _ dropIndex: Int) -> [TrackMoveResult]
    
    func export(to file: URL)
    
    func clear()
    
    func sort(_ sort: Sort)
    
    func sort(by comparator: (Track, Track) -> Bool)
}
