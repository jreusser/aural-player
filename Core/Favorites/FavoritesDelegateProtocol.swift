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
    
    func initialize(fromPersistentState persistentState: FavoritesPersistentState?)
    
    func addFavorite(track: Track)
    
    func addFavorite(artist: String)

    func addFavorite(album: String)

    func addFavorite(genre: String)
    
    func addFavorite(decade: String)
    
//    func addFavorite(playlist: Playlist)
//    
//    func addFavorite(playlistFile: ImportedPlaylist)
    
    func removeFavorite(track: Track)
    
    func removeFavorite(artist: String)

    func removeFavorite(album: String)

    func removeFavorite(genre: String)
    
    func removeFavorite(decade: String)
    
//    func removeFavorite(playlist: Playlist)
//
//    func removeFavorite(playlistFile: ImportedPlaylist)
    
    var hasAnyFavorites: Bool {get}
    
    var allFavoriteTracks: [FavoriteTrack] {get}
    var numberOfFavoriteTracks: Int {get}
    
    var artistsFromFavoriteTracks: Set<String> {get}
    var albumsFromFavoriteTracks: Set<String> {get}
    var genresFromFavoriteTracks: Set<String> {get}
    var decadesFromFavoriteTracks: Set<String> {get}
    
    var allFavoriteArtists: [FavoriteGroup] {get}
    var numberOfFavoriteArtists: Int {get}
    
    var allFavoriteAlbums: [FavoriteGroup] {get}
    var numberOfFavoriteAlbums: Int {get}
    
    var allFavoriteGenres: [FavoriteGroup] {get}
    var numberOfFavoriteGenres: Int {get}
    
    var allFavoriteDecades: [FavoriteGroup] {get}
    var numberOfFavoriteDecades: Int {get}
    
    func favoriteExists(track: Track) -> Bool
    
    func favoriteExists(artist: String) -> Bool
    
    func favoriteExists(album: String) -> Bool
    
    func favoriteExists(genre: String) -> Bool
    
    func favoriteExists(decade: String) -> Bool
    
    func playFavorite(_ favorite: Favorite)
}
