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

class TimeStretchUnitView: NSView, ColorSchemePropertyObserver {
    
    // ------------------------------------------------------------------------
    
    // MARK: UI fields
    
    @IBOutlet weak var timeSlider: TimeStretchSlider!
    
    @IBOutlet weak var btnShiftPitch: TintedImageButton!
    
    @IBOutlet weak var lblTimeStretchRateValue: NSTextField!
    
    private lazy var btnShiftPitchStateMachine: ButtonStateMachine<Bool> = ButtonStateMachine(initialState: audioGraphDelegate.timeStretchUnit.shiftPitch,
                                                                                              mappings: [
                                                                                                ButtonStateMachine.StateMapping(state: true, image: .imgChecked, colorProperty: \.buttonColor, toolTip: "Disable Pitch Shift"),
                                                                                                ButtonStateMachine.StateMapping(state: false, image: .imgNotChecked, colorProperty: \.buttonColor, toolTip: "Enable Pitch Shift"),
                                                                                              ],
                                                                                              button: btnShiftPitch)
    
    // ------------------------------------------------------------------------
    
    // MARK: Properties
    
    var rate: Float {
        timeSlider.rate
    }
    
    var shiftPitch: Bool {
        
        get {btnShiftPitchStateMachine.state}
        
        set {btnShiftPitchStateMachine.setState(newValue)}
    }
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        colorSchemesManager.registerObserver(self, forProperty: \.buttonColor)
    }
    
    // ------------------------------------------------------------------------
    
    // MARK: View update
    
    func setState(rate: Float, rateString: String,
                  shiftPitch: Bool, shiftPitchString: String) {
        
        btnShiftPitch.onIf(shiftPitch)
        
        timeSlider.rate = rate
        lblTimeStretchRateValue.stringValue = rateString
    }
    
    // Sets the playback rate to a specific value
    func setRate(_ rate: Float, rateString: String, shiftPitchString: String) {
        
        lblTimeStretchRateValue.stringValue = rateString
        timeSlider.rate = rate
    }
    
    func applyPreset(_ preset: TimeStretchPreset) {
        
        btnShiftPitchStateMachine.setState(preset.shiftPitch)
        
        timeSlider.rate = preset.rate
        lblTimeStretchRateValue.stringValue = ValueFormatter.formatTimeStretchRate(preset.rate)
    }
    
    // ------------------------------------------------------------------------
    
    // MARK: Theming
    
    func colorChanged(to newColor: PlatformColor, forProperty property: KeyPath<ColorScheme, PlatformColor>) {
        
        switch property {
            
        case \.buttonColor:
            
            btnShiftPitch.image = btnShiftPitch.image?.tintedWithColor(newColor)
            btnShiftPitch.alternateImage = btnShiftPitch.alternateImage?.tintedWithColor(newColor)
            
        default:
            
            return
        }
    }
}
