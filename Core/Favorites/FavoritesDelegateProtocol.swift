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
    
    @discardableResult func addFavorite(track: Track) -> Favorite
    
    @discardableResult func addFavorite(artist: String) -> Favorite
//
    @discardableResult func addFavorite(album: String) -> Favorite
//
//    func addFavorite(genre: String) -> Favorite
//    
//    func addFavorite(decade: String) -> Favorite
//    
//    func addFavorite(playlist: Playlist) -> Favorite
//    
//    func addFavorite(playlistFile: ImportedPlaylist) -> Favorite
    
    var allFavorites: [Favorite] {get}
    
    var count: Int {get}
    
    func getFavoriteWithFile(_ file: URL) -> Favorite?
    
    func getFavoriteAtIndex(_ index: Int) -> Favorite
    
    func deleteFavorites(atIndices indices: IndexSet)
    
    func deleteFavoriteWithFile(_ file: URL)
    
    func favoriteTrackExists(_ track: Track) -> Bool
    
    func favoriteArtistExists(_ artist: String) -> Bool
    
    func favoriteAlbumExists(_ album: String) -> Bool
    
    func playFavorite(_ favorite: Favorite) throws
}
