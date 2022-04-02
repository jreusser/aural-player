//
//  WindowLayoutsManager.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

class WindowLayoutsManager: UserManagedObjects<WindowLayout>, Destroyable, Restorable {
    
    private let preferences: ViewPreferences
    
    private var windowLoaders: [WindowLoader] = []
    
    private lazy var messenger = Messenger(for: self)
    
    private var savedLayout: WindowLayout? = nil
    
    lazy var mainWindow: NSWindow = windowLoaders.first(where: {$0.windowID == .main})!.window

    init(persistentState: WindowLayoutsPersistentState?, viewPreferences: ViewPreferences) {
        
        self.preferences = viewPreferences
        
        let systemDefinedLayouts = WindowLayoutPresets.allCases.map {$0.layout(gap: CGFloat(viewPreferences.windowGap))}
        let userDefinedLayouts: [WindowLayout] = persistentState?.userLayouts?.compactMap
        {WindowLayout(persistentState: $0)} ?? []
        
        let mainWindowLoader = WindowLoader(windowID: .main, windowControllerType: MainWindowController.self)
        windowLoaders.append(mainWindowLoader)
//        self.mainWindow = mainWindowLoader.window
        
        for windowID in WindowID.allCases {
            
            switch windowID {
                
            case .playQueue:
                
                windowLoaders.append(WindowLoader(windowID: .playQueue, windowControllerType: PlayQueueWindowController.self))
                
            case .effects:
                
                windowLoaders.append(WindowLoader(windowID: .effects, windowControllerType: EffectsWindowController.self))
                
            default:
                
                continue
            }
        }
        
        super.init(systemDefinedObjects: systemDefinedLayouts, userDefinedObjects: userDefinedLayouts)
        
        if preferences.layoutOnStartup.option == .specific, let layoutName = preferences.layoutOnStartup.layoutName {
            self.savedLayout = object(named: layoutName)
            
        } else {
            self.savedLayout = WindowLayout(systemLayoutFrom: persistentState)
        }
    }
    
    var defaultLayout: WindowLayout {
        systemDefinedObject(named: WindowLayoutPresets.verticalFullStack.name)!
    }
    
    func recomputeSystemDefinedLayouts() {
        systemDefinedObjects.forEach {WindowLayoutPresets.recompute(layout: $0, gap: CGFloat(preferences.windowGap))}
    }
    
    var isShowingModalComponent: Bool {
        
        NSApp.modalComponents.contains(where: {$0.isModal}) ||
            StringInputPopoverViewController.isShowingAPopover ||
            NSApp.modalWindow != nil
    }
    
    // MARK - Core functionality ----------------------------------------------------
    
    func restore() {
        
        windowLoaders.forEach {$0.restore()}
        performInitialLayout()
    }
    
    func destroy() {
        
        // Save the current layout for future re-use.
        savedLayout = currentWindowLayout
        
        // Hide and release all windows.
        mainWindow.childWindows?.forEach {mainWindow.removeChildWindow($0)}
        windowLoaders.forEach {$0.destroy()}
    }
    
    private func performInitialLayout() {
        
        if let initialLayout = self.savedLayout {
            
            // Remember from last app launch
            applyLayout(initialLayout)
            
        } else {
            performDefaultLayout()
        }
        
        (mainWindow as? SnappingWindow)?.ensureOnScreen()
        mainWindow.makeKeyAndOrderFront(self)
    }
    
    // Revert to default layout if app state is corrupted
    private func performDefaultLayout() {
        applyLayout(defaultLayout)
    }
    
    private func getWindow(forId id: WindowID) -> NSWindow {
        (windowLoaders.first(where: {$0.windowID == id}))!.window
    }
    
    func applyLayout(named name: String) {
        
        if let layout = object(named: name) {
            applyLayout(layout)
        }
    }
    
    func applyLayout(_ layout: WindowLayout) {
        
        mainWindow.setFrameOrigin(layout.mainWindowFrame.origin)
        
        mainWindow.childWindows?.forEach {
            $0.hide()
        }
        
        for window in layout.displayedWindows {
            
            let actualWindow = getWindow(forId: window.id)
            
            mainWindow.addChildWindow(actualWindow, ordered: .below)
            actualWindow.setFrameOrigin(window.frame.origin)
            actualWindow.show()
        }
        
        layoutChanged()
    }
    
