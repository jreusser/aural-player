//
//  EffectsWindowController.swift
//  Aural
//
//  Copyright © 2023 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
/*
 View controller for the Effects panel containing controls that alter the sound output (i.e. controls that affect the audio graph)
 */

import Cocoa

class EffectsWindowController: NSWindowController, ColorSchemePropertyObserver {
    
    override var windowNibName: String? {"EffectsWindow"}
    
    // ------------------------------------------------------------------------
    
    // MARK: UI fields
    
    @IBOutlet weak var rootContainerBox: NSBox!

    // The constituent sub-views, one for each effects unit
    
    private let masterViewController: MasterUnitViewController = MasterUnitViewController()
    private let eqViewController: EQUnitViewController = EQUnitViewController()
    private let pitchViewController: PitchShiftUnitViewController = PitchShiftUnitViewController()
    private let timeViewController: TimeStretchUnitViewController = TimeStretchUnitViewController()
    private let reverbViewController: ReverbUnitViewController = ReverbUnitViewController()
    private let delayViewController: DelayUnitViewController = DelayUnitViewController()
    private let filterViewController: FilterUnitViewController = FilterUnitViewController()
    private let auViewController: AudioUnitsViewController = AudioUnitsViewController()
    private let devicesViewController: DevicesViewController = DevicesViewController()
    
    private lazy var viewControllers = [masterViewController, eqViewController, pitchViewController, timeViewController,
                                        reverbViewController, delayViewController, filterViewController]

    // Tab view and its buttons

    @IBOutlet weak var tabView: NSTabView!
    @IBOutlet weak var lblCaption: NSTextField!

    @IBOutlet weak var masterTabViewButton: EffectsUnitTabButton!
    @IBOutlet weak var eqTabViewButton: EffectsUnitTabButton!
    @IBOutlet weak var pitchTabViewButton: EffectsUnitTabButton!
    @IBOutlet weak var timeTabViewButton: EffectsUnitTabButton!
    @IBOutlet weak var reverbTabViewButton: EffectsUnitTabButton!
    @IBOutlet weak var delayTabViewButton: EffectsUnitTabButton!
    @IBOutlet weak var filterTabViewButton: EffectsUnitTabButton!
    @IBOutlet weak var auTabViewButton: EffectsUnitTabButton!
    @IBOutlet weak var devicesTabViewButton: EffectsUnitTabButton!

    private lazy var tabViewButtons: [EffectsUnitTabButton] = [masterTabViewButton, eqTabViewButton, pitchTabViewButton, timeTabViewButton, reverbTabViewButton,
                                                                                delayTabViewButton, filterTabViewButton, auTabViewButton, devicesTabViewButton]
    
    @IBOutlet weak var btnClose: TintedImageButton!
    
    // ------------------------------------------------------------------------
    
    // MARK: Services, utilities, helpers, and properties

    // Delegate that alters the audio graph
    private let graph: AudioGraphDelegateProtocol = audioGraphDelegate
    
    private let viewPreferences: ViewPreferences = preferences.viewPreferences

    private lazy var messenger = Messenger(for: self)
    
    // ------------------------------------------------------------------------
    
    // MARK: UI initialization / life-cycle

    override func windowDidLoad() {
        
        super.windowDidLoad()
        
        theWindow.isMovableByWindowBackground = true
        
        // Initialize all sub-views
        initTabGroup()
        
        colorSchemesManager.registerObservers(tabViewButtons + [rootContainerBox], forProperty: \.backgroundColor)
        colorSchemesManager.registerObserver(lblCaption, forProperty: \.captionTextColor)
        colorSchemesManager.registerObservers([self, btnClose], forProperty: \.buttonColor)
        
        applyTheme()
        
        initSubscriptions()
    }
    
