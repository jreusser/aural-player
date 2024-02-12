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
        
        messenger.subscribeAsync(to: .Player.trackTransitioned, handler: trackTransitioned(_:),
                                 filter: {msg in msg.trackChanged})
        
        messenger.subscribe(to: .Player.muteOrUnmute, handler: muteOrUnmute)
        messenger.subscribe(to: .Player.decreaseVolume, handler: decreaseVolume(_:))
        messenger.subscribe(to: .Player.increaseVolume, handler: increaseVolume(_:))
        
        messenger.subscribe(to: .applyTheme, handler: applyTheme)
    }
}
