//
//  PlayQueueWindowController.swift
//  Aural
//
//  Copyright © 2023 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import Cocoa

class PlayQueueWindowController: NSWindowController {

    override var windowNibName: String? {"PlayQueueWindow"}
    
    @IBOutlet weak var btnClose: TintedImageButton!
    private lazy var btnCloseConstraints: LayoutConstraintsManager = LayoutConstraintsManager(for: btnClose)
    
    private lazy var containerViewController: PlayQueueContainerViewController = .init()
    
    lazy var messenger: Messenger = Messenger(for: self)
    
    override func windowDidLoad() {
        
        super.windowDidLoad()
        
        theWindow.isMovableByWindowBackground = true
        
        window?.contentView?.addSubview(containerViewController.view)
        
        containerViewController.view.anchorToSuperview()
        
        // Bring the 'X' (Close) button to the front and constrain it.
        btnClose.bringToFront()

        btnCloseConstraints.setWidth(11.5)
        btnCloseConstraints.setHeight(10)
        btnCloseConstraints.setLeading(relatedToLeadingOf: btnClose.superview!, offset: 10)
        btnCloseConstraints.setTop(relatedToTopOf: btnClose.superview!, offset: 15)
        
        // Offset the caption to the right of the 'X' (Close) button.
        containerViewController.lblCaption.moveRight(distance: 20)
        
        changeWindowCornerRadius(windowAppearanceState.cornerRadius)
        messenger.subscribe(to: .windowAppearance_changeCornerRadius, handler: changeWindowCornerRadius(_:))
    }
    
    // MARK: Actions ----------------------------------------------------------------------------------
    
    @IBAction func closeAction(_ sender: NSButton) {
        windowLayoutsManager.toggleWindow(withId: .playQueue)
    }
    
    // MARK: Notification handling ----------------------------------------------------------------------------------
    
    private func changeWindowCornerRadius(_ radius: CGFloat) {
        containerViewController.rootContainer.cornerRadius = radius
    }
    
    override func destroy() {
        
        close()
        
        containerViewController.destroy()
        messenger.unsubscribeFromAll()
    }
}
