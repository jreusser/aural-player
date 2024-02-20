//
//  TrackInfoViewController.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

/*
    View controller for the "Detailed Track Info" popover
*/
class TrackInfoWindowController: NSWindowController {
    
    override var windowNibName: String? {"TrackInfoWindow"}
    
    @IBOutlet weak var btnClose: NSButton!
    @IBOutlet weak var rootContainer: NSBox!
    
    private lazy var messenger = Messenger(for: self)
    
    override func windowDidLoad() {
        
        super.windowDidLoad()
        
        changeWindowCornerRadius(playerUIState.cornerRadius)
        
        colorSchemesManager.registerSchemeObserver(self)
        colorSchemesManager.registerPropertyObserver(self, forProperty: \.backgroundColor, changeReceiver: rootContainer)
        colorSchemesManager.registerPropertyObserver(self, forProperty: \.buttonColor, changeReceiver: btnClose)
        
        messenger.subscribe(to: .windowAppearance_changeCornerRadius, handler: changeWindowCornerRadius(_:))
    }
    
    @IBAction func closeAction(_ sender: Any) {
        close()
    }
    
    func changeWindowCornerRadius(_ radius: CGFloat) {
        rootContainer.cornerRadius = radius
    }
}

extension TrackInfoWindowController: ColorSchemeObserver {
    
    func colorSchemeChanged() {
        
        btnClose.contentTintColor = systemColorScheme.buttonColor
        rootContainer.fillColor = systemColorScheme.backgroundColor
    }
}
