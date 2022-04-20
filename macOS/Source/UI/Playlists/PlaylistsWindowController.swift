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
    
    // The tab group that switches between the 4 playlist views
    @IBOutlet weak var tabGroup: AuralTabView!
    
    @IBOutlet weak var playlistNamesViewController: PlaylistNamesTableViewController!
    
    // Spinner that shows progress when tracks are being added to any of the playlists.
    @IBOutlet weak var progressSpinner: NSProgressIndicator!
    
    // The different playlist views
    @IBOutlet weak var tableViewController: PlaylistViewController!
    
    private lazy var messenger: Messenger = Messenger(for: self)
    
    override func windowDidLoad() {
        
        super.windowDidLoad()
        
        if let tab0View = tabGroup.tabViewItem(at: 0).view {
            
            tab0View.addSubview(tableViewController.view)
            tableViewController.view.anchorToSuperview()
        }
        
        playlistNamesViewController.tableViewController = tableViewController
        
        lblCaption.font = systemFontScheme.effects.unitCaptionFont
        
        messenger.subscribe(to: .playlists_startedAddingTracks, handler: startedAddingTracks)
        messenger.subscribe(to: .playlists_doneAddingTracks, handler: doneAddingTracks)

        colorSchemesManager.registerObserver(self, forProperties: [\.backgroundColor, \.captionTextColor])
        colorSchemesManager.registerObservers([btnClose, btnCreatePlaylist, btnDeleteSelectedPlaylists], forProperty: \.buttonColor)
    }
    
    @IBAction func closeAction(_ sender: Any) {
        windowLayoutsManager.toggleWindow(withId: .playlists)
    }
    
    // MARK: Notification handling
    
    private func startedAddingTracks() {
        
        progressSpinner.startAnimation(self)
        progressSpinner.show()
    }
    
    private func doneAddingTracks() {

        progressSpinner.hide()
        progressSpinner.stopAnimation(self)
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
}
