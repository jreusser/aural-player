//
//  TimeStretchUnitView.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

class TimeStretchUnitView: NSView {
    
    // ------------------------------------------------------------------------
    
    // MARK: UI fields
    
    @IBOutlet weak var timeSlider: TimeStretchSlider!
    
    @IBOutlet weak var btnShiftPitch: EffectsUnitTriStateCheckButton!
    
    @IBOutlet weak var lblTimeStretchRateValue: NSTextField!
    @IBOutlet weak var lblPitchShiftValue: NSTextField!
    
    // ------------------------------------------------------------------------
    
    // MARK: Properties
    
    var rate: Float {
        timeSlider.rate
    }
    
    var shiftPitch: Bool {
        btnShiftPitch.isOn
    }
    
    // ------------------------------------------------------------------------
    
    // MARK: View initialization
    
    func initialize(stateFunction: @escaping EffectsUnitStateFunction) {
        
        timeSlider.effectsUnit = objectGraph.audioGraphDelegate.timeStretchUnit
//        btnShiftPitch.stateFunction = stateFunction
    }
    
    // ------------------------------------------------------------------------
    
    // MARK: View update
    
    func setState(rate: Float, rateString: String,
                  shiftPitch: Bool, shiftPitchString: String) {
        
        btnShiftPitch.onIf(shiftPitch)
        updatePitchShift(shiftPitchString: shiftPitchString)
        
        timeSlider.rate = rate
        lblTimeStretchRateValue.stringValue = rateString
    }
    
    // Updates the label that displays the pitch shift value
    func updatePitchShift(shiftPitchString: String) {
        lblPitchShiftValue.stringValue = shiftPitchString
    }
    
    // Sets the playback rate to a specific value
    func setRate(_ rate: Float, rateString: String, shiftPitchString: String) {
        
        lblTimeStretchRateValue.stringValue = rateString
        timeSlider.rate = rate
        updatePitchShift(shiftPitchString: shiftPitchString)
    }
    
    func applyPreset(_ preset: TimeStretchPreset) {
        
        btnShiftPitch.onIf(preset.shiftPitch)
        btnShiftPitch.stateChanged()
        
        lblPitchShiftValue.stringValue = ValueFormatter.formatPitch(preset.shiftedPitch)
        
        timeSlider.rate = preset.rate
        lblTimeStretchRateValue.stringValue = ValueFormatter.formatTimeStretchRate(preset.rate)
    }
    
    // ------------------------------------------------------------------------
    
    // MARK: Theming
    
    func applyColorScheme(_ scheme: ColorScheme) {
        
        redrawSliders()
        
//        btnShiftPitch.reTint()
        
        btnShiftPitch.attributedAlternateTitle = NSAttributedString(string: btnShiftPitch.title,
                                                                    attributes: [.foregroundColor: scheme.secondaryTextColor])
    }
    
    func redrawSliders() {
        timeSlider.redraw()
    }
}
