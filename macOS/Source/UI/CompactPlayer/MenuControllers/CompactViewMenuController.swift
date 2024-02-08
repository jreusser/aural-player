//
//  CompactViewMenuController.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import AppKit

class CompactViewMenuController: NSObject, NSMenuDelegate {
    
    // Menu items whose states are toggled when they (or others) are clicked
    @IBOutlet weak var showPlayerMenuItem: NSMenuItem!
    @IBOutlet weak var showPlayQueueMenuItem: NSMenuItem!
    @IBOutlet weak var toggleEffectsMenuItem: NSMenuItem!
    
    @IBOutlet weak var cornerRadiusStepper: NSStepper!
    @IBOutlet weak var lblCornerRadius: NSTextField!
    
    private lazy var messenger: Messenger = .init(for: self)
    
    // When the menu is about to open, set the menu item states according to the current window/view state
    func menuWillOpen(_ menu: NSMenu) {
        
        [showPlayerMenuItem, showPlayQueueMenuItem, toggleEffectsMenuItem].forEach {$0?.off()}

        switch compactPlayerUIState.displayedTab {
            
        case .player:
            showPlayerMenuItem.on()
            
        case .playQueue, .search:
            showPlayQueueMenuItem.on()
            
        case .effects:
            toggleEffectsMenuItem.on()
        }
        
        cornerRadiusStepper.integerValue = compactPlayerUIState.cornerRadius.roundedInt
        lblCornerRadius.stringValue = "\(cornerRadiusStepper.integerValue)px"
    }
    
    // Shows/hides the Player view
    @IBAction func showPlayerAction(_ sender: AnyObject) {
        messenger.publish(.CompactPlayer.showPlayer)
    }
 
    // Shows/hides the Play Queue view
    @IBAction func showPlayQueueAction(_ sender: AnyObject) {
        messenger.publish(.CompactPlayer.showPlayQueue)
    }
    
    // Shows/hides the effects view
    @IBAction func toggleEffectsAction(_ sender: AnyObject) {
        messenger.publish(.CompactPlayer.toggleEffects)
    }
}
