//
//  WindowedModePlayerSequencingViewController.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  
import Cocoa

class WindowedModePlayerSequencingViewController: PlayerSequencingViewController {
    
    override func initSubscriptions() {
        
        messenger.subscribe(to: .Player.setRepeatMode, handler: setRepeatMode(_:))
        messenger.subscribe(to: .Player.toggleRepeatMode, handler: toggleRepeatMode)
        messenger.subscribe(to: .Player.setShuffleMode, handler: setShuffleMode(_:))
        messenger.subscribe(to: .Player.toggleShuffleMode, handler: toggleShuffleMode)
    }
}
