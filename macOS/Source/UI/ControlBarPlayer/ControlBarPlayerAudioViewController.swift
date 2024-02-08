//
//  ControlBarPlayerAudioViewController.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  
import Cocoa

class ControlBarPlayerAudioViewController: PlayerAudioViewController {
    
    override func initSubscriptions() {
        
        messenger.subscribeAsync(to: .player_trackTransitioned, handler: trackTransitioned(_:),
                                 filter: {msg in msg.trackChanged})
        
        messenger.subscribe(to: .player_muteOrUnmute, handler: muteOrUnmute)
        messenger.subscribe(to: .player_decreaseVolume, handler: decreaseVolume(_:))
        messenger.subscribe(to: .player_increaseVolume, handler: increaseVolume(_:))
        
        messenger.subscribe(to: .applyTheme, handler: applyTheme)
    }
}
