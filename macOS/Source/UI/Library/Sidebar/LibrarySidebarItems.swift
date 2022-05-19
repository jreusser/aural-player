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
    
    private static let libraryItems: [LibrarySidebarItem] = ["Tracks", "Artists", "Albums", "Genres", "Decades"].map {LibrarySidebarItem(displayName: $0)}
    private static let historyItems: [LibrarySidebarItem] = ["Recently Played", "Most Played", "Recently Added"].map {LibrarySidebarItem(displayName: $0)}
    private static let playlistsItems: [LibrarySidebarItem] = ["Biosphere Tranquility", "Nature Sounds"].map {LibrarySidebarItem(displayName: $0)}
    
    case library = "Library"
    case fileSystem = "File System"
    case playlists = "Playlists"
    case history = "History"
    case favorites = "Favorites"
    case bookmarks = "Bookmarks"
    
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
            return [LibrarySidebarItem(displayName: "My Music")]
            
        case .playlists:
            
            return playlistsManager.playlistNames.map {LibrarySidebarItem(displayName: $0)}
            
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
}
