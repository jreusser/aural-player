//
//  FavoritesMenuController.swift
//  Aural
//
//  Copyright © 2023 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

class FavoritesMenuController: NSObject, NSMenuDelegate {
    
    @IBOutlet weak var addRemoveFavoritesMenuItem: ToggleMenuItem!
    @IBOutlet weak var manageFavoritesMenuItem: NSMenuItem!    
    
    private lazy var managerWindowController: FavoritesWindowController = .init()
    
    private lazy var messenger = Messenger(for: self)
    
    // One-time setup, when the menu loads
    override func awakeFromNib() {
        addRemoveFavoritesMenuItem.off()
    }
    
    // Before the menu opens, re-create the menu items from the model
    func menuNeedsUpdate(_ menu: NSMenu) {
        
        // These menu item actions are only available when a track is currently playing/paused
        addRemoveFavoritesMenuItem.enableIf(playbackInfoDelegate.state.isPlayingOrPaused)
        
        // Menu has 3 static items
        manageFavoritesMenuItem.enableIf(favoritesDelegate.hasAnyFavorites)
    }

    func menuWillOpen(_ menu: NSMenu) {
        
        if let playingTrack = playbackInfoDelegate.playingTrack {
            addRemoveFavoritesMenuItem.onIf(favoritesDelegate.favoriteExists(track: playingTrack))
        } else {
            addRemoveFavoritesMenuItem.off()
        }
    }
    
    // Adds/removes the currently playing track, if there is one, to/from the "Favorites" list
    @IBAction func playingTrackFavoritesAction(_ sender: Any) {
        messenger.publish(.favoritesList_addOrRemove)
    }
    
    // Opens the presets manager to manage favorites
    @IBAction func manageFavoritesAction(_ sender: Any) {
        managerWindowController.showWindow(self)
    }
}

// MARK: Favorite Tracks menu --------------------------------------------

class FavoriteTracksMenuController: NSObject, NSMenuDelegate {
    
    // Menu that displays tracks marked "favorites". Clicking on any of these items will result in the track being  played.
    @IBOutlet weak var favoriteTracksMenu: NSMenu!
    
    func menuWillOpen(_ menu: NSMenu) {
        
        // Remove existing items, before re-creating the menu.
        favoriteTracksMenu.removeAllItems()
        
        // Recreate the menu (reverse so that newer items appear first).
        for fav in favoritesDelegate.allFavoriteTracks.reversed() {
            favoriteTracksMenu.addItem(createFavoriteTrackMenuItem(fav))
        }
    }
    
    // Factory method to create a single Favorites menu item, given a model object (FavoritesItem)
    private func createFavoriteTrackMenuItem(_ fav: FavoriteTrack) -> NSMenuItem {
        
        // The action for the menu item will depend on whether it is a playable item
        let action = #selector(self.playSelectedItemAction(_:))
        
        let menuItem = FavoritesMenuItem(title: "  " + fav.name, action: action)
        menuItem.target = self
        
        menuItem.image = fav.track.art?.image ?? .imgPlayedTrack
        menuItem.image?.size = menuItemCoverArtImageSize
        
        menuItem.favorite = fav
        
        return menuItem
    }
    
    // When a "Favorites" menu item is clicked, the item is played
    @IBAction fileprivate func playSelectedItemAction(_ sender: FavoritesMenuItem) {
        
        if let fav = sender.favorite {
            favoritesDelegate.playFavorite(fav)
        }
    }
}

// MARK: Favorite Groups menu --------------------------------------------

@IBDesignable
class FavoriteGroupsMenuController: NSObject, NSMenuDelegate {
    
    // Menu that displays tracks marked "favorites". Clicking on any of these items will result in the track being  played.
    @IBOutlet weak var favoriteGroupsMenu: NSMenu!
    @IBInspectable weak var itemImage: NSImage!
    
    // Override this !!!
    var groupsFunction: () -> [FavoriteGroup] {
        {[]}
    }
    
    func menuWillOpen(_ menu: NSMenu) {
        
        // Remove existing items, before re-creating the menu.
        favoriteGroupsMenu.removeAllItems()
        
        // Recreate the menu (reverse so that newer items appear first).
        for fav in groupsFunction().reversed() {
            favoriteGroupsMenu.addItem(createFavoriteGroupMenuItem(fav))
        }
    }
    
