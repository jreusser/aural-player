//
//  PlayQueueContainerViewController.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//

import Cocoa

class PlayQueueContainerViewController: NSViewController {
    
    override var nibName: String? {"PlayQueueContainer"}
    
    @IBOutlet weak var lblCaption: NSTextField!
    @IBOutlet weak var lblTracksSummary: NSTextField!
    @IBOutlet weak var lblDurationSummary: NSTextField!
    
    // Spinner that shows progress when tracks are being added to the play queue.
    @IBOutlet weak var progressSpinner: NSProgressIndicator!
    
    @IBOutlet weak var rootContainer: NSBox!
    @IBOutlet weak var tabButtonsContainer: NSBox!
    
    private lazy var backgroundColorChangeReceivers: [ColorSchemePropertyChangeReceiver] = [rootContainer, tabButtonsContainer]
    
    // The tab group that switches between the 4 playlist views
    @IBOutlet weak var tabGroup: NSTabView!
    
    @IBOutlet weak var btnSimpleView: TrackListTabButton!
    @IBOutlet weak var btnExpandedView: TrackListTabButton!
    
    private lazy var buttonColorChangeReceivers: [ColorSchemePropertyChangeReceiver] = [btnSimpleView, btnExpandedView]
    
    lazy var tabButtons: [TrackListTabButton] = [btnSimpleView, btnExpandedView]
    
    @IBOutlet weak var sortOrderMenuItemView: SortOrderMenuItemView!
    
    @IBOutlet weak var simpleViewController: PlayQueueSimpleViewController!
    @IBOutlet weak var expandedViewController: PlayQueueExpandedViewController!
    lazy var controllers: [PlayQueueViewController] = [simpleViewController, expandedViewController]
    
    lazy var searchWindowController: SearchWindowController = .shared
    
    lazy var fileOpenDialog = DialogsAndAlerts.openFilesAndFoldersDialog
    
    lazy var alertDialog: AlertWindowController = .instance
    
    lazy var saveDialog = DialogsAndAlerts.savePlaylistDialog
    
    var currentViewController: PlayQueueViewController {
        tabGroup.selectedIndex == 0 ? simpleViewController : expandedViewController
    }
    
    lazy var messenger: Messenger = Messenger(for: self)
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        let compactView = simpleViewController.view
        let prettyView = expandedViewController.view
        
        for (index, view) in [compactView, prettyView].enumerated() {
            
            tabGroup.tabViewItem(at: index).view?.addSubview(view)
            view.anchorToSuperview()
        }
        
        doSelectTab(at: playQueueUIState.currentView.rawValue)
        
        fontSchemesManager.registerObserver(self)
        
        colorSchemesManager.registerSchemeObserver(self)
        colorSchemesManager.registerPropertyObserver(self, forProperties: [\.buttonColor, \.inactiveControlColor], changeReceivers: buttonColorChangeReceivers)
        colorSchemesManager.registerPropertyObserver(self, forProperty: \.backgroundColor, changeReceivers: backgroundColorChangeReceivers)
        colorSchemesManager.registerPropertyObserver(self, forProperty: \.captionTextColor, changeReceiver: lblCaption)
        colorSchemesManager.registerPropertyObserver(self, forProperty: \.secondaryTextColor, handler: secondaryTextColorChanged(_:))
        
        messenger.subscribe(to: .playQueue_addTracks, handler: importFilesAndFolders)
        
        messenger.subscribe(to: .playQueue_removeTracks, handler: removeTracks)
        messenger.subscribe(to: .playQueue_cropSelection, handler: cropSelection)
        messenger.subscribe(to: .playQueue_removeAllTracks, handler: removeAllTracks)
        
        messenger.subscribe(to: .playQueue_enqueueAndPlayNow, handler: enqueueAndPlayNow(_:))
        messenger.subscribe(to: .playQueue_enqueueAndPlayNext, handler: enqueueAndPlayNext(_:))
        messenger.subscribe(to: .playQueue_enqueueAndPlayLater, handler: enqueueAndPlayLater(_:))
        
        messenger.subscribe(to: .playQueue_loadAndPlayNow, handler: loadAndPlayNow(_:))
        
        messenger.subscribe(to: .playQueue_playNext, handler: playNext)
        
        messenger.subscribe(to: .playQueue_playSelectedTrack, handler: playSelectedTrack)
        
        messenger.subscribe(to: .playQueue_selectAllTracks, handler: selectAllTracks)
        messenger.subscribe(to: .playQueue_clearSelection, handler: clearSelection)
        messenger.subscribe(to: .playQueue_invertSelection, handler: invertSelection)
        
        messenger.subscribe(to: .playQueue_pageUp, handler: pageUp)
        messenger.subscribe(to: .playQueue_pageDown, handler: pageDown)
        messenger.subscribe(to: .playQueue_scrollToTop, handler: scrollToTop)
        messenger.subscribe(to: .playQueue_scrollToBottom, handler: scrollToBottom)
        
