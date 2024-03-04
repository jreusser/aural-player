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
    lazy var artistsViewController: FavoriteArtistsViewController = .init()
    lazy var albumsViewController: FavoriteAlbumsViewController = .init()
    
    lazy var tracksTable: NSTableView = tracksViewController.tableView
    
    lazy var messenger: Messenger = .init(for: self)
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        tabGroup.tabViewItem(at: 0).view?.addSubview(tracksViewController.view)
        tracksViewController.view.anchorToSuperview()
        
        tabGroup.tabViewItem(at: 1).view?.addSubview(artistsViewController.view)
        artistsViewController.view.anchorToSuperview()
        
        tabGroup.tabViewItem(at: 2).view?.addSubview(albumsViewController.view)
        albumsViewController.view.anchorToSuperview()
        
        updateCaption()
        updateSummary()
        
        fontSchemesManager.registerObserver(self)
        
        colorSchemesManager.registerSchemeObserver(self)
        colorSchemesManager.registerPropertyObserver(self, forProperty: \.backgroundColor, changeReceiver: containerBox)
        colorSchemesManager.registerPropertyObserver(self, forProperty: \.captionTextColor, changeReceiver: lblCaption)
        colorSchemesManager.registerPropertyObserver(self, forProperty: \.secondaryTextColor, changeReceiver: lblSummary)
        
        messenger.subscribe(to: .Favorites.itemAdded, handler: updateSummary)
        messenger.subscribe(to: .Favorites.itemsRemoved, handler: updateSummary)
    }
    
    func showTab(for sidebarItem: LibrarySidebarItem) {
        
        guard sidebarItem.browserTab == .favorites else {return}
        
        switch sidebarItem.displayName {
            
        case "Tracks":
            tabGroup.selectTabViewItem(at: 0)
            
        case "Artists":
            tabGroup.selectTabViewItem(at: 1)
            
        case "Albums":
            tabGroup.selectTabViewItem(at: 2)
            
        default:
            return
        }
        
        updateCaption()
        updateSummary()
    }
    
    func updateCaption() {
        
        switch tabGroup.selectedIndex {
            
        case 0:
            lblCaption.stringValue = "Tracks"
            
        case 1:
            lblCaption.stringValue = "Artists"
            
        case 2:
            lblCaption.stringValue = "Albums"
            
        default:
            return
        }
    }
    
    func updateSummary() {
        
        switch tabGroup.selectedIndex {
            
        case 0:
            
            // Tracks
            let numFavorites = favoritesDelegate.numberOfFavoriteTracks
            lblSummary.stringValue = "\(numFavorites)  favorite \(numFavorites == 1 ? "track" : "tracks")"
            
        case 1:
            
            // Artists
            let numFavorites = favoritesDelegate.numberOfFavoriteArtists
            lblSummary.stringValue = "\(numFavorites)  favorite \(numFavorites == 1 ? "artist" : "artists")"
            
        case 2:
            
            // Albums
            let numFavorites = favoritesDelegate.numberOfFavoriteAlbums
            lblSummary.stringValue = "\(numFavorites)  favorite \(numFavorites == 1 ? "album" : "albums")"
            
        default:
            return
        }
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
