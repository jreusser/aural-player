//
//  EffectsUnitViewController.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

class EffectsUnitViewController: NSViewController, Destroyable {
    
    // ------------------------------------------------------------------------
    
    // MARK: UI fields

    @IBOutlet weak var btnBypass: EffectsUnitTriStateBypassButton!
    
    // Presets controls
    @IBOutlet weak var presetsMenuButton: NSPopUpButton!
    @IBOutlet weak var presetsMenuIconItem: TintedIconMenuItem!
    @IBOutlet weak var btnSavePreset: TintedImageButton!
    lazy var userPresetsPopover: StringInputPopoverViewController = .create(self)
    
    // Labels
    var functionLabels: [NSTextField] = []
    var functionCaptionLabels: [NSTextField] = []
    var functionValueLabels: [NSTextField] = []
    
    var buttons: [TintedImageButton] = []
    var sliders: [EffectsUnitSlider] = []
    
    // ------------------------------------------------------------------------
    
    // MARK: Services, utilities, helpers, and properties
    
    let graph: AudioGraphDelegateProtocol = audioGraphDelegate
    
    var effectsUnit: EffectsUnitDelegateProtocol!
    var unitType: EffectsUnitType {effectsUnit.unitType}
    var unitStateFunction: EffectsUnitStateFunction {effectsUnit.stateFunction}
    
    var presetsWrapper: PresetsWrapperProtocol!
    
    lazy var messenger = Messenger(for: self)
    
    // ------------------------------------------------------------------------
    
    // MARK: UI initialization / life-cycle
    
    override func viewDidLoad() {
        
        oneTimeSetup()
        initControls()
        
        // TODO: Temporary, remove this !!!
//        presetsMenuButton.hide()
    }
    
    func oneTimeSetup() {
        
        fxUnitStateObserverRegistry.registerObserver(btnBypass, forFXUnit: effectsUnit)
        
//        btnSavePreset.tintFunction = {Colors.functionButtonColor}
//        presetsMenuIconItem.tintFunction = {Colors.functionButtonColor}
        
        findThemeableComponents(under: view)
        
        initSubscriptions()
    }
    
    func findThemeableComponents(under view: NSView) {
        
        for subview in view.subviews {
            
            if let label = subview as? NSTextField {
                
                if label is FunctionLabel {
                    functionLabels.append(label)
                }
                
                if label is FunctionCaptionLabel {
                    functionCaptionLabels.append(label)
                    
                } else if label is FunctionValueLabel {
                    functionValueLabels.append(label)
                }
                
            } else if let btn = subview as? TintedImageButton {
                
                buttons.append(btn)
                
            } else if let slider = subview as? EffectsUnitSlider {
                
                sliders.append(slider)
                
            } else {
                
                // Recursive call
                findThemeableComponents(under: subview)
            }
        }
    }
    
    func destroy() {
        messenger.unsubscribeFromAll()
    }
    
    func initControls() {
        
        stateChanged()
        presetsMenuButton.deselect()
    }
    
    // ------------------------------------------------------------------------
    
    // MARK: Actions
    
    @IBAction func bypassAction(_ sender: AnyObject) {

        _ = effectsUnit.toggleState()
        stateChanged()
        
        messenger.publish(.effects_unitStateChanged)
    }
    
    // Applies a preset to the effects unit
    @IBAction func presetsAction(_ sender: AnyObject) {
        
        if let selectedPresetItem = presetsMenuButton.titleOfSelectedItem {
            
            effectsUnit.applyPreset(named: selectedPresetItem)
            initControls()
        }
    }
    
    // Displays a popover to allow the user to name the new custom preset
    @IBAction func savePresetAction(_ sender: AnyObject) {
        userPresetsPopover.show(btnSavePreset, .minY)
    }
    
    // ------------------------------------------------------------------------
    
    // MARK: Message handling
    
    func initSubscriptions() {
        
        // Subscribe to notifications
        messenger.subscribe(to: .effects_unitStateChanged, handler: stateChanged)
        
        // FIXME: Revisit this filter logic.
        messenger.subscribe(to: .effects_updateEffectsUnitView,
                            handler: initControls,
                            filter: {[weak self] (unitType: EffectsUnitType) in
                                unitType.equalsOneOf(self?.unitType, .master)
                            })
        
//        messenger.subscribe(to: .effects_changeSliderColors, handler: changeSliderColors)
        
        colorSchemesManager.registerObserver(presetsMenuIconItem, forProperty: \.buttonColor)
        
        colorSchemesManager.registerObservers(functionCaptionLabels, forProperty: \.secondaryTextColor)
        colorSchemesManager.registerObservers(functionValueLabels, forProperty: \.primaryTextColor)
        
        colorSchemesManager.registerObservers(buttons, forProperty: \.buttonColor)
        
        sliders.forEach {
            fxUnitStateObserverRegistry.registerObserver($0, forFXUnit: effectsUnit)
        }
        
        colorSchemesManager.registerSchemeObservers(sliders, forProperties: [\.backgroundColor])
        
        fontSchemesManager.registerObservers(functionLabels, forProperty: \.effectsPrimaryFont)
        
//        messenger.subscribe(to: .changeFunctionButtonColor, handler: changeFunctionButtonColor(_:))
//        messenger.subscribe(to: .changeMainCaptionTextColor, handler: changeMainCaptionTextColor(_:))
//
//        messenger.subscribe(to: .effects_changeFunctionCaptionTextColor, handler: changeFunctionCaptionTextColor(_:))
//        messenger.subscribe(to: .effects_changeFunctionValueTextColor, handler: changeFunctionValueTextColor(_:))
//
//        messenger.subscribe(to: .effects_changeActiveUnitStateColor, handler: changeActiveUnitStateColor(_:))
//        messenger.subscribe(to: .effects_changeBypassedUnitStateColor, handler: changeBypassedUnitStateColor(_:))
//        messenger.subscribe(to: .effects_changeSuppressedUnitStateColor, handler: changeSuppressedUnitStateColor(_:))
    }
    
    func stateChanged() {
//        btnBypass.setUnitState(effectsUnit.state)
    }
    
    func mouseEnteredView() {
        presetsMenuButton.show()
    }
    
    func mouseExitedView() {
        presetsMenuButton.hide()
    }
    
    // ------------------------------------------------------------------------
    
    // MARK: Helper functions
    
    func showThisTab() {
        messenger.publish(.effects_showEffectsUnitTab, payload: unitType)
    }
}

// ------------------------------------------------------------------------

// MARK: StringInputReceiver

extension EffectsUnitViewController: StringInputReceiver {
    
    var inputPrompt: String {
        "Enter a new preset name:"
    }
    
    var defaultValue: String? {
        "<New preset>"
    }
    
    func validate(_ string: String) -> (valid: Bool, errorMsg: String?) {
        
        if presetsWrapper.presetExists(named: string) {
            return (false, "Preset with this name already exists !")
        } else {
            return (true, nil)
        }
    }
    
    // Receives a new EQ preset name and saves the new preset
    func acceptInput(_ string: String) {
        effectsUnit.savePreset(named: string)
    }
}

// ------------------------------------------------------------------------

// MARK: NSMenuDelegate

extension EffectsUnitViewController: NSMenuDelegate {
    
    func menuNeedsUpdate(_ menu: NSMenu) {
        
        presetsMenuButton.recreateMenu(insertingItemsAt: 1, fromItems: presetsWrapper.userDefinedPresets)
        
        // Don't select any items from the EQ presets menu
        presetsMenuButton.deselect()
    }
}
