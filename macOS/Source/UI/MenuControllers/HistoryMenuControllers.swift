//
//  HistoryMenuControllers.swift
//  Aural
//
//  Copyright © 2023 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

let menuItemCoverArtImageSize: NSSize = NSSize(width: 22, height: 22)

/*
    Manages and provides actions for the History menu that displays historical information about the usage of the app.
 */
class HistoryMenuController: NSObject, NSMenuDelegate {
    
    // Sub-menu that displays recently added files/folders. Clicking on any of these items will result in the item being added to the playlist if not already present.
    @IBOutlet weak var recentlyAddedMenu: NSMenu!
    
    @IBOutlet weak var resumeLastPlayedTrackItem: NSMenuItem!

    // Delegate that performs CRUD on the history model
    private let history: HistoryDelegateProtocol = historyDelegate
    
    private let player: PlaybackDelegateProtocol = playbackDelegate
    
    func menuWillOpen(_ menu: NSMenu) {
        resumeLastPlayedTrackItem.enableIf(player.state == .stopped && history.lastPlaybackPosition > 0)
    }
    
    @IBAction fileprivate func resumeLastPlayedTrackAction(_ sender: NSMenuItem) {
        
        do {
            
            try history.resumeLastPlayedTrack()
            
        } catch {
            
            if let lastPlayedItem = history.lastPlayedItem, let fnfError = error as? FileNotFoundError {
                
                // This needs to be done async. Otherwise, other open dialogs could hang.
                DispatchQueue.main.async {
                    
                    // Position and display an alert with error info
                    _ = DialogsAndAlerts.trackNotPlayedAlertWithError(fnfError, "Remove item").showModal()
                    self.history.deleteItem(lastPlayedItem)
                }
            }
        }
    }
    
    @IBAction fileprivate func clearHistoryAction(_ sender: NSMenuItem) {
        history.clearAllHistory()
    }
}

fileprivate let addedItemsArtLoadingQueue: OperationQueue = OperationQueue(opCount: max(SystemUtils.numberOfActiveCores / 2, 2),
                                                                           qos: .userInteractive)

fileprivate let playedItemsArtLoadingQueue: OperationQueue = OperationQueue(opCount: max(SystemUtils.numberOfActiveCores / 2, 2),
                                                                            qos: .userInteractive)

// A menu item that stores an associated history item (used when executing the menu item action)
class HistoryMenuItem: NSMenuItem {
    var historyItem: HistoryItem!
}

//fileprivate let playlist: PlaylistDelegateProtocol = playlistDelegate

fileprivate func artForFile(_ _file: URL) -> NSImage? {
    
    // Resolve sym links and aliases
    let file = _file.resolvedURL
    
    if file.isDirectory {
        
        // Display name is last path component
        // Art is folder icon
        return .imgGroup_menu
        
    } else {
        
        // Single file - playlist or track
        let fileExtension = file.lowerCasedExtension
        
        if SupportedTypes.playlistExtensions.contains(fileExtension) {
            
            // Playlist
            // Display name is last path component
            // Art is playlist icon
            return .imgHistory_playlist_padded
            
        } else if SupportedTypes.allAudioExtensions.contains(fileExtension) {
            
//            return (playlist.findFile(file)?.art?.image ?? fileReader.getArt(for: file)?.image)?.imageCopy()
            return nil
        }
    }
    
    return nil
}

// Factory method to create a single history menu item, given a model object (HistoryItem)
fileprivate func createHistoryMenuItem(_ item: HistoryItem, _ actionTarget: AnyObject, _ action: Selector) -> NSMenuItem {
    
    // The action for the menu item will depend on whether it is a playable item
    
    let menuItem = HistoryMenuItem(title: "  " + item.displayName, action: action)
    menuItem.target = actionTarget
    
    if item is TrackHistoryItem {
        menuItem.image = .imgPlayedTrack
        
    } else if item is GroupHistoryItem {
        menuItem.image = .imgGroup_menu
    }
    
    menuItem.image?.size = menuItemCoverArtImageSize
    
//    let queue = item is AddedItem ? addedItemsArtLoadingQueue : playedItemsArtLoadingQueue
//    
//    queue.addOperation {
//        
//        if let art = artForFile(item.file) {
//            
//            art.size = menuItemCoverArtImageSize
//            
//            DispatchQueue.main.async {
//                menuItem.image = art
//            }
//        }
//    }
    
    menuItem.historyItem = item
    
    return menuItem
}

