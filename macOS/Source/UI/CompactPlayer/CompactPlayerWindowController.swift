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
    let searchViewController: CompactPlayQueueSearchViewController = .init()
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
        tabView.tabViewItem(at: 2).view?.addSubview(searchViewController.view)
        
        playQueueViewController.view.anchorToSuperview()
        searchViewController.view.anchorToSuperview()
        
        tabView.selectTabViewItem(at: 0)
        
        colorSchemesManager.registerSchemeObserver(self)
        
        messenger.subscribe(to: .Effects.sheetDismissed, handler: effectsSheetDismissed)
        
        messenger.subscribe(to: .CompactPlayer.showPlayer, handler: showPlayer)
        messenger.subscribe(to: .CompactPlayer.showPlayQueue, handler: showPlayQueue)
        messenger.subscribe(to: .CompactPlayer.toggleEffects, handler: toggleEffects)
        messenger.subscribe(to: .CompactPlayer.changeWindowCornerRadius, handler: changeWindowCornerRadius)
        
        messenger.subscribe(to: .CompactPlayer.switchToModularMode, handler: switchToModularMode)
        messenger.subscribe(to: .CompactPlayer.switchToUnifiedMode, handler: switchToUnifiedMode)
        messenger.subscribe(to: .CompactPlayer.switchToMenuBarMode, handler: switchToMenuBarMode)
        messenger.subscribe(to: .CompactPlayer.switchToWidgetMode, handler: switchToWidgetMode)
        
        messenger.subscribe(to: .CompactPlayer.showSearch, handler: showSearch)
        
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
        switchToModularMode()
    }
    
    @IBAction func unifiedModeAction(_ sender: AnyObject) {
        switchToUnifiedMode()
    }
    
    @IBAction func menuBarModeAction(_ sender: AnyObject) {
        switchToMenuBarMode()
    }
    
    @IBAction func widgetModeAction(_ sender: AnyObject) {
        switchToWidgetMode()
    }
    
    private func switchToModularMode() {
        
        transferViewState()
        appModeManager.presentMode(.modular)
    }
    
    private func switchToUnifiedMode() {
        
        transferViewState()
        appModeManager.presentMode(.unified)
    }
    
    private func switchToMenuBarMode() {
        
        transferViewState()
        appModeManager.presentMode(.menuBar)
    }
    
    private func switchToWidgetMode() {
        
        transferViewState()
        appModeManager.presentMode(.widget)
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
        
        if compactPlayerUIState.displayedView == .effects {
            effectsSheetViewController.endSheet()
        }
        
        guard compactPlayerUIState.displayedView != .player else {return}
        
        tabView.selectTabViewItem(at: 0)
        eventMonitor.resumeMonitoring()
    }
    
    func showPlayQueue() {
        
        if compactPlayerUIState.displayedView == .effects {
            effectsSheetViewController.endSheet()
        }
        
        guard compactPlayerUIState.displayedView != .playQueue else {return}
        
        tabView.selectTabViewItem(at: 1)
        eventMonitor.pauseMonitoring()
    }
    
    func toggleEffects() {
        
        if compactPlayerUIState.displayedView == .effects {
            
            effectsSheetViewController.endSheet()
            return
        }
        
        // Effects not shown, so show it.
        
        switch compactPlayerUIState.displayedView {
            
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
        
        compactPlayerUIState.displayedView = .effects
        eventMonitor.pauseMonitoring()
    }
    
    func showSearch() {
        tabView.selectTabViewItem(at: 2)
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
            compactPlayerUIState.displayedView = .player
            
        case 1:
            compactPlayerUIState.displayedView = .playQueue
            
        case 2:
            compactPlayerUIState.displayedView = .search
            
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
