//
//  PlaylistContainerViewController.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import Cocoa

class PlaylistContainerViewController: NSViewController {

    @IBOutlet weak var playlistContainer: NSBox!
    
    @IBOutlet weak var lblPlaylistName: NSTextField!
    
    var playlist: Playlist? = nil {
        
        didSet {
            
            guard let thePlaylist = playlist else {
                
                playlistContainer.hide()
                return
            }
            
            lblPlaylistName.stringValue = thePlaylist.name
            playlistContainer.show()
        }
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        lblPlaylistName.font = systemFontScheme.effects.unitCaptionFont
        
        colorSchemesManager.registerObserver(playlistContainer, forProperty: \.backgroundColor)
        colorSchemesManager.registerObserver(lblPlaylistName, forProperty: \.captionTextColor)
    }
}
