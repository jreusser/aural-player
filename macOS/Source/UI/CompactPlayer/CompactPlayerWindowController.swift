//
//  CompactPlayerWindowController.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import AppKit

class CompactPlayerWindowController: NSWindowController {
    
    override var windowNibName: NSNib.Name? {"CompactPlayer"}
    
    @IBOutlet weak var rootContainerBox: NSBox!
    @IBOutlet weak var viewController: CompactPlayerViewController!
    
    @IBOutlet weak var btnQuit: TintedImageButton!
    @IBOutlet weak var optionsMenuItem: TintedIconMenuItem!
    
    @IBOutlet weak var cornerRadiusStepper: NSStepper!
    @IBOutlet weak var lblCornerRadius: NSTextField!
    
    private var snappingWindow: SnappingWindow!
    
    private lazy var messenger = Messenger(for: self)
    
    private let uiState: ControlBarPlayerUIState = controlBarPlayerUIState
    
    private var appMovingWindow: Bool = false
    
    override func windowDidLoad() {
        
        window?.isMovableByWindowBackground = true
        //        window?.level = NSWindow.Level(Int(CGWindowLevelForKey(.floatingWindow)))
        
        snappingWindow = window as? SnappingWindow
        window?.center()
        
        rootContainerBox.cornerRadius = 12
//        cornerRadiusStepper.integerValue = uiState.cornerRadius.roundedInt
//        lblCornerRadius.stringValue = "\(cornerRadiusStepper.integerValue)px"
        
        applyTheme()
        
        messenger.subscribe(to: .applyTheme, handler: applyTheme)
        messenger.subscribe(to: .applyColorScheme, handler: applyColorScheme(_:))
        
        snappingWindow.ensureOnScreen()
        
        colorSchemesManager.registerSchemeObserver(self, forProperties: [\.buttonColor])
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
    
    
    override func destroy() {
        
        close()
        viewController.destroy()
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
    
    func colorChanged(to newColor: PlatformColor, forProperty property: KeyPath<ColorScheme, PlatformColor>) {
        btnQuit.contentTintColor = systemColorScheme.buttonColor
    }
}