    // Factory method to create a single Favorites menu item, given a model object (FavoritesItem)
    private func createFavoriteGroupMenuItem(_ fav: FavoriteGroup) -> NSMenuItem {
        
        // The action for the menu item will depend on whether it is a playable item
        let action = #selector(self.playSelectedItemAction(_:))
        
        let menuItem = FavoritesMenuItem(title: "  " + fav.groupName, action: action)
        menuItem.target = self
        
        menuItem.image = itemImage
        menuItem.image?.size = menuItemCoverArtImageSize
        
        menuItem.favorite = fav
        
        return menuItem
    }
    
    // When a "Favorites" menu item is clicked, the item is played
    @IBAction fileprivate func playSelectedItemAction(_ sender: FavoritesMenuItem) {
        
        if let fav = sender.favorite {
            favoritesDelegate.playFavorite(fav)
        }
    }
}

class FavoriteArtistsMenuController: FavoriteGroupsMenuController {
    
    override var groupsFunction: () -> [FavoriteGroup] {
        {favoritesDelegate.allFavoriteArtists}
    }
}

class FavoriteAlbumsMenuController: FavoriteGroupsMenuController {
    
    override var groupsFunction: () -> [FavoriteGroup] {
        {favoritesDelegate.allFavoriteAlbums}
    }
}

class FavoriteGenresMenuController: FavoriteGroupsMenuController {
    
    override var groupsFunction: () -> [FavoriteGroup] {
        {favoritesDelegate.allFavoriteGenres}
    }
}

class FavoriteDecadesMenuController: FavoriteGroupsMenuController {
    
    override var groupsFunction: () -> [FavoriteGroup] {
        {favoritesDelegate.allFavoriteDecades}
    }
}

//// MARK: Favorite Albums menu --------------------------------------------
//
//class FavoriteAlbumsMenuController: NSObject, NSMenuDelegate {
//    
//    // Menu that displays tracks marked "favorites". Clicking on any of these items will result in the track being  played.
//    @IBOutlet weak var favoriteAlbumsMenu: NSMenu!
//    
//    func menuWillOpen(_ menu: NSMenu) {
//        
//        // Remove existing items, before re-creating the menu.
//        favoriteAlbumsMenu.removeAllItems()
//        
//        // Recreate the menu (reverse so that newer items appear first).
//        for fav in favoritesDelegate.allFavoriteAlbums.reversed() {
//            favoriteAlbumsMenu.addItem(createFavoriteAlbumMenuItem(fav))
//        }
//    }
//    
//    // Factory method to create a single Favorites menu item, given a model object (FavoritesItem)
//    private func createFavoriteAlbumMenuItem(_ fav: FavoriteGroup) -> NSMenuItem {
//        
//        // The action for the menu item will depend on whether it is a playable item
//        let action = #selector(self.playSelectedItemAction(_:))
//        
//        let menuItem = FavoritesMenuItem(title: "  " + fav.groupName, action: action)
//        menuItem.target = self
//        
//        menuItem.image = .imgAlbumGroup_menu
//        menuItem.image?.size = menuItemCoverArtImageSize
//        
//        menuItem.favorite = fav
//        
//        return menuItem
//    }
//    
//    // When a "Favorites" menu item is clicked, the item is played
//    @IBAction fileprivate func playSelectedItemAction(_ sender: FavoritesMenuItem) {
//        
//        if let fav = sender.favorite {
//            favoritesDelegate.playFavorite(fav)
//        }
//    }
//}

class FavoritesMenuItem: NSMenuItem {
    
    var favorite: Favorite!
}

// Factory method to create a single Favorites menu item, given a model object (FavoritesItem)
//private func createFavoriteTrackMenuItem(_ item: Favorite) -> NSMenuItem {
//    
//    // The action for the menu item will depend on whether it is a playable item
//    let action = #selector(self.playSelectedItemAction(_:))
//    
//    let menuItem = FavoritesMenuItem(title: "  " + item.name, action: action)
//    menuItem.target = self
//    
//    if let trackItem = item as? FavoriteTrack {
//        menuItem.image = trackItem.track.art?.image
//        
//    } else if let groupItem = item as? FavoriteGroup {
//        
//        switch groupItem.groupType {
//            
//        case .artist:
//            menuItem.image = .imgArtistGroup_menu
//            
//        case .album:
//            menuItem.image = .imgAlbumGroup_menu
//            
//        case .genre:
//            menuItem.image = .imgGenreGroup
//
//        case .decade:
//            menuItem.image = .imgDecadeGroup
//
//        case .albumDisc:
//            menuItem.image = .imgAlbumGroup_menu
//            
//        default:
//            break
//        }
//        
//    } else {
//        menuItem.image = .imgPlayedTrack
//    }
//    
//    menuItem.image?.size = menuItemCoverArtImageSize
//    menuItem.favorite = item
//    
//    return menuItem
//}
