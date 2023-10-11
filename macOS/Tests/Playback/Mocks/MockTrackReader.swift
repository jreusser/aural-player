//
//  MockTrackReader.swift
//  Tests
//
//  Copyright © 2023 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  
import AVFoundation

class MockTrackReader: TrackReader {
    
    var preparationError: DisplayableError?
    
    convenience init() {
        self.init(FileReader(), MockCoverArtReader())
    }
    
    override func prepareForPlayback(track: Track, immediate: Bool = true) throws {
        
        if let error = preparationError {
            throw error
        }
        
        track.playbackContext = MockAVFPlaybackContext(file: track.file, duration: track.duration,
                                                       audioFormat: AVAudioFormat(standardFormatWithSampleRate: 44100,
                                                                                  channels: 2)!)
    }
}
