//
//  EQViewController.swift
//  Aural-iOS
//
//  Created by Kartik Venugopal on 9/23/22.
//

import UIKit

class EQViewController: UIViewController {
    
    /// The sliders corresponding to all the bands of the equalizer.
    private var bandSliders: [UISlider] = []
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        doViewWillAppear()
    }
    
    private var rotated: Bool = false
    
    private var eqUnit: EQUnitDelegateProtocol = audioGraphDelegate.eqUnit
    
    ///
    /// Sets the state of the controls based on the current state of the equalizer.
    ///
    private func doViewWillAppear() {
        
        if rotated {return}
        
        // Discover the EQ band sliders among this view's subviews.
        // The band sliders have a tag value that is >= 0.
        // Perform filtering to exclude the global gain slider.
        bandSliders = view.subviews.compactMap {$0 as? UISlider}.filter {$0.tag >= 0}.sorted(by: {$0.tag < $1.tag})
        
        navigationItem.title = "Equalizer Settings"
        
        // Rotate the sliders by 90 degrees counter-clockwise (to make them vertical).
        bandSliders.forEach {
            $0.transform = $0.transform.rotated(by: CGFloat(3 * Float.pi / 2))
        }
        
        rotated = true
        
//        player.eqBypass ? bypassSwitch.off() : bypassSwitch.on()
//        lblBypassState.text = bypassSwitch.isOn ? "Active" : "Bypassed"
//
//        globalGainSlider.floatValue = player.eqGlobalGain
//
//        // Set the band sliders' values based on the gain value of the corresponding equalizer band.
//        for (index, band) in player.eqBands.enumerated() {
//            bandSliders[index].floatValue = band
//        }
    }
    
    @IBAction func eqBandAction(_ sender: UISlider) {
        eqUnit[sender.tag] = sender.value
    }
}
