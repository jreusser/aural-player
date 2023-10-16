//
//  AppModeManager.swift
//  Aural
//
//  Copyright © 2023 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

///
/// Switches between application user interface modes.
///
class AppModeManager {
    
    var currentMode: AppMode? = nil
    
    private lazy var windowedMode: WindowedAppModeController = WindowedAppModeController()
    
    private lazy var unifiedMode: UnifiedAppModeController = UnifiedAppModeController()
    
    private lazy var menuBarMode: MenuBarAppModeController = MenuBarAppModeController()
    
    private lazy var controlBarMode: ControlBarAppModeController = ControlBarAppModeController()
    
    private let preferences: ViewPreferences
    private let lastPresentedAppMode: AppMode?
    
    private lazy var messenger = Messenger(for: self)
    
    init(persistentState: UIPersistentState?, preferences: ViewPreferences) {
        
        self.lastPresentedAppMode = persistentState?.appMode
        self.preferences = preferences
    }
    
    func presentApp() {
        
//        if appSetup.performSetup {
//            presentMode(appSetup.presentationMode)
//            
//        } else if preferences.appModeOnStartup.option == .specific,
//           let appMode = preferences.appModeOnStartup.mode {
//
//            // Present a specific app mode.
//            presentMode(appMode)
//
//        } else {
//
//            // Remember app mode from last app launch.
//            presentMode(lastPresentedAppMode ?? .defaultMode)
//        }
        presentMode(.modular)
    }
    
    func presentMode(_ newMode: AppMode) {
        
        dismissCurrentMode()
        
        switch newMode {
        
        case .modular:
            
            windowedMode.presentMode(transitioningFromMode: currentMode)
            
        case .unified:
            
            unifiedMode.presentMode(transitioningFromMode: currentMode)
        
        case .menuBar:
            
            menuBarMode.presentMode(transitioningFromMode: currentMode)
            
        case .controlBar:
            
            controlBarMode.presentMode(transitioningFromMode: currentMode)
        }
        
        currentMode = newMode
    }
    
    private func dismissCurrentMode() {
        
        guard let currentMode = self.currentMode else {return}
        
        switch currentMode {
            
        case .modular:  windowedMode.dismissMode()
            
        case .unified:  unifiedMode.dismissMode()
            
        case .menuBar: menuBarMode.dismissMode()
            
        case .controlBar:   controlBarMode.dismissMode()
            
        }
    }
}
