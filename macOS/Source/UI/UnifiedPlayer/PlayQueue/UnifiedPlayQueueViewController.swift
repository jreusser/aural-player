//
//  UnifiedPlayQueueViewController.swift
//  Aural
//
//  Copyright © 2023 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import Cocoa

class UnifiedPlayQueueViewController: NSViewController, FontSchemePropertyObserver, ColorSchemePropertyObserver {
    
    override var nibName: String? {"UnifiedPlayQueue"}
    
    @IBOutlet weak var lblCaption: NSTextField!
    @IBOutlet weak var lblTracksSummary: NSTextField!
    @IBOutlet weak var lblDurationSummary: NSTextField!
    
    // Spinner that shows progress when tracks are being added to the play queue.
    @IBOutlet weak var progressSpinner: NSProgressIndicator!
    
    @IBOutlet weak var rootContainer: NSBox!
    @IBOutlet weak var tabButtonsContainer: NSBox!
    
    // The tab group that switches between the 4 playlist views
    @IBOutlet weak var tabGroup: NSTabView!
    
    @IBOutlet weak var btnListView: TrackListTabButton!
    @IBOutlet weak var btnTableView: TrackListTabButton!
    
    lazy var tabButtons: [TrackListTabButton] = [btnTableView, btnListView]
    
    @IBOutlet weak var sortOrderMenuItemView: SortOrderMenuItemView!
    
    @IBOutlet weak var tableViewController: PlayQueueTableViewController!
    @IBOutlet weak var listViewController: PlayQueueListViewController!
    lazy var controllers: [PlayQueueViewController] = [tableViewController, listViewController]
    
    lazy var fileOpenDialog = DialogsAndAlerts.openFilesAndFoldersDialog
    
    lazy var alertDialog: AlertWindowController = .instance
    
    lazy var saveDialog = DialogsAndAlerts.savePlaylistDialog
    
    var currentViewController: PlayQueueViewController {
        tabGroup.selectedIndex == 0 ? tableViewController : listViewController
    }
    
    lazy var messenger: Messenger = Messenger(for: self)
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        let compactView = tableViewController.view
        let prettyView = listViewController.view
        
        for (index, view) in [compactView, prettyView].enumerated() {
            
            tabGroup.tabViewItem(at: index).view?.addSubview(view)
            view.anchorToSuperview()
        }
        
        doSelectTab(at: playQueueUIState.currentView.rawValue)
        
        fontSchemesManager.registerObserver(lblCaption, forProperty: \.captionFont)
        fontSchemesManager.registerObserver(self, forProperty: \.playQueueSecondaryFont)
        
        colorSchemesManager.registerObservers([btnTableView, btnListView], forProperties: [\.buttonColor, \.inactiveControlColor])
        
        colorSchemesManager.registerObservers([rootContainer, tabButtonsContainer], forProperty: \.backgroundColor)
        
        colorSchemesManager.registerObserver(lblCaption, forProperty: \.captionTextColor)
        colorSchemesManager.registerObserver(self, forProperty: \.secondaryTextColor)
        
        messenger.subscribe(to: .playQueue_addTracks, handler: importFilesAndFolders)
        
        messenger.subscribe(to: .playQueue_removeTracks, handler: removeTracks)
        messenger.subscribe(to: .playQueue_cropSelection, handler: cropSelection)
        messenger.subscribe(to: .playQueue_removeAllTracks, handler: removeAllTracks)
        
        messenger.subscribe(to: .playQueue_enqueueAndPlayNow, handler: enqueueAndPlayNow(_:))
        messenger.subscribe(to: .playQueue_enqueueAndPlayNext, handler: enqueueAndPlayNext(_:))
        messenger.subscribe(to: .playQueue_enqueueAndPlayLater, handler: enqueueAndPlayLater(_:))
        
        messenger.subscribe(to: .playQueue_loadAndPlayNow, handler: loadAndPlayNow(_:))
        
        messenger.subscribe(to: .playQueue_playNext, handler: playNext)
        
        messenger.subscribe(to: .playQueue_moveTracksUp, handler: moveTracksUp)
        messenger.subscribe(to: .playQueue_moveTracksDown, handler: moveTracksDown)
        messenger.subscribe(to: .playQueue_moveTracksToTop, handler: moveTracksToTop)
        messenger.subscribe(to: .playQueue_moveTracksToBottom, handler: moveTracksToBottom)
        
