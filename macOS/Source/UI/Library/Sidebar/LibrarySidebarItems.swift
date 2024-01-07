//
//  SidebarItems.swift
//  Aural
//
//  Copyright © 2023 Kartik Venugopal. All rights reserved.
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
    
    case library = "Library"
    case tuneBrowser = "File System"
    
    var browserTab: LibraryBrowserTab {
        return .libraryTracks
    }
    
    var description: String {rawValue}
    
    var numberOfItems: Int {
        
        switch self {
            
        case .library:
            
            return Self.libraryItems.count
            
        case .tuneBrowser:
            
            return tuneBrowserUIState.sidebarUserFolders.count + 1
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
        }
    }
    
    var image: PlatformImage {
        
        switch self {
            
        case .library:
            
            return .imgLibrary
            
        case .tuneBrowser:
            
            return .imgFileSystem
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
         libraryImportedPlaylists = 5,
         fileSystem = 6
}
