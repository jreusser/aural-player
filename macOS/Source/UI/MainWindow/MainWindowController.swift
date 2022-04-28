//
//  MainWindowController.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

/*
    Window controller for the main application window.
 */
class MainWindowController: NSWindowController {
    
    @IBOutlet weak var logoImage: TintedImageView!
    
    // The box that encloses the Now Playing info section
    @IBOutlet weak var rootContainerBox: NSBox!
    @IBOutlet weak var containerBox: NSBox!
    
    private let playerViewController: PlayerViewController = PlayerViewController()
    
    @IBOutlet weak var btnQuit: TintedImageButton!
    @IBOutlet weak var btnMinimize: TintedImageButton!
    @IBOutlet weak var btnMenuBarMode: TintedImageButton!
    @IBOutlet weak var btnControlBarMode: TintedImageButton!
    
    // Buttons to toggle the play queue/effects views
    @IBOutlet weak var btnTogglePlayQueue: TintedImageButton!
    @IBOutlet weak var btnToggleEffects: TintedImageButton!
    @IBOutlet weak var btnTogglePlaylists: TintedImageButton!
    
    private lazy var btnTogglePlayQueueStateMachine: ButtonStateMachine<Bool> = .init(initialState: windowLayoutsManager.isShowingPlayQueue,
                                                                                    mappings: [
                                                                                        
                                                                                        ButtonStateMachine.StateMapping(state: true, image: Images.imgPlayQueue, colorProperty: \.buttonColor, toolTip: "Hide the Play Queue"),
                                                                                        ButtonStateMachine.StateMapping(state: false, image: Images.imgPlayQueue, colorProperty: \.inactiveControlColor, toolTip: "Show the Play Queue")
                                                                                    ],
                                                                                    button: btnTogglePlayQueue)
    
    private lazy var btnToggleEffectsStateMachine: ButtonStateMachine<Bool> = .init(initialState: windowLayoutsManager.isShowingEffects,
                                                                                    mappings: [
                                                                                        
                                                                                        ButtonStateMachine.StateMapping(state: true, image: Images.imgEffects, colorProperty: \.buttonColor, toolTip: "Hide the Effects panel"),
                                                                                        ButtonStateMachine.StateMapping(state: false, image: Images.imgEffects, colorProperty: \.inactiveControlColor, toolTip: "Show the Effects panel")
                                                                                    ],
                                                                                    button: btnToggleEffects)
    
    @IBOutlet weak var btnSettingsMenu: NSPopUpButton!
    
    @IBOutlet weak var settingsMenuIconItem: TintedIconMenuItem!
    
    @IBOutlet weak var mainMenu: NSMenu!
    
    var eventMonitor: EventMonitor! = EventMonitor()
    
    let controlsPreferences: GesturesControlsPreferences = preferences.controlsPreferences.gestures
    
    override var windowNibName: String? {"MainWindow"}
    
    lazy var messenger = Messenger(for: self)
    
    // MARK: Setup
    
    override func awakeFromNib() {
        NSApp.mainMenu = self.mainMenu
    }
    
    // One-time setup
    override func windowDidLoad() {
        
        // TODO: Clean this up
        theWindow.setIsVisible(false)
        initWindow()
        theWindow.setIsVisible(false)
        
        setUpEventHandling()
        initSubscriptions()
        
        super.windowDidLoad()
    }
    
    // Set window properties
    private func initWindow() {
        
        theWindow.isMovableByWindowBackground = true
        theWindow.makeKeyAndOrderFront(self)
        
        containerBox.addSubview(playerViewController.view)

        btnTogglePlayQueueStateMachine.setState(windowLayoutsManager.isShowingPlayQueue)
        btnToggleEffectsStateMachine.setState(windowLayoutsManager.isShowingEffects)
        
        btnToggleEffects.weight = .black
        btnTogglePlayQueue.weight = .black
        
        colorSchemesManager.registerObserver(rootContainerBox, forProperty: \.backgroundColor)
        colorSchemesManager.registerObserver(logoImage, forProperty: \.captionTextColor)
        
        colorSchemesManager.registerObservers([btnQuit, btnMinimize, btnMenuBarMode, btnControlBarMode, settingsMenuIconItem],
                                              forProperty: \.buttonColor)
        
        applyTheme()
    }
    
    private func initSubscriptions() {
        
        messenger.subscribe(to: .applyTheme, handler: applyTheme)

        messenger.subscribe(to: .windowManager_layoutChanged, handler: windowLayoutChanged)
        
        messenger.subscribe(to: .windowAppearance_changeCornerRadius, handler: changeWindowCornerRadius(_:))
    }
    
    override func destroy() {
        
        eventMonitor.stopMonitoring()
        eventMonitor = nil
        
        playerViewController.destroy()
        
        close()
        messenger.unsubscribeFromAll()
        
        SingletonPopoverViewController.destroy()
        StringInputPopoverViewController.destroy()
        SingletonWindowController.destroy()
        
        mainMenu.items.forEach {$0.hide()}
        
        if let auralMenu = mainMenu.item(withTitle: "Aural") {
            
            auralMenu.menu?.items.forEach {$0.disable()}
            auralMenu.show()
        }
        
        NSApp.mainMenu = nil
    }
    
    // MARK: Actions -----------------------------------------------------------
    
    // Shows/hides the play queue window (by delegating)
    @IBAction func togglePlayQueueAction(_ sender: AnyObject) {
        windowLayoutsManager.toggleWindow(withId: .playQueue)
    }
    
    // Shows/hides the effects panel on the main window
    @IBAction func toggleEffectsAction(_ sender: AnyObject) {
        windowLayoutsManager.toggleWindow(withId: .effects)
    }
    
    // Shows/hides the playlists window (by delegating)
    @IBAction func togglePlaylistsAction(_ sender: AnyObject) {
        windowLayoutsManager.toggleWindow(withId: .playlists)
    }
    
    // Quits the app
    @IBAction func quitAction(_ sender: AnyObject) {
        NSApp.terminate(self)
    }
    
    // Minimizes the window (and any child windows)
    @IBAction func minimizeAction(_ sender: AnyObject) {
        theWindow.miniaturize(self)
    }
    
    @IBAction func menuBarModeAction(_ sender: AnyObject) {
        messenger.publish(.application_switchMode, payload: AppMode.menuBar)
    }
    
    @IBAction func controlBarModeAction(_ sender: AnyObject) {
        messenger.publish(.application_switchMode, payload: AppMode.controlBar)
    }
    
    // MARK: Message handling -----------------------------------------------------------
    
    private func applyTheme() {
        changeWindowCornerRadius(windowAppearanceState.cornerRadius)
    }
    
    func windowLayoutChanged() {

        btnTogglePlayQueueStateMachine.setState(windowLayoutsManager.isShowingPlayQueue)
        btnToggleEffectsStateMachine.setState(windowLayoutsManager.isShowingEffects)
    }
    
    func changeWindowCornerRadius(_ radius: CGFloat) {
        rootContainerBox.cornerRadius = radius
    }
}
