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
    
    @IBOutlet weak var tabGroup: NSTabView!
    
    lazy var tracksViewController: FavoriteTracksViewController = .init()
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        tabGroup.tabViewItem(at: 0).view?.addSubview(tracksViewController.view)
        tracksViewController.view.anchorToSuperview()
    }
}

extension NSUserInterfaceItemIdentifier {
    
    // Table view column identifiers
    static let cid_favoriteColumn: NSUserInterfaceItemIdentifier = NSUserInterfaceItemIdentifier("cid_favoriteColumn")
}

class FavoritesTableCellView: PresetsManagerTableCellView {
   
    func setInfoFor(favorite: Favorite) {
        
        if let trackFav = favorite as? FavoriteTrack {
            
            self.text = trackFav.track.displayName
            self.image = trackFav.track.art?.image ?? .imgPlayingArt
        }
    }
}
