//
//  Globals.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

#if os(macOS)

import AppKit
let appVersion: String = NSApp.appVersion

#endif

let persistenceManager: PersistenceManager = PersistenceManager(persistentStateFile: FilesAndPaths.persistentStateFile)
let persistentState: AppPersistentState = persistenceManager.load(type: AppPersistentState.self) ?? .defaults

let preferences: Preferences = Preferences(defaults: .standard)

#if os(macOS)

let appModeManager: AppModeManager = AppModeManager(persistentState: persistentState.ui,
                                                    preferences: preferences.viewPreferences)

#endif

fileprivate let playQueue: PlayQueue = PlayQueue()

let library: Library = Library()
let libraryDelegate: LibraryDelegateProtocol = LibraryDelegate(persistentState: persistentState.library)

let playlistsManager: PlaylistsManager = PlaylistsManager(playlists: persistentState.playlists?.playlists?.compactMap {Playlist(persistentState: $0)} ?? [])

//    let playlistDelegate: PlaylistDelegateProtocol = PlaylistDelegate(persistentState: persistentState.playlist, playlist,
//                                                                           trackReader, preferences)

let playQueueDelegate: PlayQueueDelegateProtocol = PlayQueueDelegate(playQueue: playQueue,
                                                                     persistentState: persistentState.playQueue)

let audioUnitsManager: AudioUnitsManager = AudioUnitsManager()
fileprivate let audioEngine: AudioEngine = AudioEngine()

let audioGraph: AudioGraph = AudioGraph(audioEngine: audioEngine, audioUnitsManager: audioUnitsManager,
                                                    persistentState: persistentState.audioGraph)

var audioGraphDelegate: AudioGraphDelegateProtocol = AudioGraphDelegate(graph: audioGraph, persistentState: persistentState.audioGraph,
                                                                        player: playbackDelegate, preferences: preferences.soundPreferences)

let player: PlayerProtocol = Player(graph: audioGraph, avfScheduler: avfScheduler, ffmpegScheduler: ffmpegScheduler)

fileprivate let avfScheduler: PlaybackSchedulerProtocol = AVFScheduler(audioGraph.playerNode)

fileprivate let ffmpegScheduler: PlaybackSchedulerProtocol = FFmpegScheduler(playerNode: audioGraph.playerNode)

let playbackDelegate: PlaybackDelegateProtocol = {
    
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
fileprivate let _historyDelegate: HistoryDelegate = HistoryDelegate(persistentState: persistentState.history, preferences.historyPreferences, playQueueDelegate, playbackDelegate)

var favoritesDelegate: FavoritesDelegateProtocol {_favoritesDelegate}
fileprivate let _favoritesDelegate: FavoritesDelegate = FavoritesDelegate(persistentState: persistentState.favorites, playQueueDelegate,
                                                                          playbackDelegate)

var bookmarksDelegate: BookmarksDelegateProtocol {_bookmarksDelegate}
fileprivate let _bookmarksDelegate: BookmarksDelegate = BookmarksDelegate(persistentState: persistentState.bookmarks, playQueueDelegate,
                                                                          playbackDelegate)

let fileReader: FileReader = FileReader()
let trackReader: TrackReader = TrackReader(fileReader, coverArtReader)

let metadataRegistry: MetadataRegistry = MetadataRegistry(persistentState: persistentState.metadata)

let coverArtReader: CoverArtReader = CoverArtReader(fileCoverArtReader, musicBrainzCoverArtReader)
let fileCoverArtReader: FileCoverArtReader = FileCoverArtReader(fileReader)
let musicBrainzCoverArtReader: MusicBrainzCoverArtReader = MusicBrainzCoverArtReader(preferences: preferences.metadataPreferences.musicBrainz,
                                                                                     cache: musicBrainzCache)

let musicBrainzCache: MusicBrainzCache = MusicBrainzCache(state: persistentState.musicBrainzCache,
                                                          preferences: preferences.metadataPreferences.musicBrainz)

#if os(macOS)

let windowLayoutsManager: WindowLayoutsManager = WindowLayoutsManager(persistentState: persistentState.ui?.windowLayout,
                                                                      viewPreferences: preferences.viewPreferences)

let themesManager: ThemesManager = ThemesManager(persistentState: persistentState.ui?.themes, fontSchemesManager: fontSchemesManager)

let fontSchemesManager: FontSchemesManager = FontSchemesManager(persistentState: persistentState.ui?.fontSchemes)
var systemFontScheme: FontScheme {fontSchemesManager.systemScheme}

let colorSchemesManager: ColorSchemesManager = ColorSchemesManager(persistentState: persistentState.ui?.colorSchemes)
let systemColorScheme: ColorScheme = colorSchemesManager.systemScheme

let playerUIState: PlayerUIState = PlayerUIState(persistentState: persistentState.ui?.player)
let playQueueUIState: PlayQueueUIState = PlayQueueUIState(persistentState: persistentState.ui?.playQueue)
let playlistsUIState: PlaylistsUIState = PlaylistsUIState()
let menuBarPlayerUIState: MenuBarPlayerUIState = MenuBarPlayerUIState(persistentState: persistentState.ui?.menuBarPlayer)
let controlBarPlayerUIState: ControlBarPlayerUIState = ControlBarPlayerUIState(persistentState: persistentState.ui?.controlBarPlayer)
let visualizerUIState: VisualizerUIState = VisualizerUIState(persistentState: persistentState.ui?.visualizer)
let windowAppearanceState: WindowAppearanceState = WindowAppearanceState(persistentState: persistentState.ui?.windowAppearance)
let tuneBrowserUIState: TuneBrowserUIState = TuneBrowserUIState(persistentState: persistentState.ui?.tuneBrowser)

let mediaKeyHandler: MediaKeyHandler = MediaKeyHandler(preferences.controlsPreferences.mediaKeys)

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
    persistentState.metadata = metadataRegistry.persistentState
    persistentState.playbackProfiles = playbackDelegate.profiles.all().map {PlaybackProfilePersistentState(profile: $0)}
    
#if os(macOS)
    
    persistentState.ui = UIPersistentState(appMode: appModeManager.currentMode,
                                           player: playerUIState.persistentState,
                                           playQueue: playQueueUIState.persistentState,
                                           windowLayout: windowLayoutsManager.persistentState,
                                           themes: themesManager.persistentState,
                                           fontSchemes: fontSchemesManager.persistentState,
                                           colorSchemes: colorSchemesManager.persistentState,
                                           //                                               playlists: playlistUIState.persistentState,
                                           visualizer: visualizerUIState.persistentState,
                                           windowAppearance: windowAppearanceState.persistentState,
                                           tuneBrowser: tuneBrowserUIState.persistentState,
                                           menuBarPlayer: menuBarPlayerUIState.persistentState,
                                           controlBarPlayer: controlBarPlayerUIState.persistentState)
    
#endif
    
    persistentState.history = _historyDelegate.persistentState
    persistentState.favorites = _favoritesDelegate.persistentState
    persistentState.bookmarks = _bookmarksDelegate.persistentState
    persistentState.musicBrainzCache = musicBrainzCoverArtReader.cache.persistentState
    
    return persistentState
}
