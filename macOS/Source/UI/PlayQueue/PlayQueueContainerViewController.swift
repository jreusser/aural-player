//
//  PlayQueueContainerViewController.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
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
    
    @IBOutlet weak var tabButtonsContainer: NSBox!
    
    // The tab group that switches between the 4 playlist views
    @IBOutlet weak var tabGroup: NSTabView!
    
    @IBOutlet weak var btnSimpleView: TrackListTabButton!
    @IBOutlet weak var btnExpandedView: TrackListTabButton!
    
    var buttonColorChangeReceivers: [ColorSchemePropertyChangeReceiver] = []
    
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
        
        initializeView()
        setUpTheming()
        initSubscriptions()
        
        updateSummary()
    }
    
    func initializeView() {
        
        if appModeManager.currentMode == .modular,
            let lblCaptionLeadingConstraint = lblCaption.superview?.constraints.first(where: {$0.firstAttribute == .leading}) {
            
            lblCaptionLeadingConstraint.constant = 23
        }
        
        let simpleView = simpleViewController.view
        let prettyView = expandedViewController.view
        
        for (index, view) in [simpleView, prettyView].enumerated() {
            
            tabGroup.tabViewItem(at: index).view?.addSubview(view)
            view.anchorToSuperview()
        }
        
        doSelectTab(at: playQueueUIState.currentView.rawValue)
        
        if playQueueDelegate.isBeingModified {
            startedAddingTracks()
        }
    }
    
    func setUpTheming() {
        
        buttonColorChangeReceivers = [btnSimpleView, btnExpandedView]
        
        fontSchemesManager.registerObserver(self)
        
        colorSchemesManager.registerSchemeObserver(self)
        colorSchemesManager.registerPropertyObserver(self, forProperties: [\.buttonColor, \.inactiveControlColor], changeReceivers: buttonColorChangeReceivers)
        colorSchemesManager.registerPropertyObserver(self, forProperty: \.backgroundColor, changeReceiver: tabButtonsContainer)
        colorSchemesManager.registerPropertyObserver(self, forProperty: \.captionTextColor, changeReceiver: lblCaption)
        colorSchemesManager.registerPropertyObserver(self, forProperty: \.secondaryTextColor, handler: secondaryTextColorChanged(_:))
    }
    
    func initSubscriptions() {
        
        messenger.subscribe(to: .PlayQueue.addTracks, handler: importFilesAndFolders)
        
        messenger.subscribe(to: .PlayQueue.removeTracks, handler: removeTracks)
        messenger.subscribe(to: .PlayQueue.cropSelection, handler: cropSelection)
        messenger.subscribe(to: .PlayQueue.removeAllTracks, handler: removeAllTracks)
        
        messenger.subscribe(to: .PlayQueue.enqueueAndPlayNow, handler: enqueueAndPlayNow(_:))
        messenger.subscribe(to: .PlayQueue.enqueueAndPlayNext, handler: enqueueAndPlayNext(_:))
        messenger.subscribe(to: .PlayQueue.enqueueAndPlayLater, handler: enqueueAndPlayLater(_:))
        
        messenger.subscribe(to: .PlayQueue.loadAndPlayNow, handler: loadAndPlayNow(_:))
        
        messenger.subscribe(to: .PlayQueue.playNext, handler: playNext)
        
        messenger.subscribe(to: .PlayQueue.playSelectedTrack, handler: playSelectedTrack)
        
        messenger.subscribe(to: .PlayQueue.selectAllTracks, handler: selectAllTracks)
        messenger.subscribe(to: .PlayQueue.clearSelection, handler: clearSelection)
        messenger.subscribe(to: .PlayQueue.invertSelection, handler: invertSelection)
        
        messenger.subscribe(to: .PlayQueue.pageUp, handler: pageUp)
        messenger.subscribe(to: .PlayQueue.pageDown, handler: pageDown)
        messenger.subscribe(to: .PlayQueue.scrollToTop, handler: scrollToTop)
        messenger.subscribe(to: .PlayQueue.scrollToBottom, handler: scrollToBottom)
        
        messenger.subscribe(to: .PlayQueue.showPlayingTrack, handler: showPlayingTrack)
        
        messenger.subscribe(to: .PlayQueue.moveTracksUp, handler: moveTracksUp)
        messenger.subscribe(to: .PlayQueue.moveTracksDown, handler: moveTracksDown)
        messenger.subscribe(to: .PlayQueue.moveTracksToTop, handler: moveTracksToTop)
        messenger.subscribe(to: .PlayQueue.moveTracksToBottom, handler: moveTracksToBottom)
        
        messenger.subscribe(to: .PlayQueue.search, handler: search)
        
        messenger.subscribe(to: .PlayQueue.exportAsPlaylistFile, handler: exportToPlaylistFile)
        
        messenger.subscribeAsync(to: .PlayQueue.startedAddingTracks, handler: startedAddingTracks)
        messenger.subscribeAsync(to: .PlayQueue.doneAddingTracks, handler: doneAddingTracks)
        
        messenger.subscribeAsync(to: .PlayQueue.tracksAdded, handler: updateSummary)
        
        messenger.subscribeAsync(to: .Player.trackTransitioned, handler: updateSummary)
        
        messenger.subscribe(to: .PlayQueue.updateSummary, handler: updateSummary)
    }
    
    func playSelectedTrack() {
        currentViewController.playSelectedTrack()
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
        messenger.publish(.PlayQueue.refresh)
        
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
    
    func startedAddingTracks() {
        
        progressSpinner.startAnimation(nil)
        progressSpinner.show()
    }
    
    func doneAddingTracks() {
        
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
        
        tabButtonsContainer.fillColor = systemColorScheme.backgroundColor
        
        lblCaption.textColor = systemColorScheme.captionTextColor
        updateSummary()
    }
    
    func secondaryTextColorChanged(_ newColor: PlatformColor) {
        updateSummary()
    }
}
