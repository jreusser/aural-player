import Foundation

protocol FileReaderProtocol {
    
    func getPlaylistMetadata(for file: URL) throws -> PlaylistMetadata
    
    func getPlaybackMetadata(for file: URL) throws -> PlaybackContextProtocol
    
    func getArt(for file: URL) -> CoverArt?
    
    func getAuxiliaryMetadata(for file: URL, loadingAudioInfoFrom playbackContext: PlaybackContextProtocol?) -> AuxiliaryMetadata
}

class FileReader: FileReaderProtocol {
    
    let avfReader: AVFFileReader = AVFFileReader()
    let ffmpegReader: FFmpegFileReader = FFmpegFileReader()
    
    func getPlaylistMetadata(for file: URL) throws -> PlaylistMetadata {
        
        let fileExtension = file.pathExtension.lowercased()
        
        if AppConstants.SupportedTypes.nativeAudioExtensions.contains(fileExtension) {
            return try avfReader.getPlaylistMetadata(for: file)
            
        } else {
            return try ffmpegReader.getPlaylistMetadata(for: file)
        }
    }
    
    func getPlaybackMetadata(for file: URL) throws -> PlaybackContextProtocol {
        
        let fileExtension = file.pathExtension.lowercased()
        
        if AppConstants.SupportedTypes.nativeAudioExtensions.contains(fileExtension) {
            return try avfReader.getPlaybackMetadata(for: file)
            
        } else {
            return try ffmpegReader.getPlaybackMetadata(for: file)
        }
    }
    
    func getArt(for file: URL) -> CoverArt? {
        
        let fileExtension = file.pathExtension.lowercased()
        
        if AppConstants.SupportedTypes.nativeAudioExtensions.contains(fileExtension) {
            return avfReader.getArt(for: file)
            
        } else {
            return ffmpegReader.getArt(for: file)
        }
    }
    
    func getAuxiliaryMetadata(for file: URL, loadingAudioInfoFrom playbackContext: PlaybackContextProtocol? = nil) -> AuxiliaryMetadata {
        
        let fileExtension = file.pathExtension.lowercased()
        var auxMetadata: AuxiliaryMetadata
        
        if AppConstants.SupportedTypes.nativeAudioExtensions.contains(fileExtension) {
            auxMetadata = avfReader.getAuxiliaryMetadata(for: file, loadingAudioInfoFrom: playbackContext)
        } else {
            auxMetadata = ffmpegReader.getAuxiliaryMetadata(for: file, loadingAudioInfoFrom: playbackContext)
        }
        
        let fileSystemInfo = FileSystemInfo(file)
        let attrs = FileSystemUtils.fileAttributes(path: file.path)
        
        // Filesystem info
        fileSystemInfo.size = attrs.size
        fileSystemInfo.creationDate = attrs.creationDate
        fileSystemInfo.kindOfFile = attrs.kindOfFile
        fileSystemInfo.lastModified = attrs.lastModified
        fileSystemInfo.lastOpened = attrs.lastOpened
        
        auxMetadata.fileSystemInfo = fileSystemInfo
        
        return auxMetadata
    }
}