        messenger.subscribe(to: .playQueue_showPlayingTrack, handler: showPlayingTrack)
        
        messenger.subscribe(to: .playQueue_moveTracksUp, handler: moveTracksUp)
        messenger.subscribe(to: .playQueue_moveTracksDown, handler: moveTracksDown)
        messenger.subscribe(to: .playQueue_moveTracksToTop, handler: moveTracksToTop)
        messenger.subscribe(to: .playQueue_moveTracksToBottom, handler: moveTracksToBottom)
        
        messenger.subscribe(to: .playQueue_search, handler: search)
        
        messenger.subscribe(to: .playQueue_exportAsPlaylistFile, handler: exportAsPlaylistFile)
        
        messenger.subscribeAsync(to: .playQueue_startedAddingTracks, handler: startedAddingTracks)
        messenger.subscribeAsync(to: .playQueue_doneAddingTracks, handler: doneAddingTracks)
        
        messenger.subscribeAsync(to: .playQueue_tracksAdded, handler: updateSummary)
        messenger.subscribeAsync(to: .playQueue_tracksRemoved, handler: updateSummary)
        
        messenger.subscribeAsync(to: .player_trackTransitioned, handler: updateSummary)
        
        messenger.subscribe(to: .playQueue_updateSummary, handler: updateSummary)
        
        updateSummary()
    }
    
    func playSelectedTrack() {
        currentViewController.playSelectedTrack()
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
    
    func selectAllTracks() {
        currentViewController.selectAll()
    }
    
    func clearSelection() {
        currentViewController.clearSelection()
    }
    
    func invertSelection() {
        currentViewController.invertSelection()
    }
    
    // Removes all items from the playlist
    func removeAllTracks() {
        
        guard playQueueDelegate.size > 0, !checkIfPlayQueueIsBeingModified() else {return}
        
        playQueueDelegate.removeAllTracks()
        
        // Tell the play queue UI to refresh its views.
        messenger.publish(.playQueue_refresh)
        
        updateSummary()
    }
    
    func showPlayingTrack() {
        currentViewController.showPlayingTrack()
    }
    
    func pageUp() {
        currentViewController.pageUp()
    }
    
    func pageDown() {
        currentViewController.pageDown()
    }
    
    func scrollToTop() {
        currentViewController.scrollToTop()
    }
    
    func scrollToBottom() {
        currentViewController.scrollToBottom()
    }
    
    private func checkIfPlayQueueIsBeingModified() -> Bool {
        
        let playQueueBeingModified = playQueueDelegate.isBeingModified
        
        if playQueueBeingModified {
            alertDialog.showAlert(.error, "Play Queue not modified", "The Play Queue cannot be modified while tracks are being added", "Please wait till the Play Queue is done adding tracks ...")
        }
        
        return playQueueBeingModified
    }
    
    // MARK: Notification handling ----------------------------------------------------------------------------------
    
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
            let tracksSummaryAttStr = "  \(playingTrackIndex + 1) / \(playQueueDelegate.size) \(tracksCardinalString)".attributed(font: systemFontScheme.smallFont,
                                                                                                                                  color: systemColorScheme.secondaryTextColor)
            
            lblTracksSummary.attributedStringValue = playIconAttStr + tracksSummaryAttStr
            
        } else {
            
            lblTracksSummary.stringValue = "\(playQueueDelegate.size) \(tracksCardinalString)"
            lblTracksSummary.font = systemFontScheme.smallFont
            lblTracksSummary.textColor = systemColorScheme.secondaryTextColor
        }
        
        lblDurationSummary.stringValue = ValueFormatter.formatSecondsToHMS(playQueueDelegate.duration)
        lblDurationSummary.font = systemFontScheme.smallFont
        lblDurationSummary.textColor = systemColorScheme.secondaryTextColor
    }
    
    func search() {
        searchWindowController.showWindow(self)
    }
    
    override func destroy() {
        
        controllers.forEach {$0.destroy()}
        messenger.unsubscribeFromAll()
    }
}

extension PlayQueueContainerViewController: NSTabViewDelegate {
    
    func tabView(_ tabView: NSTabView, didSelect tabViewItem: NSTabViewItem?) {
        
        playQueueUIState.currentView = tabGroup.selectedIndex == 0 ? .simple : .expanded
    }
}

extension PlayQueueContainerViewController: FontSchemeObserver {
    
    func fontSchemeChanged() {
        
        lblCaption.font = systemFontScheme.captionFont
        updateSummary()
    }
}

extension PlayQueueContainerViewController: ColorSchemeObserver {
    
    func colorSchemeChanged() {
        
        [btnSimpleView, btnExpandedView].forEach {
            $0.redraw()
        }
        
        backgroundColorChangeReceivers.forEach {
            $0.colorChanged(systemColorScheme.backgroundColor)
        }
        
        lblCaption.textColor = systemColorScheme.captionTextColor
        updateSummary()
    }
    
    func secondaryTextColorChanged(_ newColor: PlatformColor) {
        updateSummary()
    }
}
