import Foundation

/*
    Contains the logic that determines the order in which tracks will be selected for playback.
    The order depends on:
 
    - the order of tracks in the playlist from which the sequence was created (i.e. the playback scope)
    - the repeat and shuffle modes
 
    This is a linear playback sequence that is unaware of the scope (entire playlist or specific group) from which the sequence was created. The size of the sequence will equal the number of tracks in the playback scope, and the indexes will represent absolute indexes within the sequence, that do not necessarily correspond to playlist indexes.
 
    Examples: 
 
         - If the scope was "All tracks" and there were 5 tracks in the playlist, the sequence might look like [0, 1, 2, 3, 4] or if shuffle is selected, maybe [2, 4, 3, 0, 1]
 
        - If the scope was "Artist: Madonna" and there were 3 tracks in the Madonna artist group, the sequence might look like [0, 1, 2] or if shuffle is selected, maybe [2, 0, 1] ... regardless of how many total tracks or groups there are in the entire playlist.
 */
class PlaybackSequence {
    
    private var repeatMode: RepeatMode = .off
    private var shuffleMode: ShuffleMode = .off
    
    // Total size of sequence (i.e. number of tracks)
    private(set) var size: Int = 0
    
    // Returns the index, within this sequence, of the currently playing track (nil if no track is playing)
    internal var cursor: Int? = nil
    
    // Contains a pre-computed shuffle sequence, when shuffleMode is .on
    private let shuffleSequence: ShuffleSequence = ShuffleSequence()
    
    init(_ repeatMode: RepeatMode, _ shuffleMode: ShuffleMode) {
        
        self.repeatMode = repeatMode
        self.shuffleMode = shuffleMode
    }
    
    // Resizes and restarts the sequence with the given size.
    // The newCursor parameter denotes the first element (i.e. track) in the new sequence.
    func resizeAndStart(size: Int, withCursor newCursor: Int? = nil) {
        
        print(String(format: "\nResizing PLBK sequence with size: %d and newCursor: %@", size, String(describing: newCursor)))
        
        self.size = size
        self.cursor = newCursor
        
        if shuffleMode == .on {
            shuffleSequence.resizeAndReshuffle(size: size, startWith: newCursor)
        }
        
        print("\tCursor now:", cursor)
    }
    
    // Restarts the sequence with the given value as the first element (i.e. track) in the new sequence.
    func start(withCursor newCursor: Int? = nil) {
        
        print(String(format: "\nStarting PLBK sequence with newCursor: %@", String(describing: newCursor)))
        
        self.cursor = newCursor
        
        if shuffleMode == .on {
            shuffleSequence.resizeAndReshuffle(size: size, startWith: newCursor)
        }
        
        print("\tCursor now:", cursor)
    }
    
    // Ends the sequence (i.e. invalidates the cursor).
    func end() {
        cursor = nil
    }
    
    // Removes all elements from the sequence and resets the cursor. (reflects an empty playlist)
    func clear() {
        
        print(String(format: "\nClearing PLBK sequence"))
        
        shuffleSequence.clear()
        size = 0
        cursor = nil
    }
    
    // MARK: Repeat and Shuffle functions ------------------------------------------------------------------------------------------
    
    // Toggles between repeat modes. See RepeatMode for more details. Returns the new repeat and shuffle mode after performing the toggle operation.
    func toggleRepeatMode() -> (repeatMode: RepeatMode, shuffleMode: ShuffleMode) {
        
        switch repeatMode {
            
        case .off:
            
            repeatMode = .one
            
            // If repeating one track, cannot also shuffle
            if shuffleMode == .on {
                
                shuffleMode = .off
                shuffleSequence.clear()
            }
            
        case .one: repeatMode = .all
        case .all: repeatMode = .off
            
        }
        
        return (repeatMode, shuffleMode)
    }
    
    // Sets the repeat mode to a specific value. Returns the new repeat and shuffle mode after performing the toggle operation.
    func setRepeatMode(_ repeatMode: RepeatMode) -> (repeatMode: RepeatMode, shuffleMode: ShuffleMode) {
        
        self.repeatMode = repeatMode
        
        // If repeating one track, cannot also shuffle
        if repeatMode == .one && shuffleMode == .on {
            
            shuffleMode = .off
            shuffleSequence.clear()
        }
        
        return (repeatMode, shuffleMode)
    }
    
    // Toggles between shuffle modes. See ShuffleMode for more details. Returns the new repeat and shuffle mode after performing the toggle operation.
    func toggleShuffleMode() -> (repeatMode: RepeatMode, shuffleMode: ShuffleMode) {
        return setShuffleMode(self.shuffleMode == .on ? .off : .on)
    }
    
