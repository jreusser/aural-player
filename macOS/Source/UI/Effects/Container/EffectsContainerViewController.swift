//
//  EffectsContainerViewController.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import Cocoa

class EffectsContainerViewController: NSViewController {
    
    override var nibName: String? {"EffectsContainer"}
    
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
    
    // ------------------------------------------------------------------------
    
    // MARK: Services, utilities, helpers, and properties

    // Delegate that alters the audio graph
    private let graph: AudioGraphDelegateProtocol = audioGraphDelegate
    
    private let viewPreferences: ViewPreferences = preferences.viewPreferences

    private lazy var messenger = Messenger(for: self)
    
    // ------------------------------------------------------------------------
    
    // MARK: UI initialization / life-cycle

    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        // Initialize all sub-views
        initTabGroup()
        
        colorSchemesManager.registerSchemeObserver(self)
        colorSchemesManager.registerPropertyObserver(self, forProperty: \.backgroundColor, changeReceivers: [rootContainerBox] + tabViewButtons)
        colorSchemesManager.registerPropertyObserver(self, forProperty: \.captionTextColor, changeReceiver: lblCaption)
        colorSchemesManager.registerPropertyObserver(self, forProperty: \.activeControlColor, handler: activeControlColorChanged(_:))
        colorSchemesManager.registerPropertyObserver(self, forProperty: \.inactiveControlColor, handler: inactiveControlColorChanged(_:))
        colorSchemesManager.registerPropertyObserver(self, forProperty: \.suppressedControlColor, handler: suppressedControlColorChanged(_:))
        colorSchemesManager.registerPropertyObserver(self, forProperty: \.buttonColor, handler: buttonColorChanged(_:))
        
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
        
        messenger.unsubscribeFromAll()
        fxUnitStateObserverRegistry.removeAllObservers()
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
    
    // ------------------------------------------------------------------------
    
    // MARK: Message handling
    
    private func initSubscriptions() {

        messenger.subscribe(to: .effects_showEffectsUnitTab, handler: showTab(_:))
        
        messenger.subscribe(to: .applyTheme, handler: applyTheme)
        messenger.subscribe(to: .applyFontScheme, handler: applyFontScheme(_:))
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
    
    func colorChanged(to newColor: PlatformColor, forProperty property: ColorSchemeProperty) {
        tabViewButtons[tabView.selectedIndex].redraw()
    }
    
}

extension EffectsContainerViewController: ColorSchemeObserver {
    
    func colorSchemeChanged() {
        
        rootContainerBox.fillColor = systemColorScheme.backgroundColor
        lblCaption.textColor = systemColorScheme.captionTextColor
    }
    
    private func activeControlColorChanged(_ newColor: PlatformColor) {
        updateTabButtons(forUnitState: .active, newColor: newColor)
    }
    
    private func inactiveControlColorChanged(_ newColor: PlatformColor) {
        updateTabButtons(forUnitState: .bypassed, newColor: newColor)
    }
    
    private func suppressedControlColorChanged(_ newColor: PlatformColor) {
        updateTabButtons(forUnitState: .suppressed, newColor: newColor)
    }
    
    private func updateTabButtons(forUnitState unitState: EffectsUnitState, newColor: PlatformColor) {
        
        if graph.masterUnit.state == unitState {
            masterTabViewButton.redraw()
        }
        
        if graph.eqUnit.state == .active {
            eqTabViewButton.redraw()
        }
        
        if graph.pitchShiftUnit.state == .active {
            pitchTabViewButton.redraw()
        }
        
        if graph.timeStretchUnit.state == .active {
            timeTabViewButton.redraw()
        }
        
        if graph.reverbUnit.state == .active {
            reverbTabViewButton.redraw()
        }
        
        if graph.delayUnit.state == .active {
            delayTabViewButton.redraw()
        }
        
        if graph.filterUnit.state == .active {
            filterTabViewButton.redraw()
        }
    }
    
    private func buttonColorChanged(_ newColor: PlatformColor) {
        tabViewButtons[tabView.selectedIndex].redraw()
    }
}
