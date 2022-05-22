//
//  AlbumGroup.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import Cocoa

class AlbumGroup: Group {
    
    private static let albumArtFileName: String = "AlbumArtSmall.jpg"
    private static let folderArtFileName: String = "Folder.jpg"
    
    private lazy var artists: Set<String> = {
        Set(tracks.compactMap {$0.artist})
    }()
    
    private lazy var genres: Set<String> =  {
        Set(tracks.compactMap {$0.genre})
    }()
    
    private lazy var years: Set<Int> =  {
        Set(tracks.compactMap {$0.year})
    }()
    
    var artistsString: String? {
        uniqueOrJoinedString(artists)
    }
    
    var genresString: String? {
        uniqueOrJoinedString(genres)
    }
    
    private func uniqueOrJoinedString(_ strings: Set<String>) -> String? {
        
        guard let firstString = strings.first else {return nil}
        
        if strings.count == 1 {
            return firstString
            
        } else {
            return strings.joined(separator: " / ")
        }
    }
    
    var yearString: String? {
        
        guard let firstYear = years.first else {return nil}
        
        if years.count == 1 {
            return "\(firstYear)"
        }
        
        let sortedYears = years.sorted(by: <)
        return "\(sortedYears.min()!) - \(sortedYears.max()!)"
    }
    
    var art: NSImage {
        
        var parentFolders: Set<URL> = Set()
        
        for track in tracks {
            parentFolders.insert(track.file.parentDir)
        }
        
        for parentDir in parentFolders {
            
            let albumArtFile = parentDir.appendingPathComponent(Self.albumArtFileName, isDirectory: false)
            
            if albumArtFile.exists, let image = NSImage(contentsOf: albumArtFile) {
                return image
            }
            
            let folderArtFile = parentDir.appendingPathComponent(Self.folderArtFileName, isDirectory: false)
            
            if folderArtFile.exists, let image = NSImage(contentsOf: folderArtFile) {
                return image
            }
        }
        
        return .imgAlbumGroup
    }
}