        messenger.subscribe(to: .playQueue_exportAsPlaylistFile, handler: exportAsPlaylistFile)
        
        messenger.subscribeAsync(to: .playQueue_startedAddingTracks, handler: startedAddingTracks)
        messenger.subscribeAsync(to: .playQueue_doneAddingTracks, handler: doneAddingTracks)
        
        messenger.subscribeAsync(to: .playQueue_tracksAdded, handler: updateSummary)
        messenger.subscribeAsync(to: .playQueue_tracksRemoved, handler: updateSummary)
        
        messenger.subscribeAsync(to: .player_trackTransitioned, handler: updateSummary)
        
        messenger.subscribe(to: .playQueue_updateSummary, handler: updateSummary)
        
        updateSummary()
    }
    
    // TODO: REFACTORING - move this to a generic TableWindowController.
    private func exportAsPlaylistFile() {
        
        // Make sure there is at least one track to save.
        guard playQueueDelegate.size > 0, !checkIfPlayQueueIsBeingModified() else {return}
        
        let saveDialog = DialogsAndAlerts.savePlaylistDialog
        
        if saveDialog.runModal() == .OK,
           let newFileURL = saveDialog.url {
            
            playQueueDelegate.exportToFile(newFileURL)
        }
    }
    
    // Removes all items from the playlist
    func removeAllTracks() {
        
        guard playQueueDelegate.size > 0, !checkIfPlayQueueIsBeingModified() else {return}
        
        playQueueDelegate.removeAllTracks()
        
        // Tell the play queue UI to refresh its views.
        messenger.publish(.playQueue_refresh)
        
        updateSummary()
    }
    
    private func checkIfPlayQueueIsBeingModified() -> Bool {
        
        let playQueueBeingModified = playQueueDelegate.isBeingModified
        
        if playQueueBeingModified {
            alertDialog.showAlert(.error, "Play Queue not modified", "The Play Queue cannot be modified while tracks are being added", "Please wait till the Play Queue is done adding tracks ...")
        }
        
        return playQueueBeingModified
    }
    
    // MARK: Notification handling ----------------------------------------------------------------------------------
    
    func fontChanged(to newFont: PlatformFont, forProperty property: KeyPath<FontScheme, PlatformFont>) {
        updateSummary()
    }
    
    func colorChanged(to newColor: PlatformColor, forProperty property: KeyPath<ColorScheme, PlatformColor>) {
        updateSummary()
    }

    private func startedAddingTracks() {
        
        progressSpinner.startAnimation(nil)
        progressSpinner.show()
    }
    
    private func doneAddingTracks() {
        
        progressSpinner.hide()
        progressSpinner.stopAnimation(nil)
    }
    
    func updateSummary() {
        
        let tracksCardinalString = playQueueDelegate.size == 1 ? "track" : "tracks"
        
        if let playingTrackIndex = playQueueDelegate.currentTrackIndex {
            
            let playIconAttStr = "▶".attributed(font: futuristicFontSet.mainFont(size: 12), color: systemColorScheme.secondaryTextColor)
            let tracksSummaryAttStr = "  \(playingTrackIndex + 1) / \(playQueueDelegate.size) \(tracksCardinalString)".attributed(font: systemFontScheme.playQueueSecondaryFont,
                                                                                                                          color: systemColorScheme.secondaryTextColor)
            
            lblTracksSummary.attributedStringValue = playIconAttStr + tracksSummaryAttStr
            
        } else {
            
            lblTracksSummary.stringValue = "\(playQueueDelegate.size) \(tracksCardinalString)"
            lblTracksSummary.font = systemFontScheme.playQueueSecondaryFont
            lblTracksSummary.textColor = systemColorScheme.secondaryTextColor
        }
        
        lblDurationSummary.stringValue = ValueFormatter.formatSecondsToHMS(playQueueDelegate.duration)
        lblDurationSummary.font = systemFontScheme.playQueueSecondaryFont
        lblDurationSummary.textColor = systemColorScheme.secondaryTextColor
    }
    
    override func destroy() {
        messenger.unsubscribeFromAll()
    }
}
