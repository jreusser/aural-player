//
//  FavoritesDelegate.swift
//  Aural
//
//  Copyright © 2023 Kartik Venugopal. All rights reserved.
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
    
    private var favoriteTracks: OrderedDictionary<URL, FavoriteTrack>
    
    private var favoriteArtists: OrderedDictionary<String, FavoriteGroup>
    private var favoriteAlbums: OrderedDictionary<String, FavoriteGroup>
    private var favoriteGenres: OrderedDictionary<String, FavoriteGroup>
    private var favoriteDecades: OrderedDictionary<String, FavoriteGroup>
    
//    private var favoriteFolders: OrderedSet<URL>
//    private var favoritePlaylistFiles: OrderedSet<URL>
//    
//    private var favoritePlaylists: OrderedSet<String>
    
    var allFavoriteTracks: [FavoriteTrack] {
        Array(favoriteTracks.values)
    }
    
    var allFavoriteArtists: [FavoriteGroup] {
        Array(favoriteArtists.values)
    }
    
    var allFavoriteAlbums: [FavoriteGroup] {
        Array(favoriteAlbums.values)
    }
    
    var allFavoriteGenres: [FavoriteGroup] {
        Array(favoriteGenres.values)
    }
    
    var allFavoriteDecades: [FavoriteGroup] {
        Array(favoriteDecades.values)
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
    }
    
    private func loadFavoritesFromPersistentState() {
        
        guard let state = appPersistentState.favorites else {return}
        
        DispatchQueue.global(qos: .utility).async {
            
            for favState in state.favorites ?? [] {
                
                guard let itemType = favState.itemType else {continue}
                
                switch itemType {
                    
                case .track:
                    
                    guard let trackFile = favState.trackFile, let metadata = metadataRegistry[trackFile] else {continue}
                    
                    let track = Track(trackFile, fileMetadata: FileMetadata(primary: metadata))
                    self.favoriteTracks[trackFile] = FavoriteTrack(track: track)
                    
        //        case .playlistFile:
        //
        //            if let playlistFile = state.playlistFile {
        //                return PlaylistFileHistoryItem(playlistFile: playlistFile, lastEventTime: lastEventTime, eventCount: eventCount)
        //            }
        //
        //        case .folder:
        //
        //            if let folder = state.folder {
        //                return FolderHistoryItem(folder: folder, lastEventTime: lastEventTime, eventCount: eventCount)
        //            }
                    
                case .group:
                    
                    if let groupName = favState.groupName, let groupType = favState.groupType {
                        
                        switch groupType {
                            
                        case .artist:
                            self.favoriteArtists[groupName] = FavoriteGroup(groupName: groupName, groupType: groupType)
                            
                        case .album:
                            self.favoriteAlbums[groupName] = FavoriteGroup(groupName: groupName, groupType: groupType)
                            
                        case .genre:
                            self.favoriteArtists[groupName] = FavoriteGroup(groupName: groupName, groupType: groupType)
                            
                        case .decade:
                            self.favoriteDecades[groupName] = FavoriteGroup(groupName: groupName, groupType: groupType)
                            
                        default:
                            break
                        }
                    }
                    
                default:
                    continue
                }
            }
        }
    }
    
    private func favoriteFromPersistentState(_ state: FavoritePersistentState) -> Favorite? {
        
        
        
        return nil
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
        favoriteGenres[decade] = favorite
        messenger.publish(.favoritesList_itemAdded, payload: favorite)
        
        print("Added fav decade: '\(decade)'")
    }
    
//    func addFavorite(playlist: Playlist) -> Favorite {
//        Favorite(name: "", type: .album)
//    }
//    
//    func addFavorite(playlistFile: ImportedPlaylist) -> Favorite {
//        Favorite(name: "", type: .album)
//    }
    
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
            
            playQueue.addTracks([favTrack.track])
            playbackDelegate.play(favTrack.track)
            
        } else if let favGroup = favorite as? FavoriteGroup,
                  let group = libraryDelegate.findGroup(named: favGroup.groupName, ofType: favGroup.groupType) {
         
            messenger.publish(LibraryGroupPlayedNotification(group: group))
            messenger.publish(EnqueueAndPlayNowCommand(tracks: group.tracks, clearPlayQueue: false))
        }
    }
    
    var persistentState: FavoritesPersistentState {
        FavoritesPersistentState(favorites: [])
    }
}