    // Sets the shuffle mode to a specific value. Returns the new repeat and shuffle mode after performing the toggle operation.
    func setShuffleMode(_ shuffleMode: ShuffleMode) -> (repeatMode: RepeatMode, shuffleMode: ShuffleMode) {
        
        // Execute this method only if the desired shuffle mode is different from the current shuffle mode.
        guard shuffleMode != self.shuffleMode else {return (repeatMode, shuffleMode)}
        
        self.shuffleMode = shuffleMode
        
        if shuffleMode == .on {
        
            // Can't shuffle and repeat one track
            if repeatMode == .one {
                repeatMode = .off
            }
            
            // No need to do this if no track is currently playing.
            if let theCursor = self.cursor {
                shuffleSequence.resizeAndReshuffle(size: size, startWith: theCursor)
            }
            
        } else {    // Shuffle mode is off
            
            shuffleSequence.clear()
        }
        
        return (repeatMode, shuffleMode)
    }
    
    // MARK: Sequence iteration functions ---------------------------------------------
    
    /*
        NOTE - "Subsequent track" is the track in the sequence that will be selected automatically by the app if playback of a track completes. It involves no user input.
    
        By contrast, "Next track" is the track in the sequence that will be selected if the user requests the next track in the sequence. This may or may not be the same as the "Subsequent track".
     
        For example, if the Repeat One setting is on, and a track is playing, Subsequent track will return the same track, while Next track will return the next playlist track or nil (if end has been reached).
     */
    
    // NOTE - In the following iteration functions, a non-nil return value represents the index, within the sequence, of the track selected for playback. A nil return value means no applicable track.
    
    // Selects, for playback, the subsequent track in the sequence
    func subsequent() -> Int? {

        guard size > 0 else {return nil}
        
        // NOTE - If shuffle is on, it is important to call resetShuffleSequence() or next() here, and update the cursor.
        // Cannot simply return the value from peekSubsequent().
        
        cursor = shuffleMode == .on ? shuffleSequence.next(repeatMode: repeatMode) : peekSubsequent()
        return cursor
    }
    
    // Peeks at (without selecting for playback) the subsequent track in the sequence
    func peekSubsequent() -> Int? {
        
        guard size > 0 else {return nil}
        
        switch (repeatMode, shuffleMode) {
            
        // Repeat Off / All, Shuffle Off
        case (.off, .off), (.all, .off):
          
            // Next track sequentially
            if let theCursor = cursor, theCursor < (size - 1) {
                
                // Has more tracks, pick the next one
                return theCursor + 1
                
            } else {
                
                // If repeating all, loop around to the first track.
                // If not repeating, nothing playing, always return the first one.
                // Else last track reached ... stop playback.
                return repeatMode == .all ? 0 : (cursor == nil ? 0 : nil)
            }
        
        // Repeat One (Shuffle Off implied)
        case (.one, .off):
            
            // Easy, just play the same track again (assume shuffleMode is off)
            return cursor == nil ? 0 : cursor
        
        // Repeat Off / All, Shuffle On
        case (.off, .on), (.all, .on):
           
            // If the sequence is complete (all tracks played), no track
            // Cannot predict next track because sequence will be reset
            return shuffleSequence.peekNext()
            
        default:
            
            return nil
        }
    }
    
    // Selects, for playback, the next track in the sequence
    func next() -> Int? {
        
        guard size > 1, cursor != nil else {return nil}
        
        // NOTE - If shuffle is on, it is important to call resetShuffleSequence() or next() here, and update the cursor.
        // Cannot simply return the value from peekNext().
        let computedValue = shuffleMode == .on ? shuffleSequence.next(repeatMode: repeatMode) : peekNext()
        
        // Update the cursor only with a non-nil value.
        if let nonNilComputedValue = computedValue {
            cursor = nonNilComputedValue
        }
        
        return computedValue
    }
    
    // Peeks at (without selecting for playback) the next track in the sequence
    func peekNext() -> Int? {
        
        guard size > 1, let theCursor = cursor else {return nil}
        
        if shuffleMode == .on {
            return shuffleSequence.peekNext()
            
        } // Shuffle mode is off
        else {
            return theCursor < (size - 1) ? theCursor + 1 : (repeatMode == .all ? 0 : nil)
        }
    }
    
    // Selects, for playback, the previous track in the sequence
    func previous() -> Int? {
        
        guard size > 1, cursor != nil else {return nil}
        
        // NOTE - If shuffle is on, it is important to call shuffleSequence.previous() here.
        // Cannot simply return the value from peekPrevious().
        let computedValue = shuffleMode == .on ? shuffleSequence.previous() : peekPrevious()

        // Update the cursor only with a non-nil value.
        if let nonNilComputedValue = computedValue {
            cursor = nonNilComputedValue
        }
        
        return computedValue
    }
    
    // Peeks at (without selecting for playback) the previous track in the sequence
    func peekPrevious() -> Int? {
        
        guard size > 1, let theCursor = cursor else {return nil}
        
        if shuffleMode == .on {
            return shuffleSequence.peekPrevious()
            
        } // Shuffle mode is off
        else {
            return theCursor > 0 ? theCursor - 1 : (repeatMode == .all ? size - 1 : nil)
        }
    }
    
    // Returns the current repeat and shuffle modes
    var repeatAndShuffleModes: (repeatMode: RepeatMode, shuffleMode: ShuffleMode) {
        return (repeatMode, shuffleMode)
    }
}
