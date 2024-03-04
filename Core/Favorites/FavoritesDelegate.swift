//
//  FavoritesDelegate.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Foundation
import OrderedCollections

///
/// A delegate allowing access to the list of user-defined favorites.
///
/// Acts as a middleman between the UI and the Favorites list,
/// providing a simplified interface / facade for the UI layer to manipulate the Favorites list.
///
/// - SeeAlso: `Favorite`
///
class FavoritesDelegate: FavoritesDelegateProtocol {
    
    var favoriteTracks: OrderedDictionary<URL, FavoriteTrack>
    
    var favoriteArtists: OrderedDictionary<String, FavoriteGroup>
    var favoriteAlbums: OrderedDictionary<String, FavoriteGroup>
    var favoriteGenres: OrderedDictionary<String, FavoriteGroup>
    var favoriteDecades: OrderedDictionary<String, FavoriteGroup>
    
    var favoriteFolders: OrderedDictionary<URL, FavoriteFolder>
    var favoritePlaylistFiles: OrderedDictionary<URL, FavoritePlaylistFile>
    
    var hasAnyFavorites: Bool {
        favoriteTracks.values.isNonEmpty || favoriteArtists.values.isNonEmpty || favoriteAlbums.values.isNonEmpty || favoriteGenres.values.isNonEmpty || favoriteDecades.values.isNonEmpty || favoriteFolders.values.isNonEmpty
    }
    
    var allFavoriteTracks: [FavoriteTrack] {
        Array(favoriteTracks.values)
    }
    
    func favoriteTrack(atChronologicalIndex index: Int) -> FavoriteTrack? {
        
        if favoriteTracks.isEmpty {return nil}
        
        if favoriteTracks.indices.contains(index) {
        
            // Invert the index
            return favoriteTracks.values[favoriteTracks.count - index - 1]
        }
        
        return nil
    }
    
    var numberOfFavoriteTracks: Int {
        favoriteTracks.count
    }
    
    var allFavoriteArtists: [FavoriteGroup] {
        Array(favoriteArtists.values)
    }
    
    var numberOfFavoriteArtists: Int {
        favoriteArtists.count
    }
    
    var allFavoriteAlbums: [FavoriteGroup] {
        Array(favoriteAlbums.values)
    }
    
    var numberOfFavoriteAlbums: Int {
        favoriteAlbums.count
    }
    
    var allFavoriteGenres: [FavoriteGroup] {
        Array(favoriteGenres.values)
    }
    
    var numberOfFavoriteGenres: Int {
        favoriteGenres.count
    }
    
    var allFavoriteDecades: [FavoriteGroup] {
        Array(favoriteDecades.values)
    }
    
    var numberOfFavoriteDecades: Int {
        favoriteDecades.count
    }
    
    var allFavoriteFolders: [FavoriteFolder] {
        Array(favoriteFolders.values)
    }
    
    var numberOfFavoriteFolders: Int {
        favoriteFolders.count
    }
    
    var allFavoritePlaylistFiles: [FavoritePlaylistFile] {
        Array(favoritePlaylistFiles.values)
    }
    
    var numberOfFavoritePlaylistFiles: Int {
        favoritePlaylistFiles.count
    }
    
    var artistsFromFavoriteTracks: Set<String> {
        Set(favoriteTracks.values.compactMap {$0.track.artist})
    }
    
    var albumsFromFavoriteTracks: Set<String> {
        Set(favoriteTracks.values.compactMap {$0.track.album})
    }
    
    var genresFromFavoriteTracks: Set<String> {
        Set(favoriteTracks.values.compactMap {$0.track.genre})
    }
    
    var decadesFromFavoriteTracks: Set<String> {
        Set(favoriteTracks.values.compactMap {$0.track.decade})
    }
    
    private let playQueue: PlayQueueDelegateProtocol
    
    // Delegate used to perform playback
    private let player: PlaybackDelegateProtocol
    
    private lazy var messenger = Messenger(for: self)
    
