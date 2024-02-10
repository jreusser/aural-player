//
//  MenuBarAppModeController.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

///
/// Controller responsible for presenting / dismissing the *Menu Bar* application user interface mode.
///
/// The menu bar app mode's interace consists of a menu that drops down from the macOS menu bar.
/// The menu item that is displayed presents a view containing essential player controls and some basic
/// options to customize that view.
///
/// The menu bar app mode allows the user access to essential player functions and is intended for a
/// low level of user interaction. It will typically be used when running the application in the "background".
///
class MenuBarAppModeController: NSObject, AppModeController {

    var mode: AppMode {.menuBar}

    private var statusItem: NSStatusItem?
    private var playerViewController: MenuBarPVC!
    private var playQueueViewController: CompactPlayQueueViewController!
    
    private var playQueueMenuItem: NSMenuItem!
    private var settingsMenuItems: [NSMenuItem] = []
    
    private let appIcon: NSImage = NSImage(named: "AppIcon-MenuBar")!
    
    private lazy var messenger: Messenger = .init(for: self)
    
    override init() {
        
        super.init()
        
        messenger.subscribe(to: .MenuBarPlayer.toggleSettingsMenu, handler: toggleSettingsMenu)
        messenger.subscribe(to: .MenuBarPlayer.togglePlayQueue, handler: togglePlayQueue)
    }
    
    func presentMode(transitioningFromMode previousMode: AppMode?) {
        
        playerViewController = MenuBarPVC()
        playQueueViewController = CompactPlayQueueViewController()

        // Make app run in menu bar and make it active.
        NSApp.setActivationPolicy(.accessory)
        NSApp.activate(ignoringOtherApps: true)
        
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        statusItem?.button?.image = appIcon
        statusItem?.button?.toolTip = "Aural Player v\(NSApp.appVersion)"
        
        let menu = NSMenu()
        
        let playerMenuItem = NSMenuItem(view: playerViewController.view)
        menu.addItem(playerMenuItem)
        
        menu.addItem(.separator())
        
        self.playQueueMenuItem = NSMenuItem(view: playQueueViewController.view)
        menu.addItem(playQueueMenuItem)
        playQueueMenuItem.showIf(menuBarPlayerUIState.showPlayQueue)
        
        menu.addItem(.separator())
        
        self.settingsMenuItems = playerViewController.settingsMenu.items
        playerViewController.settingsMenu.removeAllItems()
        
        for item in settingsMenuItems {
            menu.addItem(item)
        }
        
        menu.delegate = playerViewController
        
        statusItem?.menu = menu
    }
    
    func dismissMode() {
        
        playerViewController?.destroy()
        playQueueViewController?.destroy()
     
        if let statusItem = self.statusItem {
            
            statusItem.menu?.cancelTracking()
            statusItem.menu = nil
            
            NSStatusBar.system.removeStatusItem(statusItem)
            self.statusItem = nil
        }
        
        playerViewController = nil
        playQueueViewController = nil
        playQueueMenuItem = nil
    }
    
    private func toggleSettingsMenu() {
        
        self.settingsMenuItems.forEach {
            $0.toggleShownOrHidden()
        }
    }
    
    private func togglePlayQueue() {
        playQueueMenuItem.showIf(menuBarPlayerUIState.showPlayQueue)
    }
}

//extension MenuBarAppModeController: NSMenuDelegate {
//    
//    func menuDidClose(_ menu: NSMenu) {
//        playerViewController?.menuBarMenuClosed()
//    }
//    
//    func menuWillOpen(_ menu: NSMenu) {
//        playerViewController?.menuBarMenuOpened()
//    }
//}
