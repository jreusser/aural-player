//
//  EQUnitViewController.swift
//  Aural
//
//  Copyright © 2023 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

/*
    View controller for the EQ (Equalizer) effects unit
 */
class EQUnitViewController: EffectsUnitViewController {
    
    override var nibName: String? {"EQUnit"}
    
    // ------------------------------------------------------------------------
    
    // MARK: UI fields
    
    @IBOutlet weak var eqUnitView: EQUnitView!
    
    // ------------------------------------------------------------------------
    
    // MARK: Services, utilities, helpers, and properties
    
    private var eqUnit: EQUnitDelegateProtocol = audioGraphDelegate.eqUnit
    
    // ------------------------------------------------------------------------
    
    // MARK: UI initialization / life-cycle
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        
        self.effectsUnit = graph.eqUnit
        self.presetsWrapper = PresetsWrapper<EQPreset, EQPresets>(eqUnit.presets)
    }
    
    override func oneTimeSetup() {
        
        super.oneTimeSetup()
        eqUnitView.initialize(eqStateFunction: unitStateFunction,
                              sliderAction: #selector(self.eqSliderAction(_:)), sliderActionTarget: self)
    }
    
    override func initControls() {
        
        super.initControls()
        eqUnitView.setState(bands: eqUnit.bands, globalGain: eqUnit.globalGain)
    }
    
    override func destroy() {
        
        super.destroy()
        eqUnitView.destroy()
    }
    
    // ------------------------------------------------------------------------
    
    // MARK: Actions
    
    @IBAction func eqGlobalGainAction(_ sender: EffectsUnitSlider) {
        eqUnit.globalGain = sender.floatValue
    }
    
    // Updates the gain value of a single frequency band (specified by the slider parameter) of the Equalizer
    @IBAction func eqSliderAction(_ sender: EffectsUnitSlider) {
        eqUnit[sender.tag] = sender.floatValue
    }
    
    // ------------------------------------------------------------------------
    
    // MARK: Message handling
    
    override func initSubscriptions() {
        
        super.initSubscriptions()
        
        messenger.subscribe(to: .eqEffectsUnit_decreaseBass, handler: decreaseBass)
        messenger.subscribe(to: .eqEffectsUnit_increaseBass, handler: increaseBass)
        
        messenger.subscribe(to: .eqEffectsUnit_decreaseMids, handler: decreaseMids)
        messenger.subscribe(to: .eqEffectsUnit_increaseMids, handler: increaseMids)
        
        messenger.subscribe(to: .eqEffectsUnit_decreaseTreble, handler: decreaseTreble)
        messenger.subscribe(to: .eqEffectsUnit_increaseTreble, handler: increaseTreble)
    }
    
    // Provides a "bass boost". Increases each of the EQ bass bands by a certain preset increment.
    private func increaseBass() {
        bandsUpdated(eqUnit.increaseBass())
    }
    
    // Decreases each of the EQ bass bands by a certain preset decrement
    private func decreaseBass() {
        bandsUpdated(eqUnit.decreaseBass())
    }
    
    // Increases each of the EQ mid-frequency bands by a certain preset increment
    private func increaseMids() {
        bandsUpdated(eqUnit.increaseMids())
    }
    
    // Decreases each of the EQ mid-frequency bands by a certain preset decrement
    private func decreaseMids() {
        bandsUpdated(eqUnit.decreaseMids())
    }
    
    // Decreases each of the EQ treble bands by a certain preset increment
    private func increaseTreble() {
        bandsUpdated(eqUnit.increaseTreble())
    }
    
    // Decreases each of the EQ treble bands by a certain preset decrement
    private func decreaseTreble() {
        bandsUpdated(eqUnit.decreaseTreble())
    }
    
    private func bandsUpdated(_ bands: [Float]) {
        
        stateChanged()
        eqUnitView.bandsUpdated(bands, globalGain: eqUnit.globalGain)
        
        messenger.publish(.effects_unitStateChanged)
        showThisTab()
    }
    
    // ------------------------------------------------------------------------
    
    // MARK: Theming
    
//    override func applyColorScheme(_ scheme: ColorScheme) {
//
//        super.applyColorScheme(scheme)
//        changeSliderColors()
//    }
}
