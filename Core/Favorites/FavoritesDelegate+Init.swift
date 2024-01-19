//
//  FavoritesDelegate+Init.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import Foundation

extension FavoritesDelegate {
    
    func initialize(fromPersistentState persistentState: FavoritesPersistentState?) {
        
        guard let state = persistentState else {return}
        
        DispatchQueue.global(qos: .utility).async {
            
            for favTrack in state.favoriteTracks ?? [] {
                
                guard let trackFile = favTrack.trackFile else {continue}
                
                let track = Track(trackFile)
                self.favoriteTracks[trackFile] = FavoriteTrack(track: track)
                
                TrackLoader.mediumPriorityQueue.addOperation {
                    
                    do {
                        
                        let metadata = try fileReader.getPrimaryMetadata(for: trackFile)
                        track.setPrimaryMetadata(from: FileMetadata(primary: metadata))
                        
                    } catch {
                        NSLog("Failed to read track metadata for file: '\(trackFile.path)'")
                    }
                }
            }
            
            for favArtist in state.favoriteArtists?.compactMap({$0.groupName}) ?? [] {
                self.favoriteArtists[favArtist] = FavoriteGroup(groupName: favArtist, groupType: .artist)
            }
            
            for favAlbum in state.favoriteAlbums?.compactMap({$0.groupName}) ?? [] {
                self.favoriteAlbums[favAlbum] = FavoriteGroup(groupName: favAlbum, groupType: .album)
            }
            
            for favGenre in state.favoriteGenres?.compactMap({$0.groupName}) ?? [] {
                self.favoriteGenres[favGenre] = FavoriteGroup(groupName: favGenre, groupType: .genre)
            }
            
            for favDecade in state.favoriteDecades?.compactMap({$0.groupName}) ?? [] {
                self.favoriteDecades[favDecade] = FavoriteGroup(groupName: favDecade, groupType: .decade)
            }
        }
    }
}
