//
//  CompactAppModeController.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import AppKit

class CompactAppModeController: AppModeController {

    var mode: AppMode {.compact}

    private var windowController: CompactPlayerWindowController?
    
    func presentMode(transitioningFromMode previousMode: AppMode?) {

        NSApp.setActivationPolicy(.regular)
        NSApp.menu = nil
        
        windowController = CompactPlayerWindowController()
        windowController?.showWindow(self)
    }
    
    func dismissMode() {
        
        windowController?.destroy()
        windowController = nil
    }
}