    init(_ playQueue: PlayQueueDelegateProtocol, _ player: PlaybackDelegateProtocol) {
        
        self.player = player
        self.playQueue = playQueue
        
        self.favoriteTracks = OrderedDictionary()
        self.favoriteArtists = OrderedDictionary()
        self.favoriteAlbums = OrderedDictionary()
        self.favoriteGenres = OrderedDictionary()
        self.favoriteDecades = OrderedDictionary()
        self.favoriteFolders = OrderedDictionary()
        self.favoritePlaylistFiles = OrderedDictionary()
    }
    
    func addFavorite(track: Track) {
        
        let favorite = FavoriteTrack(track: track)
        favoriteTracks[track.file] = favorite
        messenger.publish(.favoritesList_itemAdded, payload: favorite)
        
        print("Added fav track: '\(track.displayName)'")
    }
    
    func addFavorite(artist: String) {
        
        let favorite = FavoriteGroup(groupName: artist, groupType: .artist)
        favoriteArtists[artist] = favorite
        messenger.publish(.favoritesList_itemAdded, payload: favorite)
        
        print("Added fav artist: '\(artist)'")
    }
    
    func addFavorite(album: String) {
        
        let favorite = FavoriteGroup(groupName: album, groupType: .album)
        favoriteAlbums[album] = favorite
        messenger.publish(.favoritesList_itemAdded, payload: favorite)
        
        print("Added fav album: '\(album)'")
    }
    
    func addFavorite(genre: String) {
        
        let favorite = FavoriteGroup(groupName: genre, groupType: .genre)
        favoriteGenres[genre] = favorite
        messenger.publish(.favoritesList_itemAdded, payload: favorite)
        
        print("Added fav genre: '\(genre)'")
    }

    func addFavorite(decade: String) {
        
        let favorite = FavoriteGroup(groupName: decade, groupType: .decade)
        favoriteDecades[decade] = favorite
        messenger.publish(.favoritesList_itemAdded, payload: favorite)
        
        print("Added fav decade: '\(decade)'")
    }
    
    func addFavorite(folder: URL) {
     
        let favorite = FavoriteFolder(folder: folder)
        favoriteFolders[folder] = favorite
        messenger.publish(.favoritesList_itemAdded, payload: favorite)
        
        print("Added fav folder: '\(folder.path)'")
    }
    
    func addFavorite(playlistFile: URL) {
        
        let favorite = FavoritePlaylistFile(playlistFile: playlistFile)
        favoritePlaylistFiles[playlistFile] = favorite
        messenger.publish(.favoritesList_itemAdded, payload: favorite)
        
        print("Added fav playlist file: '\(playlistFile.path)'")
    }
    
//    func addFavorite(playlist: Playlist) {
//        Favorite(name: "", type: .album)
//    }
//    
    func removeFavorite(track: Track) {
        
        if let removedFav = favoriteTracks.removeValue(forKey: track.file) {
            messenger.publish(.favoritesList_itemsRemoved, payload: Set<Favorite>([removedFav]))
        }
    }
    
    func removeFavorite(artist: String) {
        
        if let removedFav = favoriteArtists.removeValue(forKey: artist) {
            messenger.publish(.favoritesList_itemsRemoved, payload: Set<Favorite>([removedFav]))
        }
    }
    
    func removeFavorite(album: String) {
        
        if let removedFav = favoriteAlbums.removeValue(forKey: album) {
            messenger.publish(.favoritesList_itemsRemoved, payload: Set<Favorite>([removedFav]))
        }
    }
    
    func removeFavorite(genre: String) {
        
        if let removedFav = favoriteGenres.removeValue(forKey: genre) {
            messenger.publish(.favoritesList_itemsRemoved, payload: Set<Favorite>([removedFav]))
        }
    }
    
    func removeFavorite(decade: String) {
        
        if let removedFav = favoriteDecades.removeValue(forKey: decade) {
            messenger.publish(.favoritesList_itemsRemoved, payload: Set<Favorite>([removedFav]))
        }
    }
    