// Populates the given menu with items corresponding to the given historical item info, grouped by timestamp into categories like "Past 24 hours", "Past 7 days", etc.
fileprivate func createChronologicalMenu(_ items: [HistoryItem], _ menu: NSMenu, _ actionTarget: AnyObject, _ action: Selector) {
    
    // Keeps track of which time categories have already been created
    var timeCategories = Set<TimeElapsed>()
    
    for item in items {
        
        let menuItem = createHistoryMenuItem(item, actionTarget, action)
        
        // Figure out how old this item is
        let timeElapsed = Date.timeElapsedSince(item.lastEventTime)
        
        // If this category doesn't already exist, create it
        if !timeCategories.contains(timeElapsed) {
            
            timeCategories.insert(timeElapsed)
            
            // Add a descriptor menu item that describes the time category, between 2 separators
            menu.addItem(NSMenuItem.separator())
            menu.addItem(NSMenuItem.createDescriptor(title: timeElapsed.rawValue))
            menu.addItem(NSMenuItem.separator())
        }
        
        // Add the history menu item to the menu
        menu.addItem(menuItem)
    }
}

class RecentlyAddedMenuController: NSObject, NSMenuDelegate {
    
    // Sub-menu that displays recently added files/folders. Clicking on any of these items will result in the item being added to the playlist if not already present.
    @IBOutlet weak var recentlyAddedMenu: NSMenu!
    
    // Delegate that performs CRUD on the history model
    private let history: HistoryDelegateProtocol = historyDelegate
    
    // Before the menu opens, re-create the menu items from the model
    func menuWillOpen(_ menu: NSMenu) {
        
        recentlyAddedMenu.removeAllItems()
        
        // Retrieve the model and re-create all sub-menu items
        createChronologicalMenu(history.allRecentlyAddedItems(), recentlyAddedMenu, self, #selector(self.addSelectedItemAction(_:)))
    }
    
    func menuDidClose(_ menu: NSMenu) {
        addedItemsArtLoadingQueue.cancelAllOperations()
    }
    
    // When a "Recently added" menu item is clicked, the item is added to the playlist
    @IBAction fileprivate func addSelectedItemAction(_ sender: HistoryMenuItem) {
        
        // TODO: Different behavior based on type of item (track, folder, artist, etc)
        
//        if let item = sender.historyItem as? HistoryItem {
//            
//            do {
//                try history.addItem(item.file)
//                
//            } catch {
//                
//                if let fnfError = error as? FileNotFoundError {
//                    
//                    // This needs to be done async. Otherwise, other open dialogs could hang.
//                    DispatchQueue.main.async {
//                        
//                        // Position and display an alert with error info
//                        _ = DialogsAndAlerts.historyItemNotAddedAlertWithError(fnfError, "Remove item from history").showModal()
//                        self.history.deleteItem(item)
//                    }
//                }
//            }
//        }
    }
}

class RecentlyPlayedMenuController: NSObject, NSMenuDelegate {
    
    // Sub-menu that displays recently played tracks. Clicking on any of these items will result in the track being played.
    @IBOutlet weak var recentlyPlayedMenu: NSMenu!
    
    // Delegate that performs CRUD on the history model
    private let history: HistoryDelegateProtocol = historyDelegate
    
    // Before the menu opens, re-create the menu items from the model
    func menuWillOpen(_ menu: NSMenu) {
        
        recentlyPlayedMenu.removeAllItems()
        
        // Retrieve the model and re-create all sub-menu items
        createChronologicalMenu(history.allRecentlyPlayedItems(), recentlyPlayedMenu, self, #selector(self.playSelectedItemAction(_:)))
    }
    
    func menuDidClose(_ menu: NSMenu) {
        playedItemsArtLoadingQueue.cancelAllOperations()
    }
    
    // When a "Recently played" or "Favorites" menu item is clicked, the item is played
    @IBAction fileprivate func playSelectedItemAction(_ sender: HistoryMenuItem) {
        
        guard let item = sender.historyItem else {return}
        
        do {
            try history.playItem(item)
            
        } catch {
            
            if let fnfError = error as? FileNotFoundError {
                
                // This needs to be done async. Otherwise, other open dialogs could hang.
                DispatchQueue.main.async {
                    
                    // Position and display an alert with error info
                    _ = DialogsAndAlerts.trackNotPlayedAlertWithError(fnfError, "Remove item").showModal()
                    self.history.deleteItem(item)
                }
            }
        }
    }
}
