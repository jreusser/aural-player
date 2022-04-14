//
//  ObjectGraph.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Foundation

///
/// (Lazily) Initializes all the core objects and state required by the application (mostly singletons), and exposes them for application-wide
/// use as dependencies.
///
/// Acts as a simple alternative to a dependency injection framework / container.
///
class ObjectGraph {
    
    static let instance: ObjectGraph = .init()
    
    private let persistenceManager: PersistenceManager = PersistenceManager(persistentStateFile: FilesAndPaths.persistentStateFile)
    lazy var persistentState: AppPersistentState = persistenceManager.load(type: AppPersistentState.self) ?? .defaults
    
    let preferences: Preferences = Preferences(defaults: .standard)
    
#if os(macOS)
    
    lazy var appModeManager: AppModeManager = AppModeManager(persistentState: persistentState.ui,
                                                             preferences: preferences.viewPreferences)
    
#endif
    
    private lazy var playQueue: PlayQueue = PlayQueue()
    
    //    lazy var playlistsManager: PlaylistsManager = {
    //
    //        let userPlaylistNames = (persistentState.playlist?.userPlaylists ?? []).compactMap {$0.name}
    //
    //        return PlaylistsManager(systemPlaylist: self.playlist,
    //                                userPlaylists: userPlaylistNames.map {
    //
    //                                    Playlist(name: $0, userDefined: true, needsLoadingFromPersistentState: true, FlatPlaylist(),
    //                                             [GroupingPlaylist(.artists), GroupingPlaylist(.albums), GroupingPlaylist(.genres)])
    //                                })
    //    }()
    
//    lazy var playlistDelegate: PlaylistDelegateProtocol = PlaylistDelegate(persistentState: persistentState.playlist, playlist,
//                                                                           trackReader, preferences)
    
    lazy var playQueueDelegate: PlayQueueDelegateProtocol = PlayQueueDelegate(playQueue: playQueue, trackReader: trackReader,
                                                                              persistentState: persistentState.playQueue)
    
    lazy var audioUnitsManager: AudioUnitsManager = AudioUnitsManager()
    private lazy var audioEngine: AudioEngine = AudioEngine()
    
    private lazy var audioGraph: AudioGraph = AudioGraph(audioEngine: audioEngine, audioUnitsManager: audioUnitsManager,
                                                         persistentState: persistentState.audioGraph)
    
    lazy var audioGraphDelegate: AudioGraphDelegateProtocol = AudioGraphDelegate(graph: audioGraph, persistentState: persistentState.audioGraph,
                                                                                 player: playbackDelegate, preferences: preferences.soundPreferences)
    
#if os(macOS)
    private lazy var player: PlayerProtocol = Player(graph: audioGraph, avfScheduler: avfScheduler, ffmpegScheduler: ffmpegScheduler)
#elseif os(iOS)
    private lazy var player: PlayerProtocol = Player(graph: audioGraph, avfScheduler: avfScheduler, ffmpegScheduler: avfScheduler)
#endif
    
    private lazy var avfScheduler: PlaybackSchedulerProtocol = AVFScheduler(audioGraph.playerNode)
    
#if os(macOS)
    
    private lazy var ffmpegScheduler: PlaybackSchedulerProtocol = FFmpegScheduler(playerNode: audioGraph.playerNode,
                                                                                  sampleConverter: FFmpegSampleConverter())
    
#endif
    
    lazy var playbackDelegate: PlaybackDelegateProtocol = {
        
        let profiles = PlaybackProfiles(persistentState: persistentState.playbackProfiles ?? [])
        
        let startPlaybackChain = StartPlaybackChain(player, playQueue: playQueue, trackReader: trackReader, profiles, preferences.playbackPreferences)
        let stopPlaybackChain = StopPlaybackChain(player, playQueue, profiles, preferences.playbackPreferences)
        let trackPlaybackCompletedChain = TrackPlaybackCompletedChain(startPlaybackChain, stopPlaybackChain, playQueue)
        
        // Playback Delegate
        return PlaybackDelegate(player, playQueue: playQueue, profiles, preferences.playbackPreferences,
                                startPlaybackChain, stopPlaybackChain, trackPlaybackCompletedChain)
    }()
    
    var playbackInfoDelegate: PlaybackInfoDelegateProtocol {playbackDelegate}
    
    var historyDelegate: HistoryDelegateProtocol {_historyDelegate}
    private lazy var _historyDelegate: HistoryDelegate = HistoryDelegate(persistentState: persistentState.history, preferences.historyPreferences, playQueueDelegate, playbackDelegate)
    
    var favoritesDelegate: FavoritesDelegateProtocol {_favoritesDelegate}
    private lazy var _favoritesDelegate: FavoritesDelegate = FavoritesDelegate(persistentState: persistentState.favorites, playQueueDelegate,
                                                                               playbackDelegate)
    
    var bookmarksDelegate: BookmarksDelegateProtocol {_bookmarksDelegate}
    private lazy var _bookmarksDelegate: BookmarksDelegate = BookmarksDelegate(persistentState: persistentState.bookmarks, playQueueDelegate,
                                                                               playbackDelegate)
    
