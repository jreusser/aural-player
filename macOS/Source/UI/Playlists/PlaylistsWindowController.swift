//
//  PlaylistsWindowController.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import Cocoa

class PlaylistsWindowController: NSWindowController, ColorSchemeObserver {
    
    override var windowNibName: String? {"PlaylistsWindow"}

    @IBOutlet weak var rootContainer: NSBox!
    @IBOutlet weak var controlsBox: NSBox!

    @IBOutlet weak var btnClose: TintedImageButton!
    @IBOutlet weak var btnCreatePlaylist: TintedIconMenuItem!
    @IBOutlet weak var btnDeleteSelectedPlaylists: TintedImageButton!
    
    @IBOutlet weak var lblCaption: NSTextField!
    
    override func windowDidLoad() {
        
        super.windowDidLoad()
        
        lblCaption.font = systemFontScheme.effects.unitCaptionFont

        colorSchemesManager.registerObserver(self, forProperties: [\.backgroundColor, \.captionTextColor])
        colorSchemesManager.registerObservers([btnClose, btnCreatePlaylist, btnDeleteSelectedPlaylists], forProperty: \.buttonColor)
    }
    
    func colorChanged(to newColor: PlatformColor, forProperty property: KeyPath<ColorScheme, PlatformColor>) {
        
        switch property {
            
        case \.backgroundColor:
            
            [rootContainer, controlsBox].forEach {
                $0.fillColor = newColor
            }
            
        case \.captionTextColor:
            
            lblCaption.textColor = newColor
            
        default:
            
            return
        }
    }
    
    @IBAction func closeAction(_ sender: Any) {
        windowLayoutsManager.toggleWindow(withId: .playlists)
    }
}
