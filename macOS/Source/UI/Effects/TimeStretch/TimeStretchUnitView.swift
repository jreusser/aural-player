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
    
    @IBOutlet weak var btnShiftPitch: EffectsUnitToggle!
    
    @IBOutlet weak var lblTimeStretchRateValue: NSTextField!
    
    // ------------------------------------------------------------------------
    
    // MARK: Properties
    
    var rate: Float {
        timeSlider.rate
    }
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        
        fxUnitStateObserverRegistry.registerObserver(btnShiftPitch, forFXUnit: audioGraphDelegate.timeStretchUnit)
        colorSchemesManager.registerObserver(self, forProperties: [\.activeControlColor, \.inactiveControlColor, \.suppressedControlColor])
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
        
        btnShiftPitch.onIf(preset.shiftPitch)
        
        timeSlider.rate = preset.rate
        lblTimeStretchRateValue.stringValue = ValueFormatter.formatTimeStretchRate(preset.rate)
    }
    
    func colorChanged(to newColor: PlatformColor, forProperty property: KeyPath<ColorScheme, PlatformColor>) {
        
        let timeStretchUnit = audioGraphDelegate.timeStretchUnit
     
        switch property {
            
        case \.activeControlColor:
            
            if timeStretchUnit.isActive {
                btnShiftPitch.redraw(forState: .active)
            }
            
        case \.inactiveControlColor:
            
            if timeStretchUnit.state == .bypassed {
                btnShiftPitch.redraw(forState: .bypassed)
            }
            
        case \.suppressedControlColor:
            
            if timeStretchUnit.state == .suppressed {
                btnShiftPitch.redraw(forState: .suppressed)
            }
            
        default:
            return
        }
    }
}
