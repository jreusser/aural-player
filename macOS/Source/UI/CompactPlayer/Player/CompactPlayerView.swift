//
//  CompactPlayerView.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import AppKit

class CompactPlayerView: MouseTrackingView {
    
    @IBOutlet weak var functionsMenuContainerBox: NSBox!
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        startTracking()
    }
    
    override func mouseEntered(with event: NSEvent) {
        
        if playbackInfoDelegate.playingTrack != nil {
            functionsMenuContainerBox.show()
        }
    }
    
    override func mouseMoved(with event: NSEvent) {
        
        if playbackInfoDelegate.playingTrack != nil {
            functionsMenuContainerBox.show()
        }
    }
    
    override func mouseExited(with event: NSEvent) {
        functionsMenuContainerBox.hide()
    }
}
