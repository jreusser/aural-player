//
//  FileReader.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  
import Foundation

///
/// A facade for loading metadata for a file.
/// 
/// Delegates to either **AVFoundation** or **FFmpeg** depending on whether or not
/// the file is natively supported.
///
class FileReader: FileReaderProtocol {
    
    ///
    /// The actual file reader for natively supported tracks. Uses AVFoundation.
    ///
    let avfReader: AVFFileReader = AVFFileReader()
    
#if os(macOS)
    
    ///
    /// The actual file reader for non-native tracks. Uses FFmpeg.
    ///
    let ffmpegReader: FFmpegFileReader = FFmpegFileReader()
    
#endif
    
    func getPrimaryMetadata(for file: URL) throws -> PrimaryMetadata {
        
        // TODO: Temporarily disabling the cache. Is this really useful ??? Benefit (performance) vs code complexity / probability of bugs.
//        if let cachedMetadata = metadataRegistry[file] {
//            return cachedMetadata
//        }
        
#if os(macOS)
        
        let metadata = file.isNativelySupported ?
            try avfReader.getPrimaryMetadata(for: file) :
            try ffmpegReader.getPrimaryMetadata(for: file)
        
//        metadataRegistry[file] = metadata
        return metadata
        
        #elseif os(iOS)
        
        try avfReader.getPrimaryMetadata(for: file)
        
        #endif
    }
    
    func computeAccurateDuration(for file: URL) -> Double? {
        
#if os(macOS)
        
        return file.isNativelySupported ?
            avfReader.computeAccurateDuration(for: file) :
            ffmpegReader.computeAccurateDuration(for: file)
        
#elseif os(iOS)
        avfReader.computeAccurateDuration(for: file)
#endif
    }
    
    func getPlaybackMetadata(for file: URL) throws -> PlaybackContextProtocol {
        
#if os(macOS)
        
        return file.isNativelySupported ?
            try avfReader.getPlaybackMetadata(for: file) :
            try ffmpegReader.getPlaybackMetadata(for: file)
        
#elseif os(iOS)
        
        try avfReader.getPlaybackMetadata(for: file)
        
#endif
        
    }
    
    func getArt(for file: URL) -> CoverArt? {
        
        // Try retrieving cover art from the cache.
        if let cachedArt = CoverArtCache.forFile(file) {
            return cachedArt.art
        }
        
#if os(macOS)
        
        // Cover art was not found in the cache, load it from the appropriate file reader.
        let art: CoverArt? = file.isNativelySupported ?
            avfReader.getArt(for: file) :
            ffmpegReader.getArt(for: file)
        
#elseif os(iOS)
        
        let art: CoverArt? = avfReader.getArt(for: file)
        
#endif
        
        // Update the cache with the newly loaded cover art.
        CoverArtCache.addEntry(file, art)
        
        return art
    }
    
    func getAuxiliaryMetadata(for file: URL, loadingAudioInfoFrom playbackContext: PlaybackContextProtocol? = nil) -> AuxiliaryMetadata {
        
        // Load aux metadata for the track.
        
#if os(macOS)
        
        let actualFileReader: FileReaderProtocol = file.isNativelySupported ? avfReader : ffmpegReader
        return actualFileReader.getAuxiliaryMetadata(for: file, loadingAudioInfoFrom: playbackContext)
        
#elseif os(iOS)
        avfReader.getAuxiliaryMetadata(for: file, loadingAudioInfoFrom: playbackContext)
#endif
    }
    
    func getAllMetadata(for file: URL) -> FileMetadata {
        
#if os(macOS)
        
        return file.isNativelySupported ?
            avfReader.getAllMetadata(for: file) :
            ffmpegReader.getAllMetadata(for: file)
        
#elseif os(iOS)
        avfReader.getAllMetadata(for: file)
#endif
    }
}
