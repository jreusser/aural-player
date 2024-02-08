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

class CompactPlayerUIState {
    
    init() {}
    
    var isShowingPlayer: Bool = true
}

class CompactPlayerWindowController: NSWindowController {
    
    override var windowNibName: NSNib.Name? {"CompactPlayer"}
    
    @IBOutlet weak var logoImage: TintedImageView!
    
    @IBOutlet weak var rootContainerBox: NSBox!
    @IBOutlet weak var playerViewController: CompactPlayerViewController!
    private lazy var playQueueViewController: PlayQueueExpandedViewController = .init()
    
    @IBOutlet weak var tabView: NSTabView!
    
    @IBOutlet weak var btnQuit: TintedImageButton!
    @IBOutlet weak var optionsMenuItem: TintedIconMenuItem!
    
    @IBOutlet weak var btnMinimize: TintedImageButton!
    @IBOutlet weak var presentationModeMenuItem: TintedIconMenuItem!
    @IBOutlet weak var settingsMenuIconItem: TintedIconMenuItem!
    
    @IBOutlet weak var cornerRadiusStepper: NSStepper!
    @IBOutlet weak var lblCornerRadius: NSTextField!
    
    lazy var messenger = Messenger(for: self)
    
    private let uiState: ControlBarPlayerUIState = controlBarPlayerUIState
    
    private var appMovingWindow: Bool = false
    
    var eventMonitor: EventMonitor! = EventMonitor()
    
    override func windowDidLoad() {
        
        window?.isMovableByWindowBackground = true
        window?.center()
        
        tabView.tabViewItem(at: 0).view?.addSubview(playerViewController.view)
        tabView.tabViewItem(at: 1).view?.addSubview(playQueueViewController.view)
        
        playQueueViewController.view.anchorToSuperview()
        
        tabView.selectTabViewItem(at: 0)
        compactPlayerUIState.isShowingPlayer = true
        
        rootContainerBox.cornerRadius = 8
//        cornerRadiusStepper.integerValue = uiState.cornerRadius.roundedInt
//        lblCornerRadius.stringValue = "\(cornerRadiusStepper.integerValue)px"
        
        applyTheme()
        
        messenger.subscribe(to: .applyTheme, handler: applyTheme)
        messenger.subscribe(to: .applyColorScheme, handler: applyColorScheme(_:))
        
//        colorSchemesManager.registerObserver(rootContainerBox, forProperty: \.backgroundColor)
//        colorSchemesManager.registerObserver(logoImage, forProperty: \.captionTextColor)
//        
//        colorSchemesManager.registerObservers([btnQuit, btnMinimize, presentationModeMenuItem, settingsMenuIconItem],
//                                              forProperty: \.buttonColor)
        
        setUpEventHandling()
    }
    
    func applyTheme() {
        applyColorScheme(systemColorScheme)
    }
    
    func applyColorScheme(_ colorScheme: ColorScheme) {
        
        rootContainerBox.fillColor = colorScheme.backgroundColor
        //        [btnQuit, optionsMenuItem].forEach {($0 as? Tintable)?.reTint()}
    }
    
    @IBAction func cornerRadiusStepperAction(_ sender: NSStepper) {
        
        lblCornerRadius.stringValue = "\(cornerRadiusStepper.integerValue)px"
        rootContainerBox.cornerRadius = CGFloat(cornerRadiusStepper.integerValue)
        uiState.cornerRadius = rootContainerBox.cornerRadius
    }
    
    @IBAction func showPlayerAction(_ sender: NSMenuItem) {
        
        tabView.selectTabViewItem(at: 0)
        compactPlayerUIState.isShowingPlayer = true
        eventMonitor.resumeMonitoring()
    }
    
    @IBAction func showPlayQueueAction(_ sender: NSMenuItem) {
        
        tabView.selectTabViewItem(at: 1)
        compactPlayerUIState.isShowingPlayer = false
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
        uiState.windowFrame = theWindow.frame
    }
    
    // MARK: Menu delegate functions -----------------------------
    
    func menuNeedsUpdate(_ menu: NSMenu) {
        
        cornerRadiusStepper.integerValue = rootContainerBox.cornerRadius.roundedInt
        lblCornerRadius.stringValue = "\(cornerRadiusStepper.integerValue)px"
    }
}

extension CompactPlayerWindowController: ColorSchemeObserver {
    
    func colorSchemeChanged() {
        btnQuit.contentTintColor = systemColorScheme.buttonColor
    }
    
    func colorChanged(to newColor: PlatformColor, forProperty property: ColorSchemeProperty) {
        btnQuit.contentTintColor = systemColorScheme.buttonColor
    }
}
