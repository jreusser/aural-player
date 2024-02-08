//
//  UnifiedPlayerSidebarItems.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
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
            
        case .playQueue, .favorites, .bookmarks:
            
            return 0
        }
    }
    
    var items: [UnifiedPlayerSidebarItem] {
        
        switch self {
            
        case .library:
            
            return Self.libraryItems
            
        case .tuneBrowser:
            
            return libraryDelegate.fileSystemTrees.map {tree in
                
                let rootFolder = tree.root
                return UnifiedPlayerSidebarItem(displayName: rootFolder.name, browserTab: .fileSystem, tuneBrowserFolder: rootFolder, tuneBrowserTree: tree)
            }
            
            // TODO: Also add in the user folders from persistent TB state
            //            tuneBrowserUIState.sidebarUserFolders.values.map {
            //                LibrarySidebarItem(displayName: $0.url.lastPathComponent, browserTab: .fileSystem, tuneBrowserURL: $0.url)
            
        case .playlists:
            
            return playlistsManager.playlistNames.map {UnifiedPlayerSidebarItem(displayName: $0, browserTab: .playlists)}
            
        case .history:
            
            return Self.historyItems
            
        case .playQueue, .favorites, .bookmarks:
            
            return []
        }
    }
    
    var image: PlatformImage {
        
        switch self {
            
        case .playQueue:
            
            return .imgPlayQueue
            
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

// TODO: Consolidate this struct with 'LibrarySidebarItem'
struct UnifiedPlayerSidebarItem {
    
    let displayName: String
    let browserTab: UnifiedPlayerBrowserTab
    let image: PlatformImage?
    
    let tuneBrowserFolder: FileSystemFolderItem?
    let tuneBrowserTree: FileSystemTree?
    
    init(displayName: String, browserTab: UnifiedPlayerBrowserTab, tuneBrowserFolder: FileSystemFolderItem? = nil, tuneBrowserTree: FileSystemTree? = nil, image: PlatformImage? = nil) {
        
        self.displayName = displayName
        self.browserTab = browserTab
        
        self.tuneBrowserFolder = tuneBrowserFolder
        self.tuneBrowserTree = tuneBrowserTree
        
        self.image = image
    }
}

enum UnifiedPlayerBrowserTab: Int {
    
    case playQueue = 0,
         libraryTracks = 1,
         libraryArtists = 2,
         libraryAlbums = 3,
         libraryGenres = 4,
         libraryDecades = 5,
         fileSystem = 6,
         playlists = 7,
         historyRecentlyPlayed = 8,
         historyMostPlayed = 9,
         historyRecentlyAdded = 10,
         favorites = 11,
         bookmarks = 12
}
