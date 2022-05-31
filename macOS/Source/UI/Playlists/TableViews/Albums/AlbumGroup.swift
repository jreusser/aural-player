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
    
    override var groupType: String {
        "album"
    }
    
    private static let albumArtFileName: String = "AlbumArtSmall.jpg"
    private static let folderArtFileName: String = "Folder.jpg"
    
    var theTracks: [Track] {
        hasTracks ? tracks : subGroups.values.flatMap {$0.tracks}
    }
    
    private lazy var artists: Set<String> = {
        Set(theTracks.compactMap {$0.artist})
    }()
    
    private lazy var genres: Set<String> = {
        Set(theTracks.compactMap {$0.genre})
    }()
    
    private lazy var years: Set<Int> = {
        Set(theTracks.compactMap {$0.year})
    }()
    
    private lazy var discNumbers: Set<Int> = {
        Set(theTracks.compactMap {$0.discNumber})
    }()
    
    private lazy var totalDiscsCounts: Set<Int> = {
        Set(theTracks.compactMap {$0.totalDiscs})
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
    
    // TODO: Make these lazily computed and updated (invalidated) when tracks are added / removed, so
    // that they're more efficient, not re-computed every single time.
    
    var yearString: String? {
        
        guard let firstYear = years.first else {return nil}
        
        if years.count == 1 {
            return "\(firstYear)"
        }
        
        let sortedYears = years.sorted(by: <)
        return "\(sortedYears.min()!) - \(sortedYears.max()!)"
    }
    
    var discCount: Int {
        discNumbers.count
    }
    
    var totalDiscs: Int? {
        
        if totalDiscsCounts.isEmpty {return nil}
        
        if totalDiscsCounts.count == 1 {
            return totalDiscsCounts.first
        }
        
        // Maximum of all total discs counts.
        return totalDiscsCounts.sorted(by: >).first
    }
    
    var hasMoreThanOneTotalDisc: Bool {
        
        if let totalDiscs = self.totalDiscs {
            return totalDiscs > 1
        }

        return false
    }
    
    var art: NSImage {
        
        var parentFolders: Set<URL> = Set()
        
        for track in theTracks {
            parentFolders.insert(track.file.parentDir)
        }
        
        // 1 - Check for an image file in the album folder.
        
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
        
        // 2 - Check for an image file in any of the tracks.
        
        for track in theTracks {
            
            if let art = track.art?.image {
                return art
            }
        }

        // 3 - Default icon for an album.
        return .imgAlbumGroup
    }
    
    override func doCreateSubGroup(named groupName: String) -> Group {
        AlbumDiscGroup(name: groupName, depth: self.depth + 1)
    }
}

class AlbumDiscGroup: Group {
}
