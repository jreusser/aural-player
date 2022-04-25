//
//  ChaptersListWindowController.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

/*
    Window controller for the Chapters list window.
    Contains the Chapters list view and performs window snapping.
 */
class ChaptersListWindowController: NSWindowController, ModalComponentProtocol {
    
    @IBOutlet weak var rootContainerBox: NSBox!
    @IBOutlet weak var viewController: ChaptersListViewController!
    
    override var windowNibName: String? {"ChaptersList"}
    
    private lazy var messenger = Messenger(for: self)
    
    private lazy var uiState: WindowAppearanceState = windowAppearanceState
    
    // The chapters list window is only considered modal when it is the key window AND
    // the search bar has focus (i.e. a search is being performed).
    var isModal: Bool {
        theWindow.isKeyWindow && viewController.isPerformingSearch
    }
    
    override func windowDidLoad() {
        
        changeBackgroundColor(systemColorScheme.backgroundColor)
        rootContainerBox.cornerRadius = uiState.cornerRadius
        
        messenger.subscribe(to: .applyTheme, handler: applyTheme)
        messenger.subscribe(to: .applyColorScheme, handler: applyColorScheme(_:))
//        messenger.subscribe(to: .changeBackgroundColor, handler: changeBackgroundColor(_:))
        messenger.subscribe(to: .windowAppearance_changeCornerRadius, handler: changeWindowCornerRadius(_:))
    }
    
    @IBAction func closeWindowAction(_ sender: AnyObject) {
//        windowLayoutsManager.hideChaptersListWindow()
    }
    
    private func applyTheme() {
        applyColorScheme(systemColorScheme)
    }
    
    private func applyColorScheme(_ scheme: ColorScheme) {
        changeBackgroundColor(scheme.backgroundColor)
    }
    
    private func changeBackgroundColor(_ color: NSColor) {
        rootContainerBox.fillColor = color
    }
    
    func changeWindowCornerRadius(_ radius: CGFloat) {
        rootContainerBox.cornerRadius = radius
    }
    
    override func destroy() {
        
        viewController.destroy()
        
        close()
        messenger.unsubscribeFromAll()
    }
}
