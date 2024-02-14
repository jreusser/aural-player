//
//  Globals.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

#if os(macOS)

import AppKit
let appVersion: String = NSApp.appVersion
let appSetup: AppSetup = .shared

#endif

fileprivate let logger: Logger = .init()

let persistenceManager: PersistenceManager = PersistenceManager(persistentStateFile: FilesAndPaths.persistentStateFile)
let appPersistentState: AppPersistentState = {
    
    // TODO: Replace try? with do {try} and log the error!
    // TODO: Add an arg to Logger.error(error: Error)
    guard let jsonString = try? String(contentsOf: FilesAndPaths.persistentStateFile, encoding: .utf8),
          let jsonData = jsonString.data(using: .utf8),
          let dict = try? JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any] else {
        
        logger.warning("Error loading app state config file.")
        return .defaults
    }
    
    if let appVersionString = dict["appVersion"] as? String,
       let appVersion = AppVersion(versionString: appVersionString) {
        
        print("App major version: \(appVersion.majorVersion)")
        
        if appVersion.majorVersion < 4, let legacyPersistentState: LegacyAppPersistentState = persistenceManager.load(type: LegacyAppPersistentState.self) {
            
            // Attempt migration and return the mapped instance.
            print("Mapped persistent state from app version: \(appVersionString)\n")
            return AppPersistentState(legacyAppPersistentState: legacyPersistentState)
        }
    }
    
    return persistenceManager.load(type: AppPersistentState.self) ?? .defaults
}()

let userDefaults: UserDefaults = .standard
let preferences: Preferences = Preferences(defaults: userDefaults)

#if os(macOS)

let appModeManager: AppModeManager = AppModeManager(persistentState: appPersistentState.ui,
                                                    preferences: preferences.viewPreferences)

#endif

fileprivate let playQueue: PlayQueue = PlayQueue()
let playQueueDelegate: PlayQueueDelegateProtocol = PlayQueueDelegate(playQueue: playQueue,
                                                                     persistentState: appPersistentState.playQueue)

let library: Library = Library(persistentState: appPersistentState.library)
let libraryDelegate: LibraryDelegateProtocol = LibraryDelegate()

let playlistsManager: PlaylistsManager = PlaylistsManager(playlists: appPersistentState.playlists?.playlists?.compactMap {Playlist(persistentState: $0)} ?? [])

//    let playlistDelegate: PlaylistDelegateProtocol = PlaylistDelegate(persistentState: appPersistentState.playlist, playlist,
//                                                                           trackReader, preferences)

let audioUnitsManager: AudioUnitsManager = AudioUnitsManager()
fileprivate let audioEngine: AudioEngine = AudioEngine()

let audioGraph: AudioGraph = AudioGraph(audioEngine: audioEngine, audioUnitsManager: audioUnitsManager,
                                                    persistentState: appPersistentState.audioGraph)

var audioGraphDelegate: AudioGraphDelegateProtocol = AudioGraphDelegate(graph: audioGraph, persistentState: appPersistentState.audioGraph,
                                                                        player: playbackDelegate, preferences: preferences.soundPreferences)

let player: PlayerProtocol = Player(graph: audioGraph, avfScheduler: avfScheduler, ffmpegScheduler: ffmpegScheduler)

fileprivate let avfScheduler: PlaybackSchedulerProtocol = AVFScheduler(audioGraph.playerNode)

fileprivate let ffmpegScheduler: PlaybackSchedulerProtocol = FFmpegScheduler(playerNode: audioGraph.playerNode)

let playbackProfiles = PlaybackProfiles(persistentState: appPersistentState.playbackProfiles ?? [])

let playbackDelegate: PlaybackDelegateProtocol = {
    
    let startPlaybackChain = StartPlaybackChain(player, playQueue: playQueue, trackReader: trackReader, playbackProfiles, preferences.playbackPreferences)
    let stopPlaybackChain = StopPlaybackChain(player, playQueue, playbackProfiles, preferences.playbackPreferences)
    let trackPlaybackCompletedChain = TrackPlaybackCompletedChain(startPlaybackChain, stopPlaybackChain, playQueue)
    
    // Playback Delegate
    return PlaybackDelegate(player, playQueue: playQueue, playbackProfiles, preferences.playbackPreferences,
                            startPlaybackChain, stopPlaybackChain, trackPlaybackCompletedChain)
}()

var playbackInfoDelegate: PlaybackInfoDelegateProtocol {playbackDelegate}

var historyDelegate: HistoryDelegateProtocol {_historyDelegate}
fileprivate let _historyDelegate: HistoryDelegate = HistoryDelegate(persistentState: appPersistentState.history, preferences.historyPreferences, playQueueDelegate, playbackDelegate)

var favoritesDelegate: FavoritesDelegateProtocol {_favoritesDelegate}
fileprivate let _favoritesDelegate: FavoritesDelegate = FavoritesDelegate(playQueueDelegate, playbackDelegate)

var bookmarksDelegate: BookmarksDelegateProtocol {_bookmarksDelegate}
fileprivate let _bookmarksDelegate: BookmarksDelegate = BookmarksDelegate(playQueueDelegate, playbackDelegate)

let fileReader: FileReader = FileReader()
let trackReader: TrackReader = TrackReader(fileReader, coverArtReader)

