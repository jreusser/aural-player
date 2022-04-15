//
//  PlaylistViewController.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import Cocoa

class PlaylistViewController: NSViewController, NSTableViewDelegate, NSTableViewDataSource, ColorSchemeObserver {

    @IBOutlet weak var playlistContainer: NSBox!
    @IBOutlet weak var playlistBox: NSBox!
    
    @IBOutlet weak var lblPlaylistName: NSTextField!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        lblPlaylistName.font = systemFontScheme.effects.unitCaptionFont
        
        colorSchemesManager.registerObserver(self, forProperties: [\.backgroundColor, \.captionTextColor])
    }
    
    func colorChanged(to newColor: PlatformColor, forProperty property: KeyPath<ColorScheme, PlatformColor>) {
        
        switch property {
            
        case \.backgroundColor:
            
            [playlistContainer, playlistBox].forEach {
                $0?.fillColor = newColor
            }
            
        case \.captionTextColor:
            
            lblPlaylistName.textColor = newColor
            
        default:
            
            return
        }
    }
}
