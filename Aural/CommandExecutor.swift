import Foundation

class CommandExecutor {
    
    static let cancellationExitCode: Int32 = -1
    
    static func execute(_ cmd: Command) -> CommandResult {
        
        var output: NSDictionary? = nil
        var error: [String] = []
        
        let task = cmd.process
        
        if let monitoredCmd = cmd as? MonitoredCommand {
            monitoredCmd.startTime = Date()
        }
        
        task.launch()
        
        // End task after timeout interval
        if let timeout = cmd.timeout {
            
            DispatchQueue.global(qos: .background).asyncAfter(deadline: .now() + timeout, execute: {
                
                if task.isRunning {
                    task.terminate()
                    NSLog("Timed out command: %@, with args: %@", cmd.process.launchPath!, cmd.process.arguments!)
                }
            })
        }
        
        task.waitUntilExit()
        
        if let monitoredCmd = cmd as? MonitoredCommand, monitoredCmd.cancelled {
            // Task may have been canceled
            return CommandResult(nil, error, cancellationExitCode)
        }
        
        let status = task.terminationStatus
        
        if cmd.readOutput, let outpipe = task.standardOutput as? Pipe {
            
            let outdata = outpipe.fileHandleForReading.readDataToEndOfFile()
            
            do {
                
                if let dict = try JSONSerialization.jsonObject(with: outdata, options: JSONSerialization.ReadingOptions()) as? NSDictionary {
                    output = dict
                }
                
            } catch let error as NSError {
                NSLog("Error reading JSON output for command: %@, with args: %@. \nCause:", cmd.process.launchPath!, cmd.process.arguments!, error.description)
            }
        }
        
        if cmd.readErr, let errpipe = task.standardError as? Pipe {
            
            let errdata = errpipe.fileHandleForReading.readDataToEndOfFile()
            if var string = String(data: errdata, encoding: .utf8) {
                string = string.trimmingCharacters(in: .newlines)
                error = string.components(separatedBy: "\n")
            }
        }
        
        return CommandResult(output, error, status)
    }
    
    static func cancel(_ cmd: MonitoredCommand) {
        
        if cmd.process.isRunning {
            cmd.process.terminate()
        }
        
        cmd.cancelled = true
        cmd.enableMonitoring = false
    }
}

class Command {
    
    var process: Process
    var timeout: Double?
    var readOutput: Bool
    var readErr: Bool
    
    init(_ cmd : String, _ args : [String], _ timeout: Double?, _ readOutput: Bool, _ readErr: Bool) {
        
        process = Process()
        process.launchPath = cmd
        process.arguments = args
        process.qualityOfService = .userInteractive
        
        let outpipe = Pipe()
        process.standardOutput = outpipe
        
        let errpipe = Pipe()
        process.standardError = errpipe
        
        self.timeout = timeout
        
        self.readOutput = readOutput
        self.readErr = readErr
    }
    
    static func createWithOutput(cmd : String, args : [String], timeout: Double?, readOutput: Bool, readErr: Bool) -> Command {
        return Command(cmd, args, timeout, readOutput, readErr)
    }
    
    static func createSimpleCommand(cmd : String, args : [String], timeout: Double?) -> Command {
        return Command(cmd, args, timeout, false, false)
    }
}

class MonitoredCommand: Command {
 
    var track: Track
    var errorDetected: Bool = false
    
    var enableMonitoring: Bool
    var callback: ((_ command: MonitoredCommand, _ output: String) -> Void)?
    
    var cancelled: Bool = false
    
    var startTime: Date!
    
    init(_ track: Track, _ cmd : String, _ args : [String], _ qualityOfService: QualityOfService, _ timeout: Double?, _ callback: ((_ command: MonitoredCommand, _ output: String) -> Void)?, _ enableMonitoring: Bool, _ readOutput: Bool, _ readErr: Bool) {
        
        self.track = track
        
        self.enableMonitoring = enableMonitoring
        self.callback = callback
        
        super.init(cmd, args, timeout, readOutput, readErr)
      
        if callback != nil || (readOutput || readErr) {
            
            if enableMonitoring && callback != nil {
                registerCallbackForPipe(process.standardOutput as! Pipe)
                registerCallbackForPipe(process.standardError as! Pipe)
            }
        }
    }
    
    func startMonitoring() {
        
        if !enableMonitoring && callback != nil {
            
            enableMonitoring = true
            
            registerCallbackForPipe(process.standardOutput as! Pipe)
            registerCallbackForPipe(process.standardError as! Pipe)
        }
    }
    
    func stopMonitoring() {
        enableMonitoring = false
    }
    
    private func registerCallbackForPipe(_ pipe: Pipe) {
        
        pipe.fileHandleForReading.waitForDataInBackgroundAndNotify()
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name.NSFileHandleDataAvailable, object: pipe.fileHandleForReading , queue: nil) {
            notification in
            
            if self.process.isRunning && self.enableMonitoring {
                
                // Gather output and invoke callback
                let output = pipe.fileHandleForReading.availableData
                let outputString = String(data: output, encoding: String.Encoding.utf8) ?? ""
                
                self.callback!(self, outputString)
                
                // Continue monitoring
                pipe.fileHandleForReading.waitForDataInBackgroundAndNotify()
            }
        }
    }
    
    static func create(track: Track, cmd : String, args : [String], qualityOfService: QualityOfService, timeout: Double?, callback: @escaping ((_ command: MonitoredCommand, _ output: String) -> Void), enableMonitoring: Bool) -> MonitoredCommand {
        
        return MonitoredCommand(track, cmd, args, qualityOfService, timeout, callback, enableMonitoring, false, false)
    }
}

class CommandResult {
    
    var output: NSDictionary?
    var error: [String]
    var exitCode: Int32
    
    init(_ output: NSDictionary?, _ error: [String], _ exitCode: Int32) {
        
        self.output = output
        self.error = error
        self.exitCode = exitCode
    }
}