let metadataRegistry: MetadataRegistry = MetadataRegistry(persistentState: nil)

let coverArtReader: CoverArtReader = CoverArtReader(fileCoverArtReader, musicBrainzCoverArtReader)
let fileCoverArtReader: FileCoverArtReader = FileCoverArtReader(fileReader)
let musicBrainzCoverArtReader: MusicBrainzCoverArtReader = MusicBrainzCoverArtReader(preferences: preferences.metadataPreferences.musicBrainz,
                                                                                     cache: musicBrainzCache)

let musicBrainzCache: MusicBrainzCache = MusicBrainzCache(state: appPersistentState.musicBrainzCache,
                                                          preferences: preferences.metadataPreferences.musicBrainz)

// Fast Fourier Transform
let fft: FFT = FFT()

#if os(macOS)

let windowLayoutsManager: WindowLayoutsManager = WindowLayoutsManager(persistentState: appPersistentState.ui?.windowLayout,
                                                                      viewPreferences: preferences.viewPreferences)

let themesManager: ThemesManager = ThemesManager(persistentState: appPersistentState.ui?.themes, fontSchemesManager: fontSchemesManager)

let fontSchemesManager: FontSchemesManager = FontSchemesManager(persistentState: appPersistentState.ui?.fontSchemes)
var systemFontScheme: FontScheme {fontSchemesManager.systemScheme}

let colorSchemesManager: ColorSchemesManager = ColorSchemesManager(persistentState: appPersistentState.ui?.colorSchemes)
let systemColorScheme: ColorScheme = colorSchemesManager.systemScheme

let playerUIState: PlayerUIState = PlayerUIState(persistentState: appPersistentState.ui?.modularPlayer)
let unifiedPlayerUIState: UnifiedPlayerUIState = UnifiedPlayerUIState(persistentState: appPersistentState.ui?.unifiedPlayer)
let compactPlayerUIState: CompactPlayerUIState = .init(persistentState: appPersistentState.ui?.compactPlayer)

let playQueueUIState: PlayQueueUIState = PlayQueueUIState(persistentState: appPersistentState.ui?.playQueue)
let playlistsUIState: PlaylistsUIState = PlaylistsUIState()
let menuBarPlayerUIState: MenuBarPlayerUIState = MenuBarPlayerUIState(persistentState: appPersistentState.ui?.menuBarPlayer)
let widgetPlayerUIState: WidgetPlayerUIState = WidgetPlayerUIState(persistentState: appPersistentState.ui?.widgetPlayer)
let visualizerUIState: VisualizerUIState = VisualizerUIState(persistentState: appPersistentState.ui?.visualizer)
let windowAppearanceState: WindowAppearanceState = WindowAppearanceState(persistentState: appPersistentState.ui?.windowAppearance)
let tuneBrowserUIState: TuneBrowserUIState = TuneBrowserUIState(persistentState: appPersistentState.ui?.tuneBrowser)

let mediaKeyHandler: MediaKeyHandler = MediaKeyHandler(preferences.controlsPreferences.mediaKeys)

let libraryMonitor: LibraryMonitor = .init(libraryPersistentState: appPersistentState.library)

#endif

let remoteControlManager: RemoteControlManager = RemoteControlManager(playbackInfo: playbackInfoDelegate, playQueue: playQueueDelegate, audioGraph: audioGraphDelegate,
                                                                      preferences: preferences)

var persistentStateOnExit: AppPersistentState {
    
    // Gather all pieces of persistent state into the persistentState object
    var persistentState: AppPersistentState = AppPersistentState()
    
    persistentState.appVersion = appVersion
    
    persistentState.audioGraph = audioGraph.persistentState
    persistentState.playQueue = playQueue.persistentState
    persistentState.library = library.persistentState
    persistentState.playlists = playlistsManager.persistentState
//    persistentState.metadata = metadataRegistry.persistentState
    persistentState.playbackProfiles = playbackDelegate.profiles.all().map {PlaybackProfilePersistentState(profile: $0)}
    
#if os(macOS)
    
    persistentState.ui = UIPersistentState(appMode: appModeManager.currentMode,
                                           windowLayout: windowLayoutsManager.persistentState,
                                           themes: themesManager.persistentState,
                                           fontSchemes: fontSchemesManager.persistentState,
                                           colorSchemes: colorSchemesManager.persistentState,
                                           windowAppearance: windowAppearanceState.persistentState,
                                           
                                           modularPlayer: playerUIState.persistentState,
                                           unifiedPlayer: unifiedPlayerUIState.persistentState,
                                           menuBarPlayer: menuBarPlayerUIState.persistentState,
                                           widgetPlayer: widgetPlayerUIState.persistentState,
                                           compactPlayer: compactPlayerUIState.persistentState,
                                           
                                           playQueue: playQueueUIState.persistentState,
                                           visualizer: visualizerUIState.persistentState,
                                           tuneBrowser: tuneBrowserUIState.persistentState)
    
#endif
    
    persistentState.history = _historyDelegate.persistentState
    persistentState.favorites = _favoritesDelegate.persistentState
    persistentState.bookmarks = _bookmarksDelegate.persistentState
    persistentState.musicBrainzCache = musicBrainzCoverArtReader.cache.persistentState
    
    return persistentState
}
