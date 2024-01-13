//
//  FavoritesManagerViewController.swift
//  Aural
//
//  Copyright © 2023 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

class FavoritesManagerViewController: NSViewController {
    
    // Delegate that relays accessor operations to the bookmarks model
    private let favorites: FavoritesDelegateProtocol = favoritesDelegate
    
    override var nibName: String? {"FavoritesManager"}
    
    @IBOutlet weak var selectedTabCaption: NSTextField!
    @IBOutlet weak var tabGroup: NSTabView!
    
    @IBOutlet weak var containerBox: NSBox!
    @IBOutlet weak var tabButtonsBox: NSBox!
    
    lazy var tracksViewController: FavoriteTracksViewController = .init()
    lazy var tracksTable: NSTableView = tracksViewController.tableView
    
    lazy var messenger: Messenger = .init(for: self)
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        tabGroup.tabViewItem(at: 0).view?.addSubview(tracksViewController.view)
        tracksViewController.view.anchorToSuperview()
        
        fontSchemesManager.registerObserver(selectedTabCaption, forProperty: \.captionFont)
        colorSchemesManager.registerObserver(selectedTabCaption, forProperties: [\.captionTextColor])
        colorSchemesManager.registerObservers([containerBox, tabButtonsBox], forProperties: [\.backgroundColor])
        
    }
    
    @IBAction func deleteSelectedItemsAction(_ sender: NSButton) {
        
        switch tabGroup.selectedIndex {
            
        case 0:
            
            let allFavTracks = favoritesDelegate.allFavoriteTracks
            let selectedFavTracks: [FavoriteTrack] = tracksTable.selectedRowIndexes.map {allFavTracks[$0]}
            
            for fav in selectedFavTracks {
                favoritesDelegate.removeFavorite(track: fav.track)
            }
            
            tracksTable.reloadData()
            
        default:
            return
        }
    }
    
    @IBAction func playSelectedItemsAction(_ sender: NSButton) {
        
        switch tabGroup.selectedIndex {
            
        case 0:
            
            let allFavTracks = favoritesDelegate.allFavoriteTracks
            let selectedFavTracks: [FavoriteTrack] = tracksTable.selectedRowIndexes.map {allFavTracks[$0]}
            
            messenger.publish(EnqueueAndPlayNowCommand(tracks: selectedFavTracks.map {$0.track}, clearPlayQueue: false))
            
        default:
            return
        }
    }
    
    @IBAction func doneAction(_ sender: NSButton) {
        view.window?.windowController?.close()
    }
}

extension NSUserInterfaceItemIdentifier {
    
    // Table view column identifiers
    static let cid_favoriteColumn: NSUserInterfaceItemIdentifier = NSUserInterfaceItemIdentifier("cid_favoriteColumn")
}
 
