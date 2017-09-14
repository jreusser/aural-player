/*
 Reads track info from the filesystem
 */

import Cocoa
import AVFoundation

class TrackIO {
    
    static func initializeTrack(_ file: URL) -> Track {
        
        let track = Track(file)
        track.duration = 0
        track.shortDisplayName = (file.deletingPathExtension().lastPathComponent)
        track.longDisplayName = nil
        
        return track
    }
    
    static func loadDisplayInfo(_ track: Track) {
        
        let sourceAsset = AVURLAsset(url: track.file, options: nil)
        track.avAsset = sourceAsset
        track.duration = sourceAsset.duration.seconds
        
        let commonMetadata = sourceAsset.commonMetadata
        var title: String?
        var artist: String?
        var art: NSImage?
        
        // TODO: Put items in a dictionary
        for item in commonMetadata {
            
            if item.commonKey == nil {
                continue
            }
            
            if let key = item.commonKey {
                
                if key == "title" {
                    if (!Utils.isStringEmpty(item.stringValue)) {
                        title = item.stringValue!
                    }
                    
                } else if key == "artist" {
                    
                    if (!Utils.isStringEmpty(item.stringValue)) {
                        artist = item.stringValue!
                    }
                    
                } else if key == "artwork" {
                    
                    let value = item.value
                    if let artwork = NSImage(data: value as! Data) {
                        art = artwork
                    }
                }
            }
        }
        
        var shortDisplayName: String = ""
        var longDisplayName: (title: String?, artist: String?)?
        
        if (title != nil) {
            
            if (artist != nil) {
                shortDisplayName = artist! + " - "
                longDisplayName = (title: title!, artist: artist!)
            } else {
                longDisplayName = (title: title!, artist: nil)
            }
            
            shortDisplayName += title!
            track.shortDisplayName = shortDisplayName
        }
        
        track.longDisplayName = longDisplayName
        track.metadata = (title, artist, art)
    }
    
    // (Lazily) load all the information required to play this track
    static func prepareForPlayback(_ track: Track) {
        
        if (track.preparedForPlayback || track.preparationFailed) {
            return
        }
        
        if (track.avAsset == nil) {
            track.avAsset = AVURLAsset(url: track.file, options: nil)
        }
        
        let assetTracks = track.avAsset?.tracks(withMediaType: AVMediaTypeAudio)
        
        // Check if the asset has any audio tracks
        if (assetTracks?.count == 0) {
            track.preparationFailed = true
            track.preparationError = NoAudioTracksError(track.file)
            return
        }
        
        // Find out if track is playable
        let assetTrack = assetTracks?[0]
        
        // TODO: What does isPlayable actually mean ?
        if (!(assetTrack?.isPlayable)!) {
            track.preparationFailed = true
            track.preparationError = TrackNotPlayableError(track.file)
            return
        }
        
        // Determine the format to find out if it is supported
        let format = getFormat(assetTrack!)
        track.format = format
        if (!AppConstants.supportedAudioFileFormats.contains(format)) {
            track.preparationFailed = true
            track.preparationError = UnsupportedFormatError(track.file, format)
            return
        }
        
        // TODO: What if file has protected content
        // Check sourceAsset.hasProtectedContent()
        // Test against a protected iTunes file
        
        if (track.duration == nil || track.duration == 0) {
            track.duration = track.avAsset?.duration.seconds
        }
        
        var avFile: AVAudioFile? = nil
        do {
            avFile = try AVAudioFile(forReading: track.file)
            
            track.avFile = avFile!
            track.sampleRate = avFile!.processingFormat.sampleRate
            track.frames = Int64(track.sampleRate! * track.duration!)
            
            track.preparedForPlayback = true
            
        } catch let error as NSError {
            
            track.preparationFailed = true
            track.preparationError = TrackNotPlayableError(track.file)
            
            NSLog("Error reading track '%@': %@", track.file.path, error.description)
        }
    }
    
    // (Lazily) load detailed track info, when it is requested by the UI
    static func loadDetailedTrackInfo(_ track: Track) {
        
        if (track.detailedInfoLoaded) {
            return
        }
        
        var fileAttrLoaded: Bool = false
        var extendedMetadataLoaded: Bool = false
        
        // Playback info is necessary for channel count info
        if (track.avFile == nil) {
            TrackIO.prepareForPlayback(track)
        }
        track.numChannels = Int(track.avFile!.fileFormat.channelCount)
        
        // File size and bit rate
        let filePath = track.file.path
        let size = FileSystemUtils.sizeOfFile(path: filePath)
        let bitRate = normalizeBitRate(Double(size.sizeBytes) * 8 / (Double(track.duration!) * Double(Size.KB)))
        track.bitRate = bitRate
        track.size = size
        
        fileAttrLoaded = true
        
        let sourceAsset = track.avAsset!
        
        // TODO: This needs to be done with a specialized ID3 reader
        
        // Retrieve extended metadata (ID3)
        let metadataList = sourceAsset.metadata
        
        for item in metadataList {
            
            if item.commonKey == nil || item.value == nil {
                continue
            }
            
            if let key = item.commonKey {
                
                if (key != "title" && key != "artist" && key != "artwork") {
                    if (!Utils.isStringEmpty(item.stringValue)) {
                        track.extendedMetadata[String(key)] = item.stringValue!
                    }
                }
            }
        }
        
        extendedMetadataLoaded = true
        
        track.detailedInfoLoaded = fileAttrLoaded && extendedMetadataLoaded
    }
    
    // (Lazily) load extended metadata (e.g. album), for a search, when it is requested by the UI
    static func loadExtendedMetadataForSearch(_ track: Track) {
        
        // Check if metadata has already been loaded
        if (track.extendedMetadata["albumName"] != nil) {
            return
        }
        
        let sourceAsset = track.avAsset!
        
        // Retrieve extended metadata (ID3)
        let metadataList = sourceAsset.commonMetadata
        
        for item in metadataList {
            
            if item.commonKey == nil || item.value == nil {
                continue
            }
            
            if let key = item.commonKey {
                
                if (key == "albumName") {
                    if (!Utils.isStringEmpty(item.stringValue)) {
                        track.extendedMetadata[String(key)] = item.stringValue!
                    }
                }
            }
        }
    }
    
    // Normalizes a bit rate by rounding it to the nearest multiple of 32. For ex, a bit rate of 251.5 kbps is rounded to 256 kbps.
    private static func normalizeBitRate(_ rate: Double) -> Int {
        return Int(round(rate/32)) * 32
    }
    
    private static func getFormat(_ assetTrack: AVAssetTrack) -> String {
        let desc = CMFormatDescriptionGetMediaSubType(assetTrack.formatDescriptions[0] as! CMFormatDescription)
        var format = codeToString(desc)
        format = format.trimmingCharacters(in: CharacterSet.init(charactersIn: "."))
        return format
    }
    
    // Converts a four character media type code to a readable string
    private static func codeToString(_ code: FourCharCode) -> String {
        let n = Int(code)
        var s: String = String (describing: UnicodeScalar((n >> 24) & 255)!)
        s.append(String(describing: UnicodeScalar((n >> 16) & 255)!))
        s.append(String(describing: UnicodeScalar((n >> 8) & 255)!))
        s.append(String(describing: UnicodeScalar(n & 255)!))
        return s.trimmingCharacters(in: CharacterSet.whitespaces)
    }
}
