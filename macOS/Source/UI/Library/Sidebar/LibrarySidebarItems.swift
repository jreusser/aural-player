//
//  SidebarItems.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import Foundation

enum LibrarySidebarCategory: String, CaseIterable, CustomStringConvertible {
    
    private static let libraryItems: [LibrarySidebarItem] = [
        
        LibrarySidebarItem(displayName: "Tracks", browserTab: .libraryTracks, image: .imgTracks),
        LibrarySidebarItem(displayName: "Artists", browserTab: .libraryArtists, image: .imgArtistGroup),
        LibrarySidebarItem(displayName: "Albums", browserTab: .libraryAlbums, image: .imgAlbumGroup),
        LibrarySidebarItem(displayName: "Genres", browserTab: .libraryGenres, image: .imgGenreGroup),
        LibrarySidebarItem(displayName: "Decades", browserTab: .libraryDecades, image: .imgDecadeGroup),
    ]
    
    private static let historyItems: [LibrarySidebarItem] = [
        
        LibrarySidebarItem(displayName: "Recently Played", browserTab: .historyRecentlyPlayed),
        LibrarySidebarItem(displayName: "Most Played", browserTab: .historyMostPlayed),
        LibrarySidebarItem(displayName: "Recently Added", browserTab: .historyRecentlyAdded)
    ]
    
    case library = "Library"
    case tuneBrowser = "File System"
    case playlists = "Playlists"
    case history = "History"
    case favorites = "Favorites"
    case bookmarks = "Bookmarks"
    
    var browserTab: LibraryBrowserTab {
        
        switch self {
            
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
            
        case .favorites, .bookmarks:
            
            return 0
        }
    }
    
    var items: [LibrarySidebarItem] {
        
        switch self {
            
        case .library:
            
            return Self.libraryItems
            
        case .tuneBrowser:
            
            return [LibrarySidebarItem(displayName: "My Music", browserTab: .fileSystem, tuneBrowserURL: FilesAndPaths.musicDir)] +
            tuneBrowserUIState.sidebarUserFolders.values.map {
                LibrarySidebarItem(displayName: $0.url.lastPathComponent, browserTab: .fileSystem, tuneBrowserURL: $0.url)
            }
            
        case .playlists:
            
            return playlistsManager.playlistNames.map {LibrarySidebarItem(displayName: $0, browserTab: .playlists)}
            
        case .history:
            
            return Self.historyItems
            
        case .favorites:
            
            return []
            
        case .bookmarks:
            
            return []
        }
    }
    
    var image: PlatformImage {
        
        switch self {
            
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

struct LibrarySidebarItem {
    
    let displayName: String
    let browserTab: LibraryBrowserTab
    let image: PlatformImage?
    let tuneBrowserURL: URL?
    
    init(displayName: String, browserTab: LibraryBrowserTab, tuneBrowserURL: URL? = nil, image: PlatformImage? = nil) {
        
        self.displayName = displayName
        self.browserTab = browserTab
        self.tuneBrowserURL = tuneBrowserURL
        self.image = image
    }
}

enum LibraryBrowserTab: Int {
    
    case libraryTracks = 0,
         libraryArtists = 1,
         libraryAlbums = 2,
         libraryGenres = 3,
         libraryDecades = 4,
         fileSystem = 5,
         playlists = 6,
         historyRecentlyPlayed = 7,
         historyMostPlayed = 8,
         historyRecentlyAdded = 9,
         favorites = 10,
         bookmarks = 11
}
