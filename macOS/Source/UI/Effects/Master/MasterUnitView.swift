//
//  MasterUnitView.swift
//  Aural
//
//  Copyright © 2023 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

class MasterUnitView: NSView {
    
    @IBOutlet weak var btnEQBypass: EffectsUnitTriStateBypassButton!
    @IBOutlet weak var btnPitchBypass: EffectsUnitTriStateBypassButton!
    @IBOutlet weak var btnTimeBypass: EffectsUnitTriStateBypassButton!
    @IBOutlet weak var btnReverbBypass: EffectsUnitTriStateBypassButton!
    @IBOutlet weak var btnDelayBypass: EffectsUnitTriStateBypassButton!
    @IBOutlet weak var btnFilterBypass: EffectsUnitTriStateBypassButton!
    
    @IBOutlet weak var imgEQBypass: EffectsUnitTriStateBypassImage!
    @IBOutlet weak var imgPitchBypass: EffectsUnitTriStateBypassImage!
    @IBOutlet weak var imgTimeBypass: EffectsUnitTriStateBypassImage!
    @IBOutlet weak var imgReverbBypass: EffectsUnitTriStateBypassImage!
    @IBOutlet weak var imgDelayBypass: EffectsUnitTriStateBypassImage!
    @IBOutlet weak var imgFilterBypass: EffectsUnitTriStateBypassImage!
    
    @IBOutlet weak var imgAUBypass: EffectsUnitTriStateBypassImage!
    
    @IBOutlet weak var lblEQ: EffectsUnitTriStateLabel!
    @IBOutlet weak var lblPitch: EffectsUnitTriStateLabel!
    @IBOutlet weak var lblTime: EffectsUnitTriStateLabel!
    @IBOutlet weak var lblReverb: EffectsUnitTriStateLabel!
    @IBOutlet weak var lblDelay: EffectsUnitTriStateLabel!
    @IBOutlet weak var lblFilter: EffectsUnitTriStateLabel!
    
    @IBOutlet weak var lblAudioUnits: EffectsUnitTriStateLabel!
    
    var buttons: [EffectsUnitTriStateBypassButton] = []
    var images: [EffectsUnitTriStateBypassImage] = []
    var labels: [EffectsUnitTriStateLabel] = []
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        
        buttons = [btnEQBypass, btnPitchBypass, btnTimeBypass, btnReverbBypass, btnDelayBypass, btnFilterBypass]
        images = [imgEQBypass, imgPitchBypass, imgTimeBypass, imgReverbBypass, imgDelayBypass, imgFilterBypass, imgAUBypass]
        labels = [lblEQ, lblPitch, lblTime, lblReverb, lblDelay, lblFilter, lblAudioUnits]
        
        let audioGraph = audioGraphDelegate
        
        ([btnEQBypass, imgEQBypass, lblEQ] as! [FXUnitStateObserver]).forEach {
            fxUnitStateObserverRegistry.registerObserver($0, forFXUnit: audioGraph.eqUnit)
        }

        ([btnPitchBypass, imgPitchBypass, lblPitch] as! [FXUnitStateObserver]).forEach {
            fxUnitStateObserverRegistry.registerObserver($0, forFXUnit: audioGraph.pitchShiftUnit)
        }

        ([btnTimeBypass, imgTimeBypass, lblTime] as! [FXUnitStateObserver]).forEach {
            fxUnitStateObserverRegistry.registerObserver($0, forFXUnit: audioGraph.timeStretchUnit)
        }

        ([btnReverbBypass, imgReverbBypass, lblReverb] as! [FXUnitStateObserver]).forEach {
            fxUnitStateObserverRegistry.registerObserver($0, forFXUnit: audioGraph.reverbUnit)
        }

        ([btnDelayBypass, imgDelayBypass, lblDelay] as! [FXUnitStateObserver]).forEach {
            fxUnitStateObserverRegistry.registerObserver($0, forFXUnit: audioGraph.delayUnit)
        }

        ([btnFilterBypass, imgFilterBypass, lblFilter] as! [FXUnitStateObserver]).forEach {
            fxUnitStateObserverRegistry.registerObserver($0, forFXUnit: audioGraph.filterUnit)
        }
        
        ([imgAUBypass, lblAudioUnits] as! [FXUnitStateObserver]).forEach {
            fxUnitStateObserverRegistry.registerAUObserver($0)
        }
        
        fontSchemesManager.registerObservers(labels, forProperty: \.captionFont)
    }
    
    func applyPreset(_ preset: MasterPreset) {
        
        btnEQBypass.onIf(preset.eq.state == .active)
        btnPitchBypass.onIf(preset.pitch.state == .active)
        btnTimeBypass.onIf(preset.time.state == .active)
        btnReverbBypass.onIf(preset.reverb.state == .active)
        btnDelayBypass.onIf(preset.delay.state == .active)
        btnFilterBypass.onIf(preset.filter.state == .active)
        
        imgEQBypass.onIf(preset.eq.state == .active)
        imgPitchBypass.onIf(preset.pitch.state == .active)
        imgTimeBypass.onIf(preset.time.state == .active)
        imgReverbBypass.onIf(preset.reverb.state == .active)
        imgDelayBypass.onIf(preset.delay.state == .active)
        imgFilterBypass.onIf(preset.filter.state == .active)
        
        lblEQ.onIf(preset.eq.state == .active)
        lblPitch.onIf(preset.pitch.state == .active)
        lblTime.onIf(preset.time.state == .active)
        lblReverb.onIf(preset.reverb.state == .active)
        lblDelay.onIf(preset.delay.state == .active)
        lblFilter.onIf(preset.filter.state == .active)
    }
    
    func updateEQUnitToggle(_ newColor: PlatformColor) {
        
        btnEQBypass.contentTintColor = newColor
        imgEQBypass.contentTintColor = newColor
        lblEQ.textColor = newColor
    }
    
    func updatePitchShiftUnitToggle(_ newColor: PlatformColor) {
        
        btnPitchBypass.contentTintColor = newColor
        imgPitchBypass.contentTintColor = newColor
        lblPitch.textColor = newColor
    }
    
    func updateTimeStretchUnitToggle(_ newColor: PlatformColor) {
        
        btnTimeBypass.contentTintColor = newColor
        imgTimeBypass.contentTintColor = newColor
        lblTime.textColor = newColor
    }
    
    func updateReverbUnitToggle(_ newColor: PlatformColor) {
        
        btnReverbBypass.contentTintColor = newColor
        imgReverbBypass.contentTintColor = newColor
        lblReverb.textColor = newColor
    }
    
    func updateDelayUnitToggle(_ newColor: PlatformColor) {
        
        btnDelayBypass.contentTintColor = newColor
        imgDelayBypass.contentTintColor = newColor
        lblDelay.textColor = newColor
    }
    
    func updateFilterUnitToggle(_ newColor: PlatformColor) {
        
        btnFilterBypass.contentTintColor = newColor
        imgFilterBypass.contentTintColor = newColor
        lblFilter.textColor = newColor
    }
}
