//
//  PlayQueueWindowController.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import Cocoa

class PlayQueueWindowController: NSWindowController, ColorSchemeObserver {
    
    override var windowNibName: String? {"PlayQueueWindow"}
    
    @IBOutlet weak var btnClose: TintedImageButton!
    
    @IBOutlet weak var lblCaption: NSTextField!
    @IBOutlet weak var lblTracksSummary: NSTextField!
    @IBOutlet weak var lblDurationSummary: NSTextField!
    
    // Spinner that shows progress when tracks are being added to the play queue.
    @IBOutlet weak var progressSpinner: NSProgressIndicator!
    
    @IBOutlet weak var rootContainer: NSBox!
    @IBOutlet weak var tabButtonsContainer: NSBox!
    
    // The tab group that switches between the 4 playlist views
    @IBOutlet weak var tabGroup: AuralTabView!
    
    private var compactViewController: CompactPlayQueueViewController = .init()
    
    private let player: PlaybackDelegateProtocol = playbackDelegate
    private let playQueue: PlayQueueDelegateProtocol = playQueueDelegate
    
    private lazy var alertDialog: AlertWindowController = .instance
    
    private lazy var messenger: Messenger = Messenger(for: self)
    
    override func windowDidLoad() {
        
        super.windowDidLoad()
        
        let compactView = compactViewController.view
        tabGroup.addViewsForTabs([compactView])
        compactView.anchorToSuperview()
        
        colorSchemesManager.registerObserver(self, forProperties: [\.backgroundColor, \.captionTextColor])
        colorSchemesManager.registerObserver(btnClose, forProperty: \.buttonColor)
        
        lblCaption.font = systemFontScheme.effects.unitCaptionFont
        
        lblTracksSummary.font = Fonts.Player.infoBoxArtistAlbumFont
        lblTracksSummary.textColor = systemColorScheme.secondaryTextColor
        
        lblDurationSummary.font = Fonts.Player.infoBoxArtistAlbumFont
        lblDurationSummary.textColor = systemColorScheme.secondaryTextColor
        
        messenger.subscribe(to: .playQueue_exportAsPlaylistFile, handler: exportAsPlaylistFile)
        messenger.subscribe(to: .playQueue_removeAllTracks, handler: removeAllTracks)
        
        messenger.subscribeAsync(to: .playQueue_startedAddingTracks, handler: startedAddingTracks)
        messenger.subscribeAsync(to: .playQueue_doneAddingTracks, handler: doneAddingTracks)
        
        messenger.subscribeAsync(to: .playQueue_trackAdded, handler: updateSummary)
        messenger.subscribeAsync(to: .playQueue_tracksAdded, handler: updateSummary)
        messenger.subscribeAsync(to: .playQueue_tracksRemoved, handler: updateSummary)
        
        messenger.subscribeAsync(to: .player_trackTransitioned, handler: updateSummary)
        
        updateSummary()
    }
    
    // TODO: REFACTORING - move this to a generic TableWindowController.
    private func exportAsPlaylistFile() {
        
        // Make sure there is at least one track to save.
        guard playQueue.size > 0, !checkIfPlayQueueIsBeingModified() else {return}
        
        let saveDialog = DialogsAndAlerts.savePlaylistDialog
        
        if saveDialog.runModal() == .OK,
           let newFileURL = saveDialog.url {
            
            playQueue.exportToFile(newFileURL)
        }
    }
    
    // Removes all items from the playlist
    func removeAllTracks() {
        
        guard playQueue.size > 0, !checkIfPlayQueueIsBeingModified() else {return}
        
        playQueue.removeAllTracks()
        
        // Tell the play queue UI to refresh its views.
        messenger.publish(.playQueue_refresh)
        
        updateSummary()
    }
    
    private func checkIfPlayQueueIsBeingModified() -> Bool {
        
        let playQueueBeingModified = playQueue.isBeingModified
        
        if playQueueBeingModified {
            alertDialog.showAlert(.error, "Play Queue not modified", "The Play Queue cannot be modified while tracks are being added", "Please wait till the Play Queue is done adding tracks ...")
        }
        
        return playQueueBeingModified
    }
    
    // MARK: Notification handling ----------------------------------------------------------------------------------
    
    func colorChanged(to newColor: PlatformColor, forProperty property: KeyPath<ColorScheme, PlatformColor>) {
        
        switch property {
            
        case \.backgroundColor:
            
            rootContainer.fillColor = newColor
            tabButtonsContainer.fillColor = newColor
            
        case \.captionTextColor:
            
            lblCaption.textColor = newColor
         
        default:
            
            return
        }
    }
    
    private func startedAddingTracks() {
        
        progressSpinner.startAnimation(nil)
        progressSpinner.show()
    }
    
    private func doneAddingTracks() {
        
        progressSpinner.hide()
        progressSpinner.stopAnimation(nil)
    }
    
    private func updateSummary() {
        
        if let playingTrack = player.playingTrack, let index = playQueue.indexOfTrack(playingTrack) {
            lblTracksSummary.stringValue = "▶  \(index + 1) / \(playQueue.size) tracks"
            
        } else {
            lblTracksSummary.stringValue = "\(playQueue.size) tracks"
        }
        
        lblDurationSummary.stringValue = ValueFormatter.formatSecondsToHMS(playQueue.duration)
    }
    
    override func destroy() {
        // TODO: 
    }
    
    // MARK: Actions ----------------------------------------------------------------------------------
    
    @IBAction func closeAction(_ sender: NSButton) {
        windowLayoutsManager.toggleWindow(withId: .playQueue)
    }
}
