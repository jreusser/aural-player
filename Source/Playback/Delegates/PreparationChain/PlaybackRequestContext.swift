import Foundation

class PlaybackRequestContext {
    
    // Current state can change (if waiting or transcoding before playback)
    var currentState: PlaybackState
    
    let currentTrack: Track?
    let currentSeekPosition: Double

    // TODO: Can this be nil ???
    let requestedTrack: Track?
    
    let requestedByUser: Bool
    
    // Request params may change as the preparation chain executes.
    var requestParams: PlaybackParams
    
    var gapContextId: Int?

    private init(_ currentState: PlaybackState, _ currentTrack: Track?, _ currentSeekPosition: Double, _ requestedTrack: Track?, _ requestedByUser: Bool, _ requestParams: PlaybackParams) {
        
        self.currentState = currentState
        self.currentTrack = currentTrack
        self.currentSeekPosition = currentSeekPosition
        
        self.requestedTrack = requestedTrack
        self.requestedByUser = requestedByUser
        self.requestParams = requestParams
        
        self.gapContextId = nil
    }
    
    func begun() {
        PlaybackRequestContext.begun(self)
    }
    
    func completed() {
        PlaybackRequestContext.completed(self)
    }
    
    func toString() -> String {
        return String(describing: JSONMapper.map(self))
    }
    
    static var currentContext: PlaybackRequestContext?
    
    static func create(_ currentState: PlaybackState, _ currentTrack: Track?, _ currentSeekPosition: Double, _ requestedTrack: Track?, _ requestedByUser: Bool, _ requestParams: PlaybackParams) -> PlaybackRequestContext {
        
        return PlaybackRequestContext(currentState, currentTrack, currentSeekPosition, requestedTrack, requestedByUser, requestParams)
    }
    
    static func begun(_ context: PlaybackRequestContext) {
        currentContext = context
    }
    
    static func completed(_ context: PlaybackRequestContext) {
        
        if isCurrent(context) {
            clearCurrentContext()
        }
    }
    
    static func isCurrent(_ context: PlaybackRequestContext) -> Bool {
        return context === currentContext
    }
    
    static func clearCurrentContext() {
        currentContext = nil
    }
}
