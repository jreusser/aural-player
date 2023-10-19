//
//  UnifiedPlayerSidebarItems.swift
//  Aural
//
//  Copyright © 2023 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import Foundation

enum UnifiedPlayerSidebarCategory: String, CaseIterable, CustomStringConvertible {
    
    private static let libraryItems: [UnifiedPlayerSidebarItem] = [
        
        UnifiedPlayerSidebarItem(displayName: "Tracks", browserTab: .libraryTracks, image: .imgTracks),
        UnifiedPlayerSidebarItem(displayName: "Artists", browserTab: .libraryArtists, image: .imgArtistGroup),
        UnifiedPlayerSidebarItem(displayName: "Albums", browserTab: .libraryAlbums, image: .imgAlbumGroup),
        UnifiedPlayerSidebarItem(displayName: "Genres", browserTab: .libraryGenres, image: .imgGenreGroup),
        UnifiedPlayerSidebarItem(displayName: "Decades", browserTab: .libraryDecades, image: .imgDecadeGroup),
    ]
    
    private static let historyItems: [UnifiedPlayerSidebarItem] = [
        
        UnifiedPlayerSidebarItem(displayName: "Recently Played", browserTab: .historyRecentlyPlayed),
        UnifiedPlayerSidebarItem(displayName: "Most Played", browserTab: .historyMostPlayed),
        UnifiedPlayerSidebarItem(displayName: "Recently Added", browserTab: .historyRecentlyAdded)
    ]
    
    case playQueue = "Play Queue"
    case effects = "Effects"
    case library = "Library"
    case tuneBrowser = "File System"
    case playlists = "Playlists"
    case history = "History"
    case favorites = "Favorites"
    case bookmarks = "Bookmarks"
    
    var browserTab: UnifiedPlayerBrowserTab {
        
        switch self {
            
        case .playQueue:
            
            return .playQueue
            
        case .effects:
            
            return .effects
            
        case .favorites:
            
            return .favorites
            
        case .bookmarks:
            
            return .favorites
            
        default:
            
            return .libraryTracks
        }
    }
    
    var description: String {rawValue}
    
    var numberOfItems: Int {
        
        switch self {
            
        case .library:
            
            return Self.libraryItems.count
            
        case .tuneBrowser:
            
            return tuneBrowserUIState.sidebarUserFolders.count + 1
            
        case .playlists:
            
            return playlistsManager.numberOfUserDefinedObjects
            
        case .history:
            
            return Self.historyItems.count
            
        case .playQueue, .effects, .favorites, .bookmarks:
            
            return 0
        }
    }
    
    var items: [UnifiedPlayerSidebarItem] {
        
        switch self {
            
        case .library:
            
            return Self.libraryItems
            
        case .tuneBrowser:
            
            return [UnifiedPlayerSidebarItem(displayName: "My Music", browserTab: .fileSystem, tuneBrowserURL: FilesAndPaths.musicDir)] +
            tuneBrowserUIState.sidebarUserFolders.values.map {
                UnifiedPlayerSidebarItem(displayName: $0.url.lastPathComponent, browserTab: .fileSystem, tuneBrowserURL: $0.url)
            }
            
        case .playlists:
            
            return playlistsManager.playlistNames.map {UnifiedPlayerSidebarItem(displayName: $0, browserTab: .playlists)}
            
        case .history:
            
            return Self.historyItems
            
        case .playQueue, .effects, .favorites, .bookmarks:
            
            return []
        }
    }
    
    var image: PlatformImage {
        
        switch self {
            
        case .playQueue:
            
            return .imgPlayQueue
            
        case .effects:
            
            return .imgEffects
            
        case .library:
            
            return .imgLibrary
            
        case .tuneBrowser:
            
            return .imgFileSystem
            
        case .playlists:
            
            return .imgPlaylist
            
        case .history:
            
            return .imgHistory
            
        case .favorites:
            
            return .imgFavorite
            
        case .bookmarks:
            
            return .imgBookmark
        }
    }
}

struct UnifiedPlayerSidebarItem {
    
    let displayName: String
    let browserTab: UnifiedPlayerBrowserTab
    let image: PlatformImage?
    let tuneBrowserURL: URL?
    
    init(displayName: String, browserTab: UnifiedPlayerBrowserTab, tuneBrowserURL: URL? = nil, image: PlatformImage? = nil) {
        
        self.displayName = displayName
        self.browserTab = browserTab
        self.tuneBrowserURL = tuneBrowserURL
        self.image = image
    }
}

enum UnifiedPlayerBrowserTab: Int {
    
    case playQueue = 0,
         effects = 1,
         libraryTracks = 2,
         libraryArtists = 3,
         libraryAlbums = 4,
         libraryGenres = 5,
         libraryDecades = 6,
         fileSystem = 7,
         playlists = 8,
         historyRecentlyPlayed = 9,
         historyMostPlayed = 10,
         historyRecentlyAdded = 11,
         favorites = 12,
         bookmarks = 13
}
