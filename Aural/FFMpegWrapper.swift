import Cocoa

class FFMpegWrapper {
    
    static let ffprobeBinaryPath: String = Bundle.main.url(forResource: "ffprobe", withExtension: "")!.path
    static let ffmpegBinaryPath: String = Bundle.main.url(forResource: "ffmpeg", withExtension: "")!.path
    
    static let metadataIgnoreKeys: [String] = ["bitrate"]
    
    static let getMetadata_timeout: Double = 3
    static let getArtwork_timeout: Double = 10
    
    static let artBaseDir: URL = {
        
        let dir = AppConstants.FilesAndPaths.baseDir.appendingPathComponent("albumArt", isDirectory: true)
        FileSystemUtils.createDirectory(dir)
        return dir
        
    }()
    
    static func getMetadata(_ track: Track) -> LibAVInfo {
        
        var tags: [String: String] = [:]
        var streams: [LibAVStream] = []
        var duration: Double = 0
        var fileFormatDescription: String?
        
        // TODO:
        var drmProtected: Bool = false
        
        // ffprobe -v error -show_entries "stream=codec_name,codec_type,bit_rate,channels,sample_rate : format=duration :  stream_tags : format_tags" -of json Song.mp3
        
        let inputFile = track.file
        let command = Command.createWithOutput(cmd: ffprobeBinaryPath, args: ["-v", "error", "-show_entries", "stream=codec_name,codec_long_name,codec_type,bit_rate,channels,sample_rate:format=duration,format_long_name:stream_tags:format_tags", "-of", "json", inputFile.path], timeout: getMetadata_timeout, readOutput: true, readErr: true)
        
        let result = CommandExecutor.execute(command)
        
        if result.exitCode != 0 {
            return LibAVInfo(0, "", streams, [:], false)
        }
        
        if let dict = result.output {
            
            if let streamsArr = dict["streams"] as? [NSDictionary] {
                
                for streamDict in streamsArr {
                    
                    // Stream info must have type and format. Otherwise, we cannot process it
                    if var codecType = streamDict["codec_type"] as? String, let codecName = streamDict["codec_name"] as? String {
                        
                        codecType = codecType.lowercased()
                        
                        if codecType == "audio" {
                            
                            // Audio track
                            
                            let codecDescription: String? = streamDict["codec_long_name"] as? String
                            
                            var bitRate: Double?
                            var channelCount: Int = 0
                            var sampleRate: Double = 0
                            
                            if let bitRateStr = streamDict["bit_rate"] as? String, let num = Double(bitRateStr) {
                                bitRate = num / 1024
                            }
                            
                            if let channelCountInt = streamDict["channels"] as? Int {
                                channelCount = channelCountInt
                            }
                            
                            if let sampleRateStr = streamDict["sample_rate"] as? String, let rate = Double(sampleRateStr) {
                                sampleRate = rate
                            }
                            
                            if let tagsDict = streamDict["tags"] as? [String: String] {
                                
                                for (key, value) in tagsDict {
                                    tags[key.lowercased()] = value
                                }
                                
                                // DRM check
                                if inputFile.pathExtension.lowercased().hasPrefix("wma"), let value = tags["asf_protection_type"], value == "DRM" {
                                    drmProtected = true
                                }
                            }
                            
                            streams.append(LibAVStream(codecName.lowercased(), codecDescription, bitRate, channelCount, sampleRate))
                            
                        } else if codecType == "video" {
                            
                            // Art
                            streams.append(LibAVStream(codecName.lowercased()))
                        }
                    }
                }
            }
            
            if let formatDict = dict["format"] as? NSDictionary {
                
                if let tagsDict = formatDict["tags"] as? [String: String] {
                    
                    for (key, value) in tagsDict {
                        tags[key.lowercased()] = value
                    }
                    
                    // DRM check
                    if inputFile.pathExtension.lowercased().hasPrefix("wma"), let value = tags["asf_protection_type"], value == "DRM" {
                        drmProtected = true
                    }
                }
                
                if let durationStr = formatDict["duration"] as? String, let num = Double(durationStr) {
                    duration = num
                }
                
                fileFormatDescription = formatDict["format_long_name"] as? String
            }
        }
        
        return LibAVInfo(duration, fileFormatDescription, streams, tags, drmProtected)
    }
    
    static func getArt(_ track: Track) -> NSImage? {
        return getArt(track.file)
    }
    
    static func getArt(_ inputFile: URL) -> NSImage? {
        
        let now = Date()
        let imgPath = String(format: "%@-albumArt-%@.jpg", artBaseDir.appendingPathComponent(inputFile.lastPathComponent).path, now.serializableString_hms())
        
        let command = Command.createSimpleCommand(cmd: ffmpegBinaryPath, args: ["-v", "0", "-i", inputFile.path, "-an", "-vcodec", "copy", imgPath], timeout: getArtwork_timeout)
        
        let result = CommandExecutor.execute(command)
        
        var image: NSImage?
        if result.exitCode == 0 {
            
            image = NSImage(contentsOf: URL(fileURLWithPath: imgPath))

            DispatchQueue.global(qos: .background).async {
                FileSystemUtils.deleteFile(imgPath)
            }
        }
        
        return image
    }
    
    static func createTranscoderCommand(_ track: Track, _ outputFile: URL, _ mapping: FormatMapping, _ progressCallback: @escaping ((_ command: MonitoredCommand, _ output: String) -> Void), _ qualityOfService: QualityOfService, _ enableMonitoring: Bool) -> MonitoredCommand {
        
        var args = ["-v", "quiet", "-stats", "-i", track.file.path]
        
        if mapping.action == .transmux {
            args.append(contentsOf: ["-acodec", "copy"])
        } else if let encoder = mapping.encoder {
            args.append(contentsOf: ["-acodec", encoder])
        }
        
        if let sampleRate = mapping.sampleRate {
            args.append(contentsOf: ["-ar", String(describing: sampleRate)])
        }

        // -vn: Ignore video stream (including album art)
        // -sn: Ignore subtitles
        // -ac 2: Convert to stereo audio (i.e. "downmix")
        args.append(contentsOf: ["-vn", "-sn", outputFile.path])
        
        print("Created transcoder cmd with args:", args)
        
        return MonitoredCommand.create(track: track, cmd: ffmpegBinaryPath, args: args, qualityOfService: qualityOfService, timeout: nil, callback: progressCallback, enableMonitoring: enableMonitoring)
    }
}