    private func initTabGroup() {
        
        for (index, viewController) in (viewControllers + [auViewController, devicesViewController]).enumerated() {
            
            tabView.tabViewItem(at: index).view?.addSubview(viewController.view)
            viewController.view.anchorToSuperview()
        }

        fxUnitStateObserverRegistry.registerObserver(masterTabViewButton, forFXUnit: audioGraphDelegate.masterUnit)
        fxUnitStateObserverRegistry.registerObserver(eqTabViewButton, forFXUnit: audioGraphDelegate.eqUnit)
        fxUnitStateObserverRegistry.registerObserver(pitchTabViewButton, forFXUnit: audioGraphDelegate.pitchShiftUnit)
        fxUnitStateObserverRegistry.registerObserver(timeTabViewButton, forFXUnit: audioGraphDelegate.timeStretchUnit)
        fxUnitStateObserverRegistry.registerObserver(reverbTabViewButton, forFXUnit: audioGraphDelegate.reverbUnit)
        fxUnitStateObserverRegistry.registerObserver(delayTabViewButton, forFXUnit: audioGraphDelegate.delayUnit)
        fxUnitStateObserverRegistry.registerObserver(filterTabViewButton, forFXUnit: audioGraphDelegate.filterUnit)
        
        fxUnitStateObserverRegistry.registerAUObserver(auTabViewButton)
        
        // TODO: Add state observer for AU tab button (complicated - composite function comprising states of individual AUs)
        // Might need an overload of registerObserver that takes a function instead of an FXUnitDelegate.

        auTabViewButton.stateFunction = {[weak self] in
            self?.graph.audioUnits.first(where: {$0.state == .active || $0.state == .suppressed})?.state ?? .bypassed
        }
        
        devicesTabViewButton.stateFunction = {.bypassed}
        
        // Select Master tab view by default
        doTabViewAction(masterTabViewButton)
//        doTabViewAction(devicesTabViewButton)
    }

    override func destroy() {
        
        ([masterViewController, eqViewController, pitchViewController, timeViewController, reverbViewController,
          delayViewController, filterViewController, auViewController, devicesViewController] as? [Destroyable])?.forEach {$0.destroy()}
        
        close()
        messenger.unsubscribeFromAll()
    }
    
    // ------------------------------------------------------------------------
    
    // MARK: Actions

    // Switches the tab group to a particular tab
    @IBAction func tabViewAction(_ sender: EffectsUnitTabButton) {
        doTabViewAction(sender)
    }
    
    private func doTabViewAction(_ sender: EffectsUnitTabButton) {
        
        // Set sender button state, reset all other button states
        tabViewButtons.forEach {$0.unSelect()}
        sender.select()

        // Button tag is the tab index
        tabView.selectTabViewItem(at: sender.tag)
        lblCaption.stringValue = EffectsUnitType(rawValue: sender.tag)!.caption
    }
    
    @IBAction func closeWindowAction(_ sender: AnyObject) {
        windowLayoutsManager.hideWindow(withId: .effects)
    }
    
    // ------------------------------------------------------------------------
    
    // MARK: Message handling
    
    private func initSubscriptions() {

        messenger.subscribe(to: .effects_showEffectsUnitTab, handler: showTab(_:))
        
        messenger.subscribe(to: .applyTheme, handler: applyTheme)
        messenger.subscribe(to: .applyFontScheme, handler: applyFontScheme(_:))
        messenger.subscribe(to: .windowAppearance_changeCornerRadius, handler: changeWindowCornerRadius(_:))
    }

    private func showTab(_ effectsUnitType: EffectsUnitType) {
        
        switch effectsUnitType {
        
        case .master: tabViewAction(masterTabViewButton)

        case .eq: tabViewAction(eqTabViewButton)

        case .pitch: tabViewAction(pitchTabViewButton)

        case .time: tabViewAction(timeTabViewButton)

        case .reverb: tabViewAction(reverbTabViewButton)

        case .delay: tabViewAction(delayTabViewButton)

        case .filter: tabViewAction(filterTabViewButton)
            
        case .au: tabViewAction(auTabViewButton)
            
        case .devices:  tabViewAction(devicesTabViewButton)

        }
    }
    
    // ------------------------------------------------------------------------
    
    // MARK: Theming
    
    private func applyTheme() {
        
        applyFontScheme(systemFontScheme)
        changeWindowCornerRadius(windowAppearanceState.cornerRadius)
    }
    
    private func applyFontScheme(_ scheme: FontScheme) {
        lblCaption.font = scheme.captionFont
    }
    
//    private func changeActiveUnitStateColor(_ color: NSColor) {
//
////        tabViewButtons.filter {$0.unitState == .active}.forEach {
////            $0.reTint()
////        }
//    }
//
//    private func changeBypassedUnitStateColor(_ color: NSColor) {
//
////        tabViewButtons.filter {$0.unitState == .bypassed}.forEach {
////            $0.reTint()
////        }
//    }
//
//    private func changeSuppressedUnitStateColor(_ color: NSColor) {
//
////        tabViewButtons.filter {$0.unitState == .suppressed}.forEach {
////            $0.reTint()
////        }
//    }
    
    func colorChanged(to newColor: PlatformColor, forProperty property: KeyPath<ColorScheme, PlatformColor>) {
        tabViewButtons[tabView.selectedIndex].redraw()
    }
    
    func changeWindowCornerRadius(_ radius: CGFloat) {
        rootContainerBox.cornerRadius = radius
    }
}
