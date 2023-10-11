//
//  UnifiedAppModeController.swift
//  Aural
//
//  Copyright © 2023 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import Cocoa

class UnifiedAppModeController: AppModeController {
    
    var mode: AppMode {.unified}

    private var windowController: UnifiedPlayerWindowController?
    
    func presentMode(transitioningFromMode previousMode: AppMode?) {

        NSApp.setActivationPolicy(.regular)
        NSApp.menu = nil
        
        windowController = UnifiedPlayerWindowController()
        windowController?.showWindow(self)
    }
    
    func dismissMode() {
        
        windowController?.destroy()
        windowController = nil
    }
}