    func removeFavorite(folder: URL) {
        
        if let removedFav = favoriteFolders.removeValue(forKey: folder) {
            messenger.publish(.favoritesList_itemsRemoved, payload: Set<Favorite>([removedFav]))
        }
    }
    
    func removeFavorite(playlistFile: URL) {
        
        if let removedFav = favoritePlaylistFiles.removeValue(forKey: playlistFile) {
            messenger.publish(.favoritesList_itemsRemoved, payload: Set<Favorite>([removedFav]))
        }
    }
    
//    func getFavoriteAtIndex(_ index: Int) -> Favorite {
//        favorites.userDefinedObjects[index]
//    }
    
    func deleteFavorites(atIndices indices: IndexSet) {
        
//        let deletedFavorites = favorites.deleteObjects(atIndices: indices)
//        messenger.publish(.favoritesList_tracksRemoved, payload: Set(deletedFavorites))
    }
    
    func favoriteExists(track: Track) -> Bool {
        favoriteTracks[track.file] != nil
    }
    
    func favoriteExists(artist: String) -> Bool {
        favoriteArtists[artist] != nil
    }
    
    func favoriteExists(album: String) -> Bool {
        favoriteAlbums[album] != nil
    }
    
    func favoriteExists(genre: String) -> Bool {
        favoriteGenres[genre] != nil
    }
    
    func favoriteExists(decade: String) -> Bool {
        favoriteDecades[decade] != nil
    }
    
    func playFavorite(_ favorite: Favorite) {

        if let favTrack = favorite as? FavoriteTrack {
            playQueueDelegate.enqueueToPlayNow(tracks: [favTrack.track], clearQueue: false)
            
        } else if let favGroup = favorite as? FavoriteGroup,
                  let group = libraryDelegate.findGroup(named: favGroup.groupName, ofType: favGroup.groupType) {
         
            playQueueDelegate.enqueueToPlayNow(group: group, clearQueue: false)
            
        } else if let favFolder = favorite as? FavoriteFolder {
            
            // Recursively get all tracks, then add them to the PQ before playing
            
            if let folder = libraryDelegate.findFileSystemFolder(atLocation: favFolder.folder) {
                playQueueDelegate.enqueueToPlayNow(fileSystemItems: [folder], clearQueue: false)
                
            } else {
                playQueueDelegate.loadTracks(from: [favFolder.folder], params: .init(autoplay: true))
            }
            
        } else if let favPlaylistFile = favorite as? FavoritePlaylistFile {
            
            if let importedPlaylist = libraryDelegate.findImportedPlaylist(atLocation: favPlaylistFile.playlistFile) {
                playQueueDelegate.enqueueToPlayNow(playlistFile: importedPlaylist, clearQueue: false)
                
            } else {
                playQueueDelegate.loadTracks(from: [favPlaylistFile.playlistFile], params: .init(autoplay: true))
            }
        }
    }
    
    var persistentState: FavoritesPersistentState {
        
        FavoritesPersistentState(favoriteTracks: self.allFavoriteTracks.map {FavoriteTrackPersistentState(favorite: $0)},
                                 favoriteArtists: self.allFavoriteArtists.map {FavoriteGroupPersistentState(favorite: $0)},
                                 favoriteAlbums: self.allFavoriteAlbums.map {FavoriteGroupPersistentState(favorite: $0)},
                                 favoriteGenres: self.allFavoriteGenres.map {FavoriteGroupPersistentState(favorite: $0)},
                                 favoriteDecades: self.allFavoriteDecades.map {FavoriteGroupPersistentState(favorite: $0)},
                                 favoriteFolders: self.allFavoriteFolders.map {FavoriteFolderPersistentState(favorite: $0)},
                                 favoritePlaylistFiles: self.allFavoritePlaylistFiles.map {FavoritePlaylistFilePersistentState(favorite: $0)})
    }
}
