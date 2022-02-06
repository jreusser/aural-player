//
//  WindowedModePlayerSequencingViewController.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  
import Cocoa

class WindowedModePlayerSequencingViewController: PlayerSequencingViewController {
    
    override func initSubscriptions() {
        
        messenger.subscribe(to: .player_setRepeatMode, handler: setRepeatMode(_:))
        messenger.subscribe(to: .player_toggleRepeatMode, handler: toggleRepeatMode)
        messenger.subscribe(to: .player_setShuffleMode, handler: setShuffleMode(_:))
        messenger.subscribe(to: .player_toggleShuffleMode, handler: toggleShuffleMode)
    }
}
