//
//  DelayViewController.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

/*
    View controller for the Delay effects unit
 */
class DelayViewController: EffectsUnitViewController {
    
    @IBOutlet weak var delayView: DelayView!
    
    override var nibName: String? {"Delay"}
    
    var delayUnit: DelayUnitDelegateProtocol = objectGraph.audioGraphDelegate.delayUnit
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        
        unitType = .delay
        effectsUnit = delayUnit
        presetsWrapper = PresetsWrapper<DelayPreset, DelayPresets>(delayUnit.presets)
    }
    
    override func oneTimeSetup() {
        
        super.oneTimeSetup()
        delayView.initialize(self.unitStateFunction)
    }

    override func initControls() {

        super.initControls()
        delayView.setState(delayUnit.time, delayUnit.formattedTime, delayUnit.amount, delayUnit.formattedAmount, delayUnit.feedback, delayUnit.formattedFeedback, delayUnit.lowPassCutoff, delayUnit.formattedLowPassCutoff)
    }
    
    override func stateChanged() {
        
        super.stateChanged()
        delayView.stateChanged()
    }

    // Updates the Delay amount parameter
    @IBAction func delayAmountAction(_ sender: AnyObject) {

        delayUnit.amount = delayView.amount
        delayView.setAmount(delayUnit.amount, delayUnit.formattedAmount)
    }

    // Updates the Delay time parameter
    @IBAction func delayTimeAction(_ sender: AnyObject) {

        delayUnit.time = delayView.time
        delayView.setTime(delayUnit.time, delayUnit.formattedTime)
    }

    // Updates the Delay feedback parameter
    @IBAction func delayFeedbackAction(_ sender: AnyObject) {

        delayUnit.feedback = delayView.feedback
        delayView.setFeedback(delayUnit.feedback, delayUnit.formattedFeedback)
    }

    // Updates the Delay low pass cutoff parameter
    @IBAction func delayCutoffAction(_ sender: AnyObject) {

        delayUnit.lowPassCutoff = delayView.cutoff
        delayView.setCutoff(delayUnit.lowPassCutoff, delayUnit.formattedLowPassCutoff)
    }
    
    override func applyColorScheme(_ scheme: ColorScheme) {
        
        super.applyColorScheme(scheme)
        changeSliderColors()
    }
    
    override func changeSliderColors() {
        delayView.redrawSliders()
    }
    
    override func changeActiveUnitStateColor(_ color: NSColor) {
        
        super.changeActiveUnitStateColor(color)
        delayView.redrawSliders()
    }
    
    override func changeBypassedUnitStateColor(_ color: NSColor) {
        
        super.changeBypassedUnitStateColor(color)
        delayView.redrawSliders()
    }
    
    override func changeSuppressedUnitStateColor(_ color: NSColor) {
        
        super.changeSuppressedUnitStateColor(color)
        delayView.redrawSliders()
    }
}
