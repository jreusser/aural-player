//
//  FavoritesDelegateProtocol.swift
//  Aural
//
//  Copyright © 2023 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Foundation

///
/// A functional contract for a delegate allowing access to the list of user-defined favorites.
///
/// Acts as a middleman between the UI and the Favorites list,
/// providing a simplified interface / facade for the UI layer to manipulate the Favorites list.
///
/// - SeeAlso: `Favorite`
///
protocol FavoritesDelegateProtocol {
    
    func addFavorite(track: Track)
    
    func addFavorite(artist: String)

    func addFavorite(album: String)

    func addFavorite(genre: String)
    
    func addFavorite(decade: String)
    
//    func addFavorite(playlist: Playlist) -> Favorite
//    
//    func addFavorite(playlistFile: ImportedPlaylist) -> Favorite
    
    var allFavoriteTracks: [FavoriteTrack] {get}
    
    var allFavoriteArtists: [FavoriteGroup] {get}
    
    var allFavoriteAlbums: [FavoriteGroup] {get}
    
    var allFavoriteGenres: [FavoriteGroup] {get}
    
    var allFavoriteDecades: [FavoriteGroup] {get}
    
    func favoriteExists(track: Track) -> Bool
    
    func favoriteExists(artist: String) -> Bool
    
    func favoriteExists(album: String) -> Bool
    
    func favoriteExists(genre: String) -> Bool
    
    func favoriteExists(decade: String) -> Bool
    
    func playFavorite(_ favorite: Favorite)
}