    lazy var fileReader: FileReader = FileReader()
    lazy var trackReader: TrackReader = TrackReader(fileReader, coverArtReader)
    
    lazy var coverArtReader: CoverArtReader = CoverArtReader(fileCoverArtReader, musicBrainzCoverArtReader)
    lazy var fileCoverArtReader: FileCoverArtReader = FileCoverArtReader(fileReader)
    lazy var musicBrainzCoverArtReader: MusicBrainzCoverArtReader = MusicBrainzCoverArtReader(preferences: preferences.metadataPreferences.musicBrainz,
                                                                                              cache: musicBrainzCache)
    
    lazy var musicBrainzCache: MusicBrainzCache = MusicBrainzCache(state: persistentState.musicBrainzCache,
                                                                   preferences: preferences.metadataPreferences.musicBrainz)
    
#if os(macOS)
    
    lazy var windowLayoutsManager: WindowLayoutsManager = WindowLayoutsManager(persistentState: persistentState.ui?.windowLayout,
                                                                               viewPreferences: preferences.viewPreferences)
    
    lazy var themesManager: ThemesManager = ThemesManager(persistentState: persistentState.ui?.themes, fontSchemesManager: fontSchemesManager)
    lazy var fontSchemesManager: FontSchemesManager = FontSchemesManager(persistentState: persistentState.ui?.fontSchemes)
    lazy var colorSchemesManager: ColorSchemesManager = ColorSchemesManager(persistentState: persistentState.ui?.colorSchemes)
    
    lazy var playerUIState: PlayerUIState = PlayerUIState(persistentState: persistentState.ui?.player)
//    lazy var playlistUIState: PlaylistUIState = PlaylistUIState(persistentState: persistentState.ui?.playlist)
    lazy var menuBarPlayerUIState: MenuBarPlayerUIState = MenuBarPlayerUIState(persistentState: persistentState.ui?.menuBarPlayer)
    lazy var controlBarPlayerUIState: ControlBarPlayerUIState = ControlBarPlayerUIState(persistentState: persistentState.ui?.controlBarPlayer)
    lazy var visualizerUIState: VisualizerUIState = VisualizerUIState(persistentState: persistentState.ui?.visualizer)
    lazy var windowAppearanceState: WindowAppearanceState = WindowAppearanceState(persistentState: persistentState.ui?.windowAppearance)
    
    let mediaKeyHandler: MediaKeyHandler
    
#endif
    
    lazy var remoteControlManager: RemoteControlManager = RemoteControlManager(playbackInfo: playbackInfoDelegate, playQueue: playQueueDelegate, audioGraph: audioGraphDelegate,
                                                                               preferences: preferences)
    
    // Performs all necessary object initialization
    private init() {
        
        // Force initialization of objects that would not be initialized soon enough otherwise
        // (they are not referred to in code that is executed on app startup).
        
#if os(macOS)
        
        self.mediaKeyHandler = MediaKeyHandler(preferences.controlsPreferences.mediaKeys)
        
#endif
        
        _ = remoteControlManager
        
        DispatchQueue.global(qos: .background).async {
            self.cleanUpLegacyFolders()
        }
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
    
    private lazy var tearDownOpQueue: OperationQueue = OperationQueue(opCount: 2, qos: .userInteractive)
    
    // Called when app exits
    func tearDown() {
        
        // Gather all pieces of persistent state into the persistentState object
        var persistentState: AppPersistentState = AppPersistentState()
        
        persistentState.appVersion = appVersion
        
        persistentState.audioGraph = audioGraph.persistentState
        persistentState.playQueue = playQueue.persistentState
        persistentState.playbackProfiles = playbackDelegate.profiles.all().map {PlaybackProfilePersistentState(profile: $0)}
        
#if os(macOS)
        
        persistentState.ui = UIPersistentState(appMode: appModeManager.currentMode,
                                               windowLayout: windowLayoutsManager.persistentState,
                                               themes: themesManager.persistentState,
                                               fontSchemes: fontSchemesManager.persistentState,
                                               colorSchemes: colorSchemesManager.persistentState,
                                               player: playerUIState.persistentState,
//                                               playlist: playlistUIState.persistentState,
                                               visualizer: visualizerUIState.persistentState,
                                               windowAppearance: windowAppearanceState.persistentState,
                                               menuBarPlayer: menuBarPlayerUIState.persistentState,
                                               controlBarPlayer: controlBarPlayerUIState.persistentState)
        
#endif
        
        persistentState.history = _historyDelegate.persistentState
        persistentState.favorites = _favoritesDelegate.persistentState
        persistentState.bookmarks = _bookmarksDelegate.persistentState
        persistentState.musicBrainzCache = musicBrainzCoverArtReader.cache.persistentState
        
        // App state persistence and shutting down the audio engine can be performed concurrently
        // on two background threads to save some time when exiting the app.
        
        tearDownOpQueue.addOperations([
            
            // Persist app state to disk.
            BlockOperation {
                self.persistenceManager.save(persistentState)
            },
            
            // Tear down the player and audio engine.
            BlockOperation {
                self.player.tearDown()
                self.audioGraph.tearDown()
            }
            
        ], waitUntilFinished: true)
    }
}
