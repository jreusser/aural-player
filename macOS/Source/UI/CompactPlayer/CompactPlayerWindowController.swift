//
//  CompactPlayerWindowController.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//

import AppKit

class CompactPlayerWindowController: NSWindowController {
    
    override var windowNibName: NSNib.Name? {"CompactPlayerWindow"}
    
    @IBOutlet weak var rootContainerBox: NSBox!
    
    @IBOutlet weak var logoImage: TintedImageView!
    @IBOutlet weak var btnQuit: TintedImageButton!
    @IBOutlet weak var btnMinimize: TintedImageButton!
    @IBOutlet weak var presentationModeMenuItem: TintedIconMenuItem!
    @IBOutlet weak var settingsMenuIconItem: TintedIconMenuItem!
    
    @IBOutlet weak var tabView: NSTabView!
    private let playerViewController: CompactPlayerViewController = .init()
    private let playQueueViewController: CompactPlayQueueViewController = .init()
    private lazy var effectsSheetViewController: EffectsSheetViewController = .init()
    
    @IBOutlet weak var showPlayerMenuItem: NSMenuItem!
    @IBOutlet weak var showPlayQueueMenuItem: NSMenuItem!
    
    @IBOutlet weak var scrollingEnabledMenuItem: NSMenuItem!
    @IBOutlet weak var showSeekPositionMenuItem: NSMenuItem!
    @IBOutlet weak var seekPositionDisplayTypeMenuItem: NSMenuItem!
    
    @IBOutlet weak var timeElapsedMenuItem: SeekPositionDisplayTypeMenuItem!
    @IBOutlet weak var timeRemainingMenuItem: SeekPositionDisplayTypeMenuItem!
    @IBOutlet weak var trackDurationMenuItem: SeekPositionDisplayTypeMenuItem!
    
    @IBOutlet weak var cornerRadiusStepper: NSStepper!
    @IBOutlet weak var lblCornerRadius: NSTextField!
    
    var seekPositionDisplayTypeItems: [NSMenuItem] = []
    
    lazy var messenger = Messenger(for: self)
    
    private var appMovingWindow: Bool = false
    
    var eventMonitor: EventMonitor! = EventMonitor()
    
    override func windowDidLoad() {
        
        window?.isMovableByWindowBackground = true
        window?.center()
        
        initFromPersistentState()
        
        tabView.tabViewItem(at: 0).view?.addSubview(playerViewController.view)
        tabView.tabViewItem(at: 1).view?.addSubview(playQueueViewController.view)
        
        playQueueViewController.view.anchorToSuperview()
        
        tabView.selectTabViewItem(at: 0)
        
        // View settings menu items
        timeElapsedMenuItem.displayType = .elapsed
        timeRemainingMenuItem.displayType = .remaining
        trackDurationMenuItem.displayType = .duration
        
        seekPositionDisplayTypeItems = [timeElapsedMenuItem, timeRemainingMenuItem, trackDurationMenuItem]
        
        colorSchemesManager.registerSchemeObserver(self)
        
        messenger.subscribe(to: .effects_sheetDismissed, handler: effectsSheetDismissed)
        
        setUpEventHandling()
    }
    
    private func initFromPersistentState() {
        
        if let rememberedLocation = compactPlayerUIState.windowLocation {
            window?.setFrameOrigin(rememberedLocation)
        }
        
        changeWindowCornerRadius(compactPlayerUIState.cornerRadius)
    }
    
    @IBAction func cornerRadiusStepperAction(_ sender: NSStepper) {
        
        let cgFloatValue = CGFloat(cornerRadiusStepper.floatValue)
        
        compactPlayerUIState.cornerRadius = cgFloatValue
        changeWindowCornerRadius(cgFloatValue)
        lblCornerRadius.stringValue = "\(cornerRadiusStepper.integerValue)px"
    }
    
    @IBAction func showPlayerAction(_ sender: NSMenuItem) {
        
        tabView.selectTabViewItem(at: 0)
        eventMonitor.resumeMonitoring()
    }
    
    @IBAction func showPlayQueueAction(_ sender: NSMenuItem) {
        
        tabView.selectTabViewItem(at: 1)
        eventMonitor.pauseMonitoring()
    }
    
    @IBAction func showEffectsAction(_ sender: NSMenuItem) {
        
        switch compactPlayerUIState.displayedTab {
            
        case .player:
            playerViewController.presentAsSheet(effectsSheetViewController)
            
        case .playQueue:
            playQueueViewController.presentAsSheet(effectsSheetViewController)
            
        case .search:
            // TODO: Implement this!
            return
            
        default:
            return
        }
        
        compactPlayerUIState.displayedTab = .effects
        eventMonitor.pauseMonitoring()
    }
    
    override func destroy() {
        
        close()
        playerViewController.destroy()
        
        eventMonitor.stopMonitoring()
        eventMonitor = nil
        
        messenger.unsubscribeFromAll()
    }
    
    @IBAction func modularModeAction(_ sender: AnyObject) {
        
        transferViewState()
        appModeManager.presentMode(.modular)
    }
    
    @IBAction func unifiedModeAction(_ sender: AnyObject) {
        
        transferViewState()
        appModeManager.presentMode(.unified)
    }
    
    @IBAction func menuBarModeAction(_ sender: AnyObject) {
        
        transferViewState()
        appModeManager.presentMode(.menuBar)
    }
    
    @IBAction func controlBarModeAction(_ sender: AnyObject) {
        
        transferViewState()
        appModeManager.presentMode(.controlBar)
    }
    
    // Minimizes the window (and any child windows)
    @IBAction func minimizeAction(_ sender: AnyObject) {
        theWindow.miniaturize(self)
    }
    
    @IBAction func quitAction(_ sender: AnyObject) {
        
        transferViewState()
        NSApp.terminate(self)
    }
    
    private func transferViewState() {
        compactPlayerUIState.windowLocation = theWindow.frame.origin
    }
    
    private func changeWindowCornerRadius(_ radius: CGFloat) {
        rootContainerBox.cornerRadius = radius
    }
    
    private func effectsSheetDismissed() {
        
        eventMonitor.resumeMonitoring()
        updateDisplayedTabState()
    }
    
    private func updateDisplayedTabState() {
        
        // NOTE: Effects does not have its own tab (it's displayed in a separate sheet view).
        
        switch tabView.selectedIndex {
            
        case 0:
            compactPlayerUIState.displayedTab = .player
            
        case 1:
            compactPlayerUIState.displayedTab = .playQueue
            
        case 2:
            compactPlayerUIState.displayedTab = .search
            
        default:
            compactPlayerUIState.displayedTab = .player
        }
    }
}

extension CompactPlayerWindowController: ColorSchemeObserver {
    
    func colorSchemeChanged() {
        
        rootContainerBox.fillColor = systemColorScheme.backgroundColor
        logoImage.contentTintColor = systemColorScheme.captionTextColor
        
        [btnQuit, btnMinimize].forEach {
            $0.contentTintColor = systemColorScheme.buttonColor
        }
        
        [presentationModeMenuItem, settingsMenuIconItem].forEach {
            $0?.colorChanged(systemColorScheme.buttonColor)
        }
    }
}

extension CompactPlayerWindowController: NSTabViewDelegate {
    
    func tabView(_ tabView: NSTabView, didSelect tabViewItem: NSTabViewItem?) {
        updateDisplayedTabState()
    }
}
