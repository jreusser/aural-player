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
    
    var displayedView: CompactPlayerDisplayedView = .player
    
    var windowLocation: NSPoint?
    
    var cornerRadius: CGFloat
    private static let defaultCornerRadius: CGFloat = 3
    
    var trackInfoScrollingEnabled: Bool
    
    var showTrackTime: Bool
    
    init(persistentState: CompactPlayerUIPersistentState?) {
        
        windowLocation = persistentState?.windowLocation?.toNSPoint()
        cornerRadius = persistentState?.cornerRadius ?? Self.defaultCornerRadius
        
        trackInfoScrollingEnabled = persistentState?.trackInfoScrollingEnabled ?? true
        
        showTrackTime = persistentState?.showTrackTime ?? true
    }
    
    var persistentState: CompactPlayerUIPersistentState {
        
        var windowLocation: NSPointPersistentState? = nil
        
        if let location = self.windowLocation {
            windowLocation = NSPointPersistentState(point: location)
        }
        
        return CompactPlayerUIPersistentState(windowLocation: windowLocation,
                                              cornerRadius: cornerRadius,
                                              trackInfoScrollingEnabled: trackInfoScrollingEnabled,
                                              showTrackTime: showTrackTime)
    }
}

enum CompactPlayerDisplayedView {
    
    case player
    case playQueue
    case search
    case effects
}
