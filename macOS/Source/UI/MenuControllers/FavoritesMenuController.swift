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
    
    // Menu that displays tracks marked "favorites". Clicking on any of these items will result in the track being  played.
    @IBOutlet weak var favoritesMenu: NSMenu!
    
    @IBOutlet weak var addRemoveFavoritesMenuItem: ToggleMenuItem!
    @IBOutlet weak var manageFavoritesMenuItem: NSMenuItem!    
    
    private lazy var managerWindowController: PresetsManagerWindowController = PresetsManagerWindowController.instance
    
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
        manageFavoritesMenuItem.enableIf(favoritesDelegate.count > 0)
    }

    func menuWillOpen(_ menu: NSMenu) {
        
        if let playingTrack = playbackInfoDelegate.playingTrack {
            addRemoveFavoritesMenuItem.onIf(favoritesDelegate.favoriteTrackExists(playingTrack))
        } else {
            addRemoveFavoritesMenuItem.off()
        }
        
        // Remove existing (possibly stale) items, starting after the static items
        while favoritesMenu.items.count > 3 {
            favoritesMenu.removeItem(at: 3)
        }
        
        // Recreate the menu (reverse so that newer items appear first).
        favoritesDelegate.allFavorites.reversed().forEach {favoritesMenu.addItem(createFavoritesMenuItem($0))}
    }
    
    // Factory method to create a single Favorites menu item, given a model object (FavoritesItem)
    private func createFavoritesMenuItem(_ item: Favorite) -> NSMenuItem {
        
        // The action for the menu item will depend on whether it is a playable item
        let action = #selector(self.playSelectedItemAction(_:))
        
        let menuItem = FavoritesMenuItem(title: "  " + item.name, action: action)
        menuItem.target = self
        
        if let trackItem = item as? FavoriteTrack {
            menuItem.image = trackItem.track.art?.image
            
        } else if let groupItem = item as? FavoriteGroup {
            
            switch groupItem.groupType {
                
            case .artist:
                menuItem.image = .imgArtistGroup_menu
                
            case .album:
                menuItem.image = .imgAlbumGroup_menu
                
            case .genre:
                menuItem.image = .imgGenreGroup

            case .decade:
                menuItem.image = .imgDecadeGroup

            case .albumDisc:
                menuItem.image = .imgAlbumGroup_menu
                
            default:
                break
            }
            
        } else {
            menuItem.image = .imgPlayedTrack
        }
        
        menuItem.image?.size = menuItemCoverArtImageSize
        menuItem.favorite = item
        
        return menuItem
    }
    
    // Adds/removes the currently playing track, if there is one, to/from the "Favorites" list
    @IBAction func favoritesAction(_ sender: Any) {
        messenger.publish(.favoritesList_addOrRemove)
    }
    
    // When a "Favorites" menu item is clicked, the item is played
    @IBAction fileprivate func playSelectedItemAction(_ sender: FavoritesMenuItem) {
        
        if let fav = sender.favorite {
            favoritesDelegate.playFavorite(fav)
        }
    }
    
    // Opens the presets manager to manage favorites
    @IBAction func manageFavoritesAction(_ sender: Any) {
        managerWindowController.showFavoritesManager()
    }
}

class FavoritesMenuItem: NSMenuItem {
    
    var favorite: Favorite!
}
