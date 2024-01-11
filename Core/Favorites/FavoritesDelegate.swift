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

///
/// A delegate allowing access to the list of user-defined favorites.
///
/// Acts as a middleman between the UI and the Favorites list,
/// providing a simplified interface / facade for the UI layer to manipulate the Favorites list.
///
/// - SeeAlso: `Favorite`
///
class FavoritesDelegate: FavoritesDelegateProtocol {
    
    private typealias Favorites = UserManagedObjects<Favorite>
    
    private let favorites: Favorites
    
    private let playQueue: PlayQueueDelegateProtocol
    
    // Delegate used to perform playback
    private let player: PlaybackDelegateProtocol
    
    private lazy var messenger = Messenger(for: self)
    
    init(persistentState: FavoritesPersistentState?, _ playQueue: PlayQueueDelegateProtocol, _ player: PlaybackDelegateProtocol) {
        
        self.player = player
        self.playQueue = playQueue
        
        self.favorites = Favorites(systemDefinedObjects: [], userDefinedObjects: [])
        
        DispatchQueue.global(qos: .utility).async {
            
            for fav in persistentState?.favorites?.compactMap({self.favoriteFromPersistentState($0)}) ?? [] {
                self.favorites.addObject(fav)
            }
        }
        
        // TODO: Use TrackLoader here to load tracks for all favorites.
    }
    
    private func favoriteFromPersistentState(_ state: FavoritePersistentState) -> Favorite? {
        
        guard let itemType = state.itemType else {return nil}
        
        switch itemType {
            
        case .track:
            
            if let trackFile = state.trackFile {
                
                do {
                    
                    var fileMetadata = FileMetadata()
                    fileMetadata.primary = try fileReader.getPrimaryMetadata(for: trackFile)
                    
                    let track = Track(trackFile, fileMetadata: fileMetadata)
                    return FavoriteTrack(track: track)
                    
                } catch {}
            }
            
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
            
            if let groupName = state.groupName, let groupType = state.groupType {
                return FavoriteGroup(groupName: groupName, groupType: groupType)
            }
            
        default: return nil
            
        }
        
        return nil
    }
    
    @discardableResult func addFavorite(track: Track) -> Favorite {
        
        let favorite = FavoriteTrack(track: track)
        favorites.addObject(favorite)
        messenger.publish(.favoritesList_itemAdded, payload: favorite)
        
        print("Added fav track: '\(track.displayName)'")
        
        return favorite
    }
    
    @discardableResult func addFavorite(artist: String) -> Favorite {
        
        let favorite = FavoriteGroup(groupName: artist, groupType: .artist)
        favorites.addObject(favorite)
        messenger.publish(.favoritesList_itemAdded, payload: favorite)
        
        print("Added fav artist: '\(artist)'")
        
        return favorite
    }
    
    @discardableResult func addFavorite(album: String) -> Favorite {
        
        let favorite = FavoriteGroup(groupName: album, groupType: .album)
        favorites.addObject(favorite)
        messenger.publish(.favoritesList_itemAdded, payload: favorite)
        
        print("Added fav album: '\(album)'")
        
        return favorite
    }
//    
//    func addFavorite(genre: String) -> Favorite {
//        Favorite(name: "", type: .album)
//    }
//    
//    func addFavorite(decade: String) -> Favorite {
//        Favorite(name: "", type: .album)
//    }
//    
//    func addFavorite(playlist: Playlist) -> Favorite {
//        Favorite(name: "", type: .album)
//    }
//    
//    func addFavorite(playlistFile: ImportedPlaylist) -> Favorite {
//        Favorite(name: "", type: .album)
//    }
    
    var allFavorites: [Favorite] {favorites.userDefinedObjects}
    
    var count: Int {favorites.numberOfUserDefinedObjects}
    
    func getFavoriteWithFile(_ file: URL) -> Favorite? {
        favorites.userDefinedObject(named: file.path)
    }
    
    func getFavoriteAtIndex(_ index: Int) -> Favorite {
        favorites.userDefinedObjects[index]
    }
    
    func deleteFavorites(atIndices indices: IndexSet) {
        
        let deletedFavorites = favorites.deleteObjects(atIndices: indices)
        messenger.publish(.favoritesList_tracksRemoved, payload: Set(deletedFavorites))
    }
    
    func deleteFavoriteWithFile(_ file: URL) {
        
//        if let favorite = favorites.deleteObject(withKey: file.path) {
//            messenger.publish(.favoritesList_tracksRemoved, payload: Set([favorite]))
//        }
    }
    
    func favoriteTrackExists(_ track: Track) -> Bool {
        favorites.userDefinedObjectExists(named: track.file.path)
    }
    
    func favoriteArtistExists(_ artist: String) -> Bool {
        favorites.userDefinedObjectExists(named: "artist_\(artist)")
    }
    
    func favoriteAlbumExists(_ album: String) -> Bool {
        favorites.userDefinedObjectExists(named: "album_\(album)")
    }
    
    func playFavorite(_ favorite: Favorite) throws {
        
//        do {
        
            // First, add the given track to the play queue.
//        if favorite.type == .track, let file = favorite.file {
//            playQueueDelegate.loadTracks(from: [file], autoplay: true)
//        }
            
            // TODO: What if the file no longer exists ??? Display an error !
//
//        } catch {
//
//            if let fnfError = error as? FileNotFoundError {
//
//                // Log and rethrow error
//                NSLog("Unable to play Favorites item. Details: %@", fnfError.message)
//                throw fnfError
//            }
//        }
    }
    
    var persistentState: FavoritesPersistentState {
        FavoritesPersistentState(favorites: allFavorites.compactMap {FavoritePersistentState(favorite: $0)})
    }
}
