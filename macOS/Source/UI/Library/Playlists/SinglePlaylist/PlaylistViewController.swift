//
//  PlaylistViewController.swift
//  Aural
//
//  Copyright © 2023 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import Cocoa

class PlaylistViewController: NSViewController {
    
    override var nibName: String? {"Playlist"}
    
    @IBOutlet weak var rootContainer: NSBox!
    @IBOutlet weak var tabButtonsBox: NSBox!

    @IBOutlet weak var lblPlaylistName: NSTextField!
    
    // The tab group that switches between the 4 playlist views
    @IBOutlet weak var tabGroup: NSTabView!
    @IBOutlet weak var tableViewTabButton: TrackListTabButton!
    @IBOutlet weak var listViewTabButton: TrackListTabButton!
    
    private lazy var tabViewButtons: [TrackListTabButton] = [tableViewTabButton, listViewTabButton]
    
    @IBOutlet weak var lblTracksSummary: NSTextField!
    @IBOutlet weak var lblDurationSummary: NSTextField!
    
    // Spinner that shows progress when tracks are being added to any of the playlists.
    @IBOutlet weak var progressSpinner: NSProgressIndicator!
    
    @IBOutlet weak var controlsContainer: PlaylistControlsContainer!
    
    // The different playlist views
    @IBOutlet weak var tableViewController: PlaylistTracksViewController!
    
    unowned var playlist: Playlist! = nil {
        
        didSet {
            
            tableViewController.playlist = playlist
            lblPlaylistName.stringValue = playlist?.name ?? ""
            updateSummary()
        }
    }
    
    lazy var fileOpenDialog = DialogsAndAlerts.openFilesAndFoldersDialog
    
    private lazy var messenger: Messenger = Messenger(for: self)
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        if let tab0View = tabGroup.tabViewItem(at: 0).view {
            
            tab0View.addSubview(tableViewController.view)
            tableViewController.view.anchorToSuperview()
        }
        
        playlistsManager.loadPlaylists()
        
        doTabViewAction(tableViewTabButton)
        
        lblPlaylistName.font = systemFontScheme.captionFont
        lblTracksSummary.font = systemFontScheme.playlist.summaryFont
        lblDurationSummary.font = systemFontScheme.playlist.summaryFont
        
        controlsContainer.startTracking()
        
        messenger.subscribeAsync(to: .playlists_startedAddingTracks, handler: startedAddingTracks)
        messenger.subscribeAsync(to: .playlists_doneAddingTracks, handler: doneAddingTracks)
        
        messenger.subscribe(to: .playlists_updateSummary, handler: updateSummary)

        colorSchemesManager.registerObservers([rootContainer, tabButtonsBox], forProperty: \.backgroundColor)
        colorSchemesManager.registerObservers(tabViewButtons, forProperties: [\.backgroundColor, \.buttonColor, \.inactiveControlColor])
        colorSchemesManager.registerObserver(lblPlaylistName, forProperty: \.captionTextColor)
        colorSchemesManager.registerObservers([lblTracksSummary, lblDurationSummary], forProperty: \.secondaryTextColor)
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
    
    private func updateSummary() {
        
        guard let displayedPlaylist = self.playlist else {
            
            lblTracksSummary.stringValue = "0 tracks"
            lblDurationSummary.stringValue = "0:00"
            return
        }
        
        let numTracks = displayedPlaylist.size
        lblTracksSummary.stringValue = "\(numTracks) \(numTracks == 1 ? "track" : "tracks")"
        lblDurationSummary.stringValue = ValueFormatter.formatSecondsToHMS(displayedPlaylist.duration)
    }
    
    @IBAction func importFilesAndFoldersAction(_ sender: NSButton) {
        importFilesAndFolders()
    }
    
    @IBAction func tabViewAction(_ sender: TrackListTabButton) {
        doTabViewAction(sender)
    }
    
    private func doTabViewAction(_ sender: TrackListTabButton) {
        
        // Set sender button state, reset all other button states
        tabViewButtons.forEach {$0.unSelect()}
        sender.select()

        // Button tag is the tab index
        tabGroup.selectTabViewItem(at: sender.tag)
    }
    
    // Invokes the Open file dialog, to allow the user to add tracks/playlists to the app playlist
    func importFilesAndFolders() {
        
        guard let playlist = self.playlist, !playlist.isBeingModified else {return}
        
        if fileOpenDialog.runModal() == .OK {
            playlist.loadTracks(from: fileOpenDialog.urls)
        }
    }
}
