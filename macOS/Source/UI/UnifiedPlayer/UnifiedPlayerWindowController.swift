//
//  UnifiedPlayerWindowController.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import Cocoa

class UnifiedPlayerWindowController: NSWindowController {
    
    override var windowNibName: String? {"UnifiedPlayer"}
    
    @IBOutlet weak var logoImage: TintedImageView!
    @IBOutlet weak var rootContainerBox: NSBox!
    
    @IBOutlet weak var btnQuit: TintedImageButton!
    @IBOutlet weak var btnMinimize: TintedImageButton!
    @IBOutlet weak var presentationModeMenuItem: TintedIconMenuItem!
    @IBOutlet weak var settingsMenuIconItem: TintedIconMenuItem!
    
    private lazy var messenger: Messenger = Messenger(for: self)
    
    // One-time setup
    override func windowDidLoad() {
        
        // TODO: Clean this up
        theWindow.setIsVisible(false)
        initWindow()
        theWindow.setIsVisible(false)
        
//        setUpEventHandling()
        initSubscriptions()
        
        super.windowDidLoad()
    }
    
    // Set window properties
    private func initWindow() {
        
        theWindow.makeKeyAndOrderFront(self)
        
//        containerBox.addSubview(playerViewController.view)

        colorSchemesManager.registerObserver(rootContainerBox, forProperty: \.backgroundColor)
        colorSchemesManager.registerObserver(logoImage, forProperty: \.captionTextColor)
        
        colorSchemesManager.registerObservers([btnQuit, btnMinimize, presentationModeMenuItem, settingsMenuIconItem],
                                              forProperty: \.buttonColor)
        
        applyTheme()
    }
    
    private func initSubscriptions() {
        
        messenger.subscribe(to: .applyTheme, handler: applyTheme)
        messenger.subscribe(to: .windowAppearance_changeCornerRadius, handler: changeWindowCornerRadius(_:))
    }
    
    override func destroy() {
        
        close()
//        viewController.destroy()
        messenger.unsubscribeFromAll()
    }
    
    // MARK: Actions -----------------------------------------------------------
    
    // Quits the app
    @IBAction func quitAction(_ sender: AnyObject) {
        NSApp.terminate(self)
    }
    
    // Minimizes the window (and any child windows)
    @IBAction func minimizeAction(_ sender: AnyObject) {
        theWindow.miniaturize(self)
    }
    
    @IBAction func modularModeAction(_ sender: AnyObject) {
        messenger.publish(.application_switchMode, payload: AppMode.modular)
    }
    
    @IBAction func menuBarModeAction(_ sender: AnyObject) {
        messenger.publish(.application_switchMode, payload: AppMode.menuBar)
    }
    
    @IBAction func controlBarModeAction(_ sender: AnyObject) {
        messenger.publish(.application_switchMode, payload: AppMode.controlBar)
    }
    
    // MARK: Message handling -----------------------------------------------------------
    
    private func applyTheme() {
        changeWindowCornerRadius(windowAppearanceState.cornerRadius)
    }
    
    func changeWindowCornerRadius(_ radius: CGFloat) {
        rootContainerBox.cornerRadius = radius
    }
}