    private func layoutChanged() {
        messenger.publish(.windowManager_layoutChanged)
    }
    
    var currentWindowLayout: WindowLayout {
        
        var windows: [LayoutWindow] = []
        
        for child in mainWindow.childWindows ?? [] {
            
            if let windowID = child.windowID {
                windows.append(LayoutWindow(id: windowID, frame: child.frame))
            }
        }
        
        return WindowLayout(name: "_system_", systemDefined: true, mainWindowFrame: self.mainWindowFrame, displayedWindows: windows)
    }
    
//    var isShowingEffects: Bool {
//        return effectsWindowLoaded && _effectsWindow.isVisible
//    }
//
//    var isShowingPlaylist: Bool {
//        return playlistWindowLoaded && _playlistWindow.isVisible
//    }
//
//    // NOTE - Boolean short-circuiting is important here. Otherwise, the chapters list window will be unnecessarily loaded.
//    var isShowingChaptersList: Bool {
//        return chaptersListWindowLoader.isWindowLoaded && _chaptersListWindow.isVisible
//    }
//
//    // NOTE - Boolean short-circuiting is important here. Otherwise, the chapters list window will be unnecessarily loaded.
//    var isChaptersListWindowKey: Bool {
//        return isShowingChaptersList && _chaptersListWindow == NSApp.keyWindow
//    }
//
//    var isShowingVisualizer: Bool {
//        return visualizerWindowLoader.isWindowLoaded && _visualizerWindow.isVisible
//    }
    
    var mainWindowFrame: NSRect {
        mainWindow.frame
    }
    
    // MARK: View toggling code ----------------------------------------------------
    
//    // Shows/hides the effects window
    func toggleWindow(withId id: WindowID) {
        
        let window = getWindow(forId: id)
        
        if window.isVisible {
            window.hide()
            
        } else {
            
            mainWindow.addChildWindow(window, ordered: .above)
            window.show()
            window.orderFront(self)
        }
        
        layoutChanged()
    }
    
    func hideWindow(withId id: WindowID) {
        
        getWindow(forId: id).hide()
        layoutChanged()
    }
    
    func isShowingWindow(withId id: WindowID) -> Bool {
        
        for loader in windowLoaders {
            
            if loader.windowID == id {
                return loader.isWindowLoaded && loader.window.isVisible
            }
        }
        
        return false
    }
    
    func isWindowLoaded(withId id: WindowID) -> Bool {
        (windowLoaders.first(where: {$0.windowID == id}))!.isWindowLoaded
    }
    
    func showChaptersListWindow() {
        
//        let shouldCenterChaptersListWindow = !chaptersListWindowLoader.isWindowLoaded
//
//        mainWindow.addChildWindow(_chaptersListWindow, ordered: .above)
//        _chaptersListWindow.makeKeyAndOrderFront(self)
//
//        // This will happen only once after each app launch - the very first time the window is shown.
//        // After that, the window will be restored to its previous on-screen location
//        if shouldCenterChaptersListWindow && playlistWindowLoaded {
//            _chaptersListWindow.showCentered(relativeTo: _playlistWindow)
//        }
    }
    
    var isShowingPlayQueue: Bool {
        isShowingWindow(withId: .playQueue)
    }
    
    var isShowingEffects: Bool {
        isShowingWindow(withId: .effects)
    }
    
    // MARK: Miscellaneous functions ------------------------------------

    func addChildWindow(_ window: NSWindow) {
        mainWindow.addChildWindow(window, ordered: .above)
    }
    
    var persistentState: WindowLayoutsPersistentState {
        
        let userLayouts = userDefinedObjects.map {WindowLayoutPersistentState(layout: $0)}
        let currentAppMode = objectGraph.appModeManager.currentMode
        
        if currentAppMode == .windowed {
            
            let systemLayout = WindowLayoutPersistentState(layout: currentWindowLayout)
            return WindowLayoutsPersistentState(systemLayout: systemLayout, userLayouts: userLayouts)
            
        } else {
            
            let systemLayout = WindowLayoutPersistentState(layout: savedLayout ?? defaultLayout)
            return WindowLayoutsPersistentState(systemLayout: systemLayout, userLayouts: userLayouts)
        }
    }
}
