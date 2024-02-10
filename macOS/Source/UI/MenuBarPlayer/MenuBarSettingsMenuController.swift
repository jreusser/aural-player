//
//  MenuBarSettingsMenuController.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import AppKit

class MenuBarSettingsMenuController: NSObject, NSMenuDelegate {
    
    @IBOutlet weak var showPlayQueueMenuItem: NSMenuItem!
    @IBOutlet weak var seekPositionDisplayTypeMenuItem: NSMenuItem!
    
    @IBOutlet weak var timeElapsedMenuItem: SeekPositionDisplayTypeMenuItem!
    @IBOutlet weak var timeRemainingMenuItem: SeekPositionDisplayTypeMenuItem!
    @IBOutlet weak var trackDurationMenuItem: SeekPositionDisplayTypeMenuItem!
    
    var seekPositionDisplayTypeItems: [NSMenuItem] = []
    
    private lazy var messenger = Messenger(for: self)
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        
        // View settings menu items
        timeElapsedMenuItem.displayType = .elapsed
        timeRemainingMenuItem.displayType = .remaining
        trackDurationMenuItem.displayType = .duration
        
        seekPositionDisplayTypeItems = [timeElapsedMenuItem, timeRemainingMenuItem, trackDurationMenuItem]
    }
    
//    func menuNeedsUpdate(_ menu: NSMenu) {
    
    func menuWillOpen(_ menu: NSMenu) {
        
        showPlayQueueMenuItem.onIf(menuBarPlayerUIState.showPlayQueue)
        
        seekPositionDisplayTypeItems.forEach {$0.off()}
        
        switch playerUIState.trackTimeDisplayType {
            
        case .elapsed:
            timeElapsedMenuItem.on()
            
        case .remaining:
            timeRemainingMenuItem.on()
            
        case .duration:
            trackDurationMenuItem.on()
        }
    }
 
    // Shows/hides the Play Queue view
    @IBAction func showPlayQueueAction(_ sender: AnyObject) {
        
        menuBarPlayerUIState.showPlayQueue.toggle()
        messenger.publish(.MenuBarPlayer.togglePlayQueue)
    }

    @IBAction func changeSeekPositionDisplayTypeAction(_ sender: SeekPositionDisplayTypeMenuItem) {
        
        playerUIState.trackTimeDisplayType = sender.displayType
//        messenger.publish(.CompactPlayer.changeTrackTimeDisplayType)
    }
}
