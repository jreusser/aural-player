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

class PlayQueueWindowController: NSWindowController {
    
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
    @IBOutlet weak var tabGroup: NSTabView!
    
    @IBOutlet weak var btnListView: PlayQueueTabButton!
    @IBOutlet weak var btnTableView: PlayQueueTabButton!
    
    @IBOutlet weak var compactViewController: CompactPlayQueueViewController!
    @IBOutlet weak var prettyViewController: PrettyPlayQueueViewController!
    
    private let playQueue: PlayQueueDelegateProtocol = playQueueDelegate
    
    private lazy var alertDialog: AlertWindowController = .instance
    
    private lazy var messenger: Messenger = Messenger(for: self)
    
    override func windowDidLoad() {
        
        super.windowDidLoad()
        
        theWindow.isMovableByWindowBackground = true
        
        let compactView = compactViewController.view
        let prettyView = prettyViewController.view
        
        for (index, view) in [compactView, prettyView].enumerated() {
            
            tabGroup.tabViewItem(at: index).view?.addSubview(view)
            view.anchorToSuperview()
        }
        
        [1, 0].forEach {tabGroup.selectTabViewItem(at: $0)}
        tabViewAction(btnTableView)
        
        colorSchemesManager.registerObservers([btnTableView, btnListView], forProperties: [\.buttonColor, \.inactiveControlColor])
        
        colorSchemesManager.registerObservers([rootContainer, tabButtonsContainer], forProperty: \.backgroundColor)
        colorSchemesManager.registerObserver(btnClose, forProperty: \.buttonColor)
        
        colorSchemesManager.registerObserver(lblCaption, forProperty: \.captionTextColor)
        colorSchemesManager.registerObservers([lblTracksSummary, lblDurationSummary], forProperty: \.secondaryTextColor)
        
        lblCaption.font = systemFontScheme.captionFont
        lblTracksSummary.font = Fonts.Player.infoBoxArtistAlbumFont
        lblDurationSummary.font = Fonts.Player.infoBoxArtistAlbumFont
        
        changeWindowCornerRadius(windowAppearanceState.cornerRadius)
        
        messenger.subscribe(to: .playQueue_exportAsPlaylistFile, handler: exportAsPlaylistFile)
        messenger.subscribe(to: .playQueue_removeAllTracks, handler: removeAllTracks)
        
        messenger.subscribeAsync(to: .playQueue_startedAddingTracks, handler: startedAddingTracks)
        messenger.subscribeAsync(to: .playQueue_doneAddingTracks, handler: doneAddingTracks)
        
        messenger.subscribeAsync(to: .playQueue_tracksAdded, handler: updateSummary)
        messenger.subscribeAsync(to: .playQueue_tracksRemoved, handler: updateSummary)
        
        messenger.subscribeAsync(to: .player_trackTransitioned, handler: updateSummary)
        
        messenger.subscribe(to: .playQueue_updateSummary, handler: updateSummary)
        
        messenger.subscribe(to: .applyFontScheme, handler: applyFontScheme(_:))
        messenger.subscribe(to: .windowAppearance_changeCornerRadius, handler: changeWindowCornerRadius(_:))
        
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
    
    private func applyFontScheme(_ scheme: FontScheme) {
        lblCaption.font = scheme.captionFont
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
        
        let tracksCardinalString = playQueue.size == 1 ? "track" : "tracks"
        
        if let playingTrackIndex = playQueue.currentTrackIndex {
            
            let playIconAttStr = "▶".attributed(font: futuristicFontSet.mainFont(size: 12), color: systemColorScheme.secondaryTextColor)
            let tracksSummaryAttStr = "  \(playingTrackIndex + 1) / \(playQueue.size) \(tracksCardinalString)".attributed(font: systemFontScheme.playlist.summaryFont, color: systemColorScheme.secondaryTextColor)
            
            lblTracksSummary.attributedStringValue = playIconAttStr + tracksSummaryAttStr
            
        } else {
            lblTracksSummary.stringValue = "\(playQueue.size) \(tracksCardinalString)"
        }
        
        lblDurationSummary.stringValue = ValueFormatter.formatSecondsToHMS(playQueue.duration)
    }
    
    override func destroy() {
        // TODO: 
    }
    
    private func changeWindowCornerRadius(_ radius: CGFloat) {
        rootContainer.cornerRadius = radius
    }
    
    // MARK: Actions ----------------------------------------------------------------------------------
    
    // Switches the tab group to a particular tab
    @IBAction func tabViewAction(_ sender: PlayQueueTabButton) {

        // Set sender button state, reset all other button states
        [btnTableView, btnListView].forEach {$0.unSelect()}
        sender.select()

        // Button tag is the tab index
        tabGroup.selectTabViewItem(at: sender.tag)
        lblCaption.stringValue = EffectsUnitType(rawValue: sender.tag)!.caption
    }
    
    @IBAction func closeAction(_ sender: NSButton) {
        windowLayoutsManager.toggleWindow(withId: .playQueue)
    }
}
