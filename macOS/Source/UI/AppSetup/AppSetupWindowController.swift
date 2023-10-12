//
//  AppSetupWindowController.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import Cocoa

class AppSetupWindowController: NSWindowController {
    
    override var windowNibName: String? {"AppSetupWindow"}
    
//    @IBOutlet weak var tabView: AuralTabView!
    
//    private let playlistPrefsView: PreferencesViewProtocol = PlaylistPreferencesViewController()
//    private let playbackPrefsView: PreferencesViewProtocol = PlaybackPreferencesViewController()
//    private let soundPrefsView: PreferencesViewProtocol = SoundPreferencesViewController()
//    private let viewPrefsView: PreferencesViewProtocol = ViewPreferencesViewController()
//    private let historyPrefsView: PreferencesViewProtocol = HistoryPreferencesViewController()
//    private let controlsPrefsView: PreferencesViewProtocol = ControlsPreferencesViewController()
//    private let metadataPrefsView: PreferencesViewProtocol = MetadataPreferencesViewController()
    
//    private var subViews: [PreferencesViewProtocol] = []
    private lazy var messenger: Messenger = Messenger(for: self)
    
    override func windowDidLoad() {
        
        super.windowDidLoad()
        
        window?.isMovableByWindowBackground = true
        window?.center()
        
//        subViews = [playlistPrefsView, playbackPrefsView, soundPrefsView, viewPrefsView, historyPrefsView, controlsPrefsView, metadataPrefsView]
//        tabView.addViewsForTabs(subViews.map {$0.preferencesView})
    }
    
    @IBAction func skipSetupAction(_ sender: Any) {
        
        close()
        messenger.publish(.appSetup_completed)
    }
}
