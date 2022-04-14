//
//  SnappingWindowDelegate.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  
import Cocoa

class SnappingWindowDelegate: NSObject, NSWindowDelegate {
    
    private unowned var window: SnappingWindow!
    private lazy var viewPreferences: ViewPreferences = preferences.viewPreferences
    
    init(window: SnappingWindow) {
        
        self.window = window
        super.init()
        
        self.window.delegate = self
    }
    
    func windowDidMove(_ notification: Notification) {
        
        // Only respond if movement was user-initiated (flag on window).
        guard window.userMovingWindow else {return}
        
        if checkForSnapToWindows() {
            return
        }
        
        // If window doesn't need to be snapped to another window, check if it needs to be snapped to the visible frame
        checkForSnapToScreen()
    }
    
    private func checkForSnapToWindows() -> Bool {
        
        guard viewPreferences.snapToWindows else {return false}
        
        // First check if window can be snapped to another app window
        for mate in getCandidateWindowsForSnap() {
            
            if mate.isVisible && window.checkForSnap(to: mate) {
                return true
            }
        }
        
        return false
    }
    
    private func checkForSnapToScreen() {
        
        if viewPreferences.snapToScreen {
            window.checkForSnapToVisibleFrame()
        }
    }
    
    // Sorted by order of relevance
    private func getCandidateWindowsForSnap() -> [NSWindow] {
        
        let otherWindows: [SnappingWindow] = NSApp.windows.compactMap {$0 as? SnappingWindow}.filter {
            $0.snapLevel <= self.window.snapLevel
        }
        
        return otherWindows.sorted(by: {$0.snapLevel < $1.snapLevel})
    }
}
