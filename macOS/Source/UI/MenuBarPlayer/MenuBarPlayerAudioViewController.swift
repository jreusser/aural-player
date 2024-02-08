//
//  MenuBarPlayerAudioViewController.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  
import Cocoa

class MenuBarPlayerAudioViewController: PlayerAudioViewController {
    
    override func setUpColorAndFontObservation() {}
    
    override func initSubscriptions() {
        
        messenger.subscribeAsync(to: .player_trackTransitioned, handler: trackTransitioned(_:),
                                 filter: {msg in msg.trackChanged})
    }
    
    override func updateVolumeMuteButtonImage(_ volume: Float, _ muted: Bool) {
        
        if muted {
            
            btnVolume.image = .imgMute.filledWithColor(.white)
            
        } else {

            // Zero / Low / Medium / High (different images)
            
            switch volume {
                
            case highVolumeRange:
                
                btnVolume.image = .imgVolumeHigh.filledWithColor(.white)
                
            case mediumVolumeRange:
                
                btnVolume.image = .imgVolumeMedium.filledWithColor(.white)
                
            case lowVolumeRange:
                
                btnVolume.image = .imgVolumeLow.filledWithColor(.white)
                
            default:
                
                btnVolume.image = .imgVolumeZero.filledWithColor(.white)
            }
        }
    }
}
