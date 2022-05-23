//
//  LibraryAlbumsViewController+Actions.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import Cocoa

extension LibraryAlbumsViewController {
    
    @IBAction func playNowAction(_ sender: AnyObject) {
        
        guard let item = outlineView.selectedItem else {return}
        
        if let track = item as? Track {
            messenger.publish(EnqueueAndPlayNowCommand(tracks: [track], clearPlayQueue: false))
            
        } else if let group = item as? Group {
            messenger.publish(EnqueueAndPlayNowCommand(tracks: group.tracks, clearPlayQueue: false))
        }
    }
}
