//
//  AppDelegate.swift
//  Aural
//
//  Copyright © 2023 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

///
/// Entry point for the Aural Player application. Performs application life-cycle functions and allows launching of the app with specific files
/// from Finder.
///
@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    /// (Optional) launch parameters: files to open upon launch (can be audio or playlist files)
    private var filesToOpen: [URL] = []
    
    /// Flag that indicates whether the app has already finished launching (used when reopening the app with launch parameters)
    private var appLaunched: Bool = false
    
    /// Timestamp when the app last opened a set of files. This is used to consolidate multiple chunks of a file open operation into a single one (from the perspective of the user, it is one operation). This is necessary because a single Finder open operation results in multiple file open method calls here. Why ???
    private var lastFileOpenTime: Date?
    
    /// A window of time within which multiple file open operations will be considered as chunks of one single operation
    private let fileOpenNotificationWindow_seconds: Double = 3
    
    private lazy var tearDownOpQueue: OperationQueue = OperationQueue(opCount: 2, qos: .userInteractive)
    private lazy var recurringPersistenceOpQueue: OperationQueue = OperationQueue(opCount: 1, qos: .background)
    
    /// Measured in seconds
    private static let persistenceTaskInterval: Int = 60
    
    private lazy var persistenceTaskExecutor = RepeatingTaskExecutor(intervalMillis: Self.persistenceTaskInterval * 1000,
                                                                     task: savePersistentState,
                                                                     queue: .global(qos: .background))
    
    private lazy var messenger = Messenger(for: self)
    
    private lazy var appSetupWindowController: AppSetupWindowController = .init()
    
    override init() {
        
        super.init()
        
        SystemUtils.openFilesLimit = 10000
        configureLogging()
    }
    
    /// Make sure all logging is done to the app's log file
    private func configureLogging() {
        
        if let logFileCString = FilesAndPaths.logFile.path.cString(using: .ascii) {
            freopen(logFileCString, "a+", stderr)
        }
    }

    /// Presents the application's user interface upon app startup.
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        
        initialize()
        
        print("App launched for the first time ? \(!persistenceManager.persistentStateFileExists)")
        
        if AppSetup.setupRequired {
            
            messenger.subscribe(to: .appSetup_completed, handler: postLaunch(appSetup:))
            appSetupWindowController.showWindow(self)
            
        } else {
            postLaunch(appSetup: nil)
        }
        
        // TODO: Put 'startObserving()' in some kind of protocol ???
        colorSchemesManager.startObserving()
        fontSchemesManager.startObserving()
    }
    
    private func postLaunch(appSetup: AppSetup?) {
        
        if let theAppSetup = appSetup {
            
            colorSchemesManager.applyScheme(named: theAppSetup.colorScheme.name)
            fontSchemesManager.applyScheme(named: theAppSetup.fontScheme.name)
            
//            library.homeFolder = theAppSetup.libraryHome
        }

        appModeManager.presentApp()
        
        // Update the appLaunched flag
        appLaunched = true
        
        // Tell app components that the app has finished launching, and pass along any launch parameters (set of files to open)
        messenger.publish(.application_launched, payload: filesToOpen)
        
        beginPeriodicPersistence()
    }
    
    private func folderMonitoring() {
        
        //        try! EonilFSEvents.startWatching(
        //            paths: ["/Users/kven/Muthu"],
        //            for: ObjectIdentifier(self),
        //            onQueue: .global(qos: .utility)) {event in
        //
        //                guard let flags = event.flag else {return}
        //
        //                if flags.contains(.itemCreated) {
        //                    print("\nCreated: \(event.path)")
        //                }
        //
        //                else if flags.contains(.itemRemoved) {
        //                    print("\nRemoved: \(event.path)")
        //                }
        //
        //                else if flags.contains(.itemRenamed) {
        //                    print("\nRenamed: \(event.path)")
        //                }
        //
        //                else {
        //                    print("\n\n??? UNKNOWN: \(event)")
        //                }
        //        }
    }
    
    private func initialize() {
        
        // Force initialization of objects that would not be initialized soon enough otherwise
        // (they are not referred to in code that is executed on app startup).
        
    #if os(macOS)
        
        _ = mediaKeyHandler
        
        DispatchQueue.global(qos: .background).async {
            self.cleanUpLegacyFolders()
        }
        
    #endif
        
        _ = remoteControlManager
    }
    
    ///
    /// Clean up (delete) file system folders that were used by previous app versions that had the transcoder and/or recorder.
    ///
    private func cleanUpLegacyFolders() {
        
        let transcoderDir = FilesAndPaths.subDirectory(named: "transcoderStore")
        let artDir = FilesAndPaths.subDirectory(named: "albumArt")
        let recordingsDir = FilesAndPaths.subDirectory(named: "recordings")
        
        for folder in [transcoderDir, artDir, recordingsDir] {
            folder.delete()
        }
    }
    
    /// Opens the application with a single file (audio file or playlist)
    public func application(_ sender: NSApplication, openFile filename: String) -> Bool {
        
        self.application(sender, openFiles: [filename])
        return true
    }
    
    /// Opens the application with a set of files (audio files or playlists)
    public func application(_ sender: NSApplication, openFiles filenames: [String]) {
        
        // Mark the timestamp of this operation
        let now = Date()
        
        // Clear previously added files from filesToOpen array, and add new files
        filesToOpen = filenames.map {URL(fileURLWithPath: $0)}
        
        // If app has already launched, that means the app is "reopening" with the specified set of files
        if appLaunched {
            
            // Check when the last file open operation was performed, to see if this is a chunk of a single larger operation
            let timeSinceLastFileOpen = lastFileOpenTime != nil ? now.timeIntervalSince(lastFileOpenTime!) : (fileOpenNotificationWindow_seconds + 1)
            
            // Publish a notification to the app that it needs to open the new set of files
            let reopenMsg = AppReopenedNotification(filesToOpen: filesToOpen, isDuplicateNotification: timeSinceLastFileOpen < fileOpenNotificationWindow_seconds)
            
            messenger.publish(reopenMsg)
        }
        
        // Update the lastFileOpenTime timestamp to the current time
        lastFileOpenTime = now
    }
    
    /// Tears down app components in preparation for app termination.
    func applicationWillTerminate(_ aNotification: Notification) {
        
        // Broadcast a notification to all app components that the app will exit.
        // This call is synchronous, i.e. it will block till all observers have
        // finished saving their state or performing any cleanup.
        messenger.publish(.application_willExit)
        
        // Perform a final shutdown.
        tearDown()
    }
    
    // Called when app exits
    private func tearDown() {
        
        // App state persistence and shutting down the audio engine can be performed concurrently
        // on two background threads to save some time when exiting the app.
        
        let _persistentStateOnExit = persistentStateOnExit
        
        tearDownOpQueue.addOperations([
            
            // Persist app state to disk.
            BlockOperation {
                
                if self.recurringPersistenceOpQueue.operationCount == 0 {
                    
                    // If the recurring persistence task is not running, save state normally.
                    persistenceManager.save(_persistentStateOnExit)
                    
                } else {
                    
                    // If the recurring persistence task is running, just wait for it to finish.
                    self.recurringPersistenceOpQueue.waitUntilAllOperationsAreFinished()
                }
            },
            
            // Tear down the player and audio engine.
            BlockOperation {
                
                player.tearDown()
                audioGraph.tearDown()
            }
            
        ], waitUntilFinished: true)
    }
    
    func beginPeriodicPersistence() {
        
        DispatchQueue.global(qos: .background).asyncAfter(deadline: .now() + Double(Self.persistenceTaskInterval)) {
            self.persistenceTaskExecutor.startOrResume()
        }
    }
    
    private func savePersistentState() {
        
        // TODO: Store Window frames in memory from Window delegates (onMove and onResize) so this can be done totally from a background thread.
        
        let _persistentStateOnExit = persistentStateOnExit
        
        // Wait a bit for the main thread task to finish.
        DispatchQueue.global(qos: .background).async {
            
            // Make sure app is not tearing down ! If it is, do nothing here.
            if self.tearDownOpQueue.operationCount == 0 {
                
                self.recurringPersistenceOpQueue.addOperation {
                    persistenceManager.save(_persistentStateOnExit)
                }
            }
        }
    }
}
