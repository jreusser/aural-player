//
//  PlaylistsViewController.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import Cocoa

class PlaylistsViewController: NSViewController {
    
    override var nibName: String? {"Playlists"}
    
    @IBOutlet weak var tabGroup: NSTabView!
    
    private lazy var messenger: Messenger = Messenger(for: self)
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        messenger.subscribe(to: .playlists_showPlaylist, handler: showPlaylist(named:))
    }
    
    override func destroy() {
        
        super.destroy()
        messenger.unsubscribeFromAll()
    }
    
    private func showPlaylist(named playlistName: String) {
        
        guard let playlist = playlistsManager.object(named: playlistName) else {return}
        
        for tab in tabGroup.tabViewItems {
            
            guard let controller = tab.viewController as? PlaylistViewController else {continue}
            
            if controller.playlist == playlist {
                
                tabGroup.selectTabViewItem(tab)
                return
            }
        }
        
        let newController = PlaylistViewController()
        newController.forceLoadingOfView()
        newController.playlist = playlist
        
        tabGroup.addTabViewItem(NSTabViewItem(viewController: newController))
        newController.view.anchorToSuperview()
        
        tabGroup.showLastTab()
    }
}
