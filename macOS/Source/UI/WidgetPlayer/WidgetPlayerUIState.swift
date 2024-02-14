//
//  WidgetPlayerUIState.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  
import Cocoa

class WidgetPlayerUIState {
    
    var windowFrame: NSRect?
    
    static let defaultCornerRadius: CGFloat = 3
    var cornerRadius: CGFloat
    
    var trackInfoScrollingEnabled: Bool
    
    var showTrackTime: Bool
    
    init(persistentState: WidgetPlayerUIPersistentState?) {
        
        windowFrame = persistentState?.windowFrame?.toNSRect()
        cornerRadius = persistentState?.cornerRadius ?? Self.defaultCornerRadius
        
        trackInfoScrollingEnabled = persistentState?.trackInfoScrollingEnabled ?? true
        
        showTrackTime = persistentState?.showTrackTime ?? true
    }
    
    var persistentState: WidgetPlayerUIPersistentState {
        
        var windowFrame: NSRectPersistentState? = nil
        
        if let frame = self.windowFrame {
            windowFrame = NSRectPersistentState(rect: frame)
        }
        
        return WidgetPlayerUIPersistentState(windowFrame: windowFrame,
                                                 cornerRadius: cornerRadius,
                                                 trackInfoScrollingEnabled: trackInfoScrollingEnabled,
                                                 showTrackTime: showTrackTime)
    }
}
