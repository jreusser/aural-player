//
//  CompactPlayerUIState.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import Foundation

class CompactPlayerUIState {
    
    var displayedTab: CompactPlayerTab = .player
    
    var windowLocation: NSPoint?
    
    var cornerRadius: CGFloat
    private static let defaultCornerRadius: CGFloat = 3
    
    var trackInfoScrollingEnabled: Bool
    
    var showSeekPosition: Bool
    
    init(persistentState: CompactPlayerUIPersistentState?) {
        
        windowLocation = persistentState?.windowLocation?.toNSPoint()
        cornerRadius = persistentState?.cornerRadius ?? Self.defaultCornerRadius
        
        trackInfoScrollingEnabled = persistentState?.trackInfoScrollingEnabled ?? true
        
        showSeekPosition = persistentState?.showSeekPosition ?? true
    }
    
    var persistentState: CompactPlayerUIPersistentState {
        
        var windowLocation: NSPointPersistentState? = nil
        
        if let location = self.windowLocation {
            windowLocation = NSPointPersistentState(point: location)
        }
        
        return CompactPlayerUIPersistentState(windowLocation: windowLocation,
                                              cornerRadius: cornerRadius,
                                              trackInfoScrollingEnabled: trackInfoScrollingEnabled,
                                              showSeekPosition: showSeekPosition)
    }
}

enum CompactPlayerTab {
    
    case player
    case playQueue
    case search
    case effects
}
