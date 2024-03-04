//
//  FavoritesManagerViewController.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

class FavoritesManagerViewController: NSViewController {
    
    // Delegate that relays accessor operations to the bookmarks model
    private let favorites: FavoritesDelegateProtocol = favoritesDelegate
    
    override var nibName: String? {"FavoritesManager"}
    
    @IBOutlet weak var containerBox: NSBox!
    
    @IBOutlet weak var lblCaption: NSTextField!
    @IBOutlet weak var tabGroup: NSTabView!
    @IBOutlet weak var lblSummary: NSTextField!
    
    lazy var tracksViewController: FavoriteTracksViewController = .init()
    lazy var tracksTable: NSTableView = tracksViewController.tableView
    
    lazy var messenger: Messenger = .init(for: self)
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        tabGroup.tabViewItem(at: 0).view?.addSubview(tracksViewController.view)
        tracksViewController.view.anchorToSuperview()
        
        updateSummary()
        
        fontSchemesManager.registerObserver(self)
        
        colorSchemesManager.registerSchemeObserver(self)
        colorSchemesManager.registerPropertyObserver(self, forProperty: \.backgroundColor, changeReceiver: containerBox)
        colorSchemesManager.registerPropertyObserver(self, forProperty: \.captionTextColor, changeReceiver: lblCaption)
        colorSchemesManager.registerPropertyObserver(self, forProperty: \.secondaryTextColor, changeReceiver: lblSummary)
        
        messenger.subscribe(to: .Favorites.itemAdded, handler: updateSummary)
        messenger.subscribe(to: .Favorites.itemsRemoved, handler: updateSummary)
    }
    
    func updateSummary() {
        lblSummary.stringValue = "\(favoritesDelegate.numberOfFavoriteTracks)  favorite tracks"
    }
    
    @IBAction func deleteSelectedItemsAction(_ sender: NSButton) {
        
        switch tabGroup.selectedIndex {
            
        case 0:
            
            let selectedFavTracks: [FavoriteTrack] = tracksTable.selectedRowIndexes.compactMap {favoritesDelegate.favoriteTrack(atChronologicalIndex: $0)}
            
            if selectedFavTracks.isNonEmpty {
                
                for fav in selectedFavTracks {
                    favoritesDelegate.removeFavorite(track: fav.track)
                }
                
                tracksTable.reloadData()
            }
            
        default:
            return
        }
    }
    
    @IBAction func playSelectedItemsAction(_ sender: NSButton) {
        
        switch tabGroup.selectedIndex {
            
        case 0:
            
            let selectedFavTracks: [FavoriteTrack] = tracksTable.selectedRowIndexes.compactMap {favoritesDelegate.favoriteTrack(atChronologicalIndex: $0)}
            
            if selectedFavTracks.isNonEmpty {
                playQueueDelegate.enqueueToPlayNow(tracks: selectedFavTracks.map {$0.track}, clearQueue: false)
            }
            
        default:
            return
        }
    }
    
    @IBAction func doneAction(_ sender: NSButton) {
        view.window?.windowController?.close()
    }
}

extension FavoritesManagerViewController: FontSchemeObserver {
    
    func fontSchemeChanged() {
        
        lblCaption.font = systemFontScheme.captionFont
        lblSummary.font = systemFontScheme.smallFont
    }
}

extension FavoritesManagerViewController: ColorSchemeObserver {
    
    func colorSchemeChanged() {
        
        lblCaption.textColor = systemColorScheme.captionTextColor
        lblSummary.textColor = systemColorScheme.secondaryTextColor
    }
}

extension NSUserInterfaceItemIdentifier {
    
    // Table view column identifiers
    static let cid_favoriteColumn: NSUserInterfaceItemIdentifier = NSUserInterfaceItemIdentifier("cid_favoriteColumn")
}
