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
        
        LibrarySidebarItem(displayName: "Tracks", browserTab: .libraryTracks),
        LibrarySidebarItem(displayName: "Artists", browserTab: .libraryArtists),
        LibrarySidebarItem(displayName: "Albums", browserTab: .libraryAlbums),
        LibrarySidebarItem(displayName: "Genres", browserTab: .libraryGenres),
        LibrarySidebarItem(displayName: "Decades", browserTab: .libraryDecades),
    ]
    
    private static let historyItems: [LibrarySidebarItem] = [
        
        LibrarySidebarItem(displayName: "Recently Played", browserTab: .historyRecentlyPlayed),
        LibrarySidebarItem(displayName: "Most Played", browserTab: .historyMostPlayed),
        LibrarySidebarItem(displayName: "Recently Added", browserTab: .historyRecentlyAdded)
    ]
    
    case library = "Library"
    case fileSystem = "File System"
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
            
        case .fileSystem:
            
            // TODO:
            return 1
            
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
            
        case .fileSystem:
            
            // TODO:
            return [LibrarySidebarItem(displayName: "My Music", browserTab: .fileSystem)]
            
        case .playlists:
            
            return playlistsManager.playlistNames.map {LibrarySidebarItem(displayName: $0, browserTab: .playlist)}
            
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
            
        case .fileSystem:
            
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
}

enum LibraryBrowserTab: Int {
    
    case libraryTracks = 0,
         libraryArtists = 1,
         libraryAlbums = 2,
         libraryGenres = 3,
         libraryDecades = 4,
         playlist = 5,
         fileSystem = 6,
         historyRecentlyPlayed = 7,
         historyMostPlayed = 8,
         historyRecentlyAdded = 9,
         favorites = 10,
         bookmarks = 11
}
