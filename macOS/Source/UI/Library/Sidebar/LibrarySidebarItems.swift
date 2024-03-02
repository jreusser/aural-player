//
//  SidebarItems.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
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
        LibrarySidebarItem(displayName: "Playlist Files", browserTab: .libraryImportedPlaylists, image: .imgPlaylist)
    ]
    
    private static let favoritesItems: [LibrarySidebarItem] = [
        
        LibrarySidebarItem(displayName: "Tracks", browserTab: .favoritesTracks, image: .imgTracks),
        LibrarySidebarItem(displayName: "Artists", browserTab: .favoritesArtists, image: .imgArtistGroup),
        LibrarySidebarItem(displayName: "Albums", browserTab: .favoritesAlbums, image: .imgAlbumGroup),
        LibrarySidebarItem(displayName: "Genres", browserTab: .favoritesGenres, image: .imgGenreGroup),
        LibrarySidebarItem(displayName: "Decades", browserTab: .favoritesDecades, image: .imgDecadeGroup),
        LibrarySidebarItem(displayName: "Playlist Files", browserTab: .favoritesImportedPlaylists, image: .imgPlaylist),
        LibrarySidebarItem(displayName: "Playlists", browserTab: .favoritesPlaylists, image: .imgPlaylist)
    ]
    
    case library = "Library"
    case tuneBrowser = "File System"
    case playlists = "Playlists"
    case favorites = "Favorites"
    
    var description: String {rawValue}
    
    var numberOfItems: Int {
        
        switch self {
            
        case .library:
            
            return Self.libraryItems.count
            
        case .tuneBrowser:
            
            return libraryDelegate.fileSystemTrees.count + tuneBrowserUIState.sidebarUserFolders.count
            
        case .playlists:
            
            return playlistsManager.numberOfUserDefinedObjects
            
        case .favorites:
            
            return Self.favoritesItems.count
        }
    }
    
    var items: [LibrarySidebarItem] {
        
        switch self {
            
        case .library:
            
            return Self.libraryItems
            
        case .tuneBrowser:
            
            return libraryDelegate.fileSystemTrees.map {tree in
                
                let rootFolder = tree.root
                return LibrarySidebarItem(displayName: rootFolder.name, browserTab: .fileSystem, tuneBrowserFolder: rootFolder, tuneBrowserTree: tree)
                
            } + tuneBrowserUIState.sidebarUserFolders.map {
                LibrarySidebarItem(displayName: $0.folder.name, browserTab: .fileSystem, tuneBrowserFolder: $0.folder, tuneBrowserTree: $0.tree)
            }
            
        case .playlists:
            
            return playlistsManager.userDefinedObjects.map {
                LibrarySidebarItem(displayName: $0.name, browserTab: .playlists)
            }
            
        case .favorites:
            
            return Self.favoritesItems
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
            
        case .favorites:
            
            return .imgFavorite
        }
    }
}

class LibrarySidebarItem: Equatable {
    
    var displayName: String
    let browserTab: LibraryBrowserTab
    let image: PlatformImage?
    
    let tuneBrowserFolder: FileSystemFolderItem?
    let tuneBrowserTree: FileSystemTree?
    
    init(displayName: String, browserTab: LibraryBrowserTab, tuneBrowserFolder: FileSystemFolderItem? = nil, tuneBrowserTree: FileSystemTree? = nil, image: PlatformImage? = nil) {
        
        self.displayName = displayName
        self.browserTab = browserTab
        
        self.tuneBrowserFolder = tuneBrowserFolder
        self.tuneBrowserTree = tuneBrowserTree
        
        self.image = image
    }
    
    static func == (lhs: LibrarySidebarItem, rhs: LibrarySidebarItem) -> Bool {
        
        if lhs.browserTab != rhs.browserTab {
            return false
        }
        
        if lhs.browserTab != .fileSystem {
            return true
        }
        
        // Same folder implies same tree
        return lhs.tuneBrowserFolder == rhs.tuneBrowserFolder
    }
}

enum LibraryBrowserTab: Int {
    
    case libraryTracks = 0,
         libraryArtists = 1,
         libraryAlbums = 2,
         libraryGenres = 3,
         libraryDecades = 4,
         libraryImportedPlaylists = 5,
         fileSystem = 6,
         playlists = 7,
         favoritesTracks = 8,
         favoritesArtists = 9,
         favoritesAlbums = 10,
         favoritesGenres = 11,
         favoritesDecades = 12,
         favoritesImportedPlaylists = 13,
         favoritesPlaylists = 14
}
