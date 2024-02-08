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
    
    @IBOutlet weak var mainMenu: NSMenu!
    
    @IBOutlet weak var rootContainerBox: NSBox!
    
    @IBOutlet weak var logoImage: TintedImageView!
    @IBOutlet weak var btnQuit: TintedImageButton!
    @IBOutlet weak var btnMinimize: TintedImageButton!
    @IBOutlet weak var presentationModeMenuItem: TintedIconMenuItem!
    @IBOutlet weak var settingsMenuIconItem: TintedIconMenuItem!
    
    @IBOutlet weak var tabView: NSTabView!
    let playerViewController: CompactPlayerViewController = .init()
    let playQueueViewController: CompactPlayQueueViewController = .init()
    lazy var effectsSheetViewController: EffectsSheetViewController = .init()
    
    lazy var messenger = Messenger(for: self)
    
    private var appMovingWindow: Bool = false
    
    var eventMonitor: EventMonitor! = EventMonitor()
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        NSApp.mainMenu = self.mainMenu
    }
    
    override func windowDidLoad() {
        
        window?.isMovableByWindowBackground = true
        window?.center()
        
        initFromPersistentState()
        
        tabView.tabViewItem(at: 0).view?.addSubview(playerViewController.view)
        tabView.tabViewItem(at: 1).view?.addSubview(playQueueViewController.view)
        
        playQueueViewController.view.anchorToSuperview()
        
        tabView.selectTabViewItem(at: 0)
        
        colorSchemesManager.registerSchemeObserver(self)
        
        messenger.subscribe(to: .effects_sheetDismissed, handler: effectsSheetDismissed)
        
        messenger.subscribe(to: .CompactPlayer.showPlayer, handler: showPlayer)
        messenger.subscribe(to: .CompactPlayer.showPlayQueue, handler: showPlayQueue)
        messenger.subscribe(to: .CompactPlayer.toggleEffects, handler: toggleEffects)
        messenger.subscribe(to: .CompactPlayer.changeWindowCornerRadius, handler: changeWindowCornerRadius)
        
        setUpEventHandling()
    }
    
    private func initFromPersistentState() {
        
        if let rememberedLocation = compactPlayerUIState.windowLocation {
            window?.setFrameOrigin(rememberedLocation)
        }
        
        changeWindowCornerRadius()
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
    
    func showPlayer() {
        
        guard compactPlayerUIState.displayedTab != .player else {return}
        
        tabView.selectTabViewItem(at: 0)
        eventMonitor.resumeMonitoring()
    }
    
    func showPlayQueue() {
        
        guard compactPlayerUIState.displayedTab != .playQueue else {return}
        
        tabView.selectTabViewItem(at: 1)
        eventMonitor.pauseMonitoring()
    }
    
    func toggleEffects() {
        
        if compactPlayerUIState.displayedTab == .effects {
            
            effectsSheetViewController.endSheet()
            return
        }
        
        // Effects not shown, so show it.
        
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
    
    private func transferViewState() {
        compactPlayerUIState.windowLocation = theWindow.frame.origin
    }
    
    func changeWindowCornerRadius() {
        rootContainerBox.cornerRadius = compactPlayerUIState.cornerRadius
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
            return
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
