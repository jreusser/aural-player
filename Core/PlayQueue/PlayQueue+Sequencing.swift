//
//  PlayQueue+Sequencing.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import Foundation

extension PlayQueue {
    
    func start() -> Track? {

        // Set the scope of the new sequence according to the playlist view type. For ex, if the "Artists" playlist view is selected, the new sequence will consist of all tracks in the "Artists" playlist, and the order of playback will be determined by the ordering within the Artists playlist (in addition to the repeat/shuffle modes).

        // Begin playing the subsequent track (first track determined by the sequence)
        subsequent()
    }

    func stop() {

        // Reset the sequence cursor (to indicate that no track is playing)
        currentTrackIndex = nil
    }

    // MARK: Specific track selection functions -------------------------------------------------------------------------------------

    func select(trackAt index: Int) -> Track? {
        
        guard let track = self[index] else {return nil}
        
        currentTrackIndex = index
        return track
    }
    
    func selectTrack(_ track: Track) -> Bool {
        
        guard let index = indexOfTrack(track) else {return false}
        
        currentTrackIndex = index
        return true
    }

    // MARK: Sequence iteration functions -------------------------------------------------------------------------------------

    func subsequent() -> Track? {
        
        currentTrackIndex = indexOfSubsequent
        return currentTrack
    }
    
    // Peeks at (without selecting for playback) the subsequent track in the sequence
    private var indexOfSubsequent: Int? {
        
        guard size > 0 else {return nil}
        
        switch (repeatMode, shuffleMode) {
            
        // Repeat Off / All, Shuffle Off
        case (.off, .off), (.all, .off):
          
            // Next track sequentially
            if let theCurTrackIndex = currentTrackIndex, theCurTrackIndex < (size - 1) {
                
                // Has more tracks, pick the next one
                return theCurTrackIndex + 1
                
            } else {
                
                // If repeating all, loop around to the first track.
                // If not repeating, nothing playing, always return the first one.
                // Else last track reached ... stop playback.
                return repeatMode == .all ? 0 : (currentTrackIndex == nil ? 0 : nil)
            }
        
        // Repeat One (Shuffle Off implied)
        case (.one, .off):
            
            // Easy, just play the same track again (assume shuffleMode is off)
            return currentTrackIndex == nil ? 0 : currentTrackIndex
        
        // Repeat Off / All, Shuffle On
        case (.off, .on), (.all, .on):
           
            // If the sequence is complete (all tracks played), no track
            // Cannot predict next track because sequence will be reset
            return shuffleSequence.peekNext()
            
        default:
            
            return nil
        }
    }
    
    func next() -> Track? {

        // If there is no previous track, don't change the playingTrack variable, because the playing track will continue playing
        if let nextIndex = indexOfNext, let nextTrack = self[nextIndex] {

            currentTrackIndex = nextIndex
            return nextTrack
        }

        return nil
    }
    
    // Peeks at (without selecting for playback) the next track in the sequence
    private var indexOfNext: Int? {
        
        guard size > 1, let theCurTrackIndex = currentTrackIndex else {return nil}
        
        if shuffleMode == .on {
            return shuffleSequence.peekNext()
            
        } // Shuffle mode is off
        else {
            return theCurTrackIndex < (size - 1) ? theCurTrackIndex + 1 : (repeatMode == .all ? 0 : nil)
        }
    }

    func previous() -> Track? {

        // If there is no previous track, don't change the playingTrack variable, because the playing track will continue playing
        if let previousIndex = indexOfPrevious, let previousTrack = self[previousIndex] {

            currentTrackIndex = previousIndex
            return previousTrack
        }

        return nil
    }
    
    // Peeks at (without selecting for playback) the previous track in the sequence
    private var indexOfPrevious: Int? {
        
        guard size > 1, let theCurTrackIndex = currentTrackIndex else {return nil}
        
        if shuffleMode == .on {
            return shuffleSequence.peekPrevious()
            
        } // Shuffle mode is off
        else {
            return theCurTrackIndex > 0 ? theCurTrackIndex - 1 : (repeatMode == .all ? size - 1 : nil)
        }
    }

    func peekSubsequent() -> Track? {

        guard let subsequentIndex = indexOfSubsequent else {return nil}
        return self[subsequentIndex]
    }

    func peekNext() -> Track? {

        guard let nextIndex = indexOfNext else {return nil}
        return self[nextIndex]
    }

    func peekPrevious() -> Track? {

        // If there is no previous track, don't change the playingTrack variable, because the playing track will continue playing
        guard let previousIndex = indexOfPrevious else {return nil}
        return self[previousIndex]
    }

    // MARK: Repeat/Shuffle -------------------------------------------------------------------------------------
    
    // Sets the repeat mode to a specific value. Returns the new repeat and shuffle mode after performing the toggle operation.
    func setRepeatMode(_ repeatMode: RepeatMode) -> RepeatAndShuffleModes {
        
        self.repeatMode = repeatMode
        
        // If repeating one track, cannot also shuffle
        if self.repeatAndShuffleModes == (.one, .on) {
            
            shuffleMode = .off
            shuffleSequence.clear()
        }
        
        return repeatAndShuffleModes
    }
    
    // Sets the shuffle mode to a specific value. Returns the new repeat and shuffle mode after performing the toggle operation.
    func setShuffleMode(_ shuffleMode: ShuffleMode) -> RepeatAndShuffleModes {
        
        // Execute this method only if the desired shuffle mode is different from the current shuffle mode.
        guard shuffleMode != self.shuffleMode else {return (repeatMode, shuffleMode)}
        
        self.shuffleMode = shuffleMode
        
        if self.shuffleMode == .on {
        
            // Can't shuffle and repeat one track
            if repeatMode == .one {
                repeatMode = .off
            }
            
            // No need to do this if no track is currently playing.
            if let theCurTrackIndex = self.currentTrackIndex {
                shuffleSequence.resizeAndReshuffle(size: size, startWith: theCurTrackIndex)
            }
            
        } // Shuffle mode is off
        else {
            
            shuffleSequence.clear()
        }
        
        return repeatAndShuffleModes
    }

    // Toggles between repeat modes. See RepeatMode for more details. Returns the new repeat and shuffle mode after performing the toggle operation.
    func toggleRepeatMode() -> RepeatAndShuffleModes {
        setRepeatMode(repeatMode.toggle())
    }
    
    // Toggles between shuffle modes. See ShuffleMode for more details. Returns the new repeat and shuffle mode after performing the toggle operation.
    func toggleShuffleMode() -> RepeatAndShuffleModes {
        setShuffleMode(shuffleMode.toggle())
    }
    
    var repeatAndShuffleModes: RepeatAndShuffleModes {
        (repeatMode, shuffleMode)
    }
}
