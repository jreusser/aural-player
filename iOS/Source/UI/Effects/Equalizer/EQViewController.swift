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
    
    @IBOutlet weak var btnBypass: UIButton!
    
    private var eqUnit: EQUnitDelegateProtocol = audioGraphDelegate.eqUnit
    
    private var initialized: Bool = false
    
    ///
    /// Sets the state of the controls based on the current state of the equalizer.
    ///
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        
        if initialized {return}
        
        // Discover the EQ band sliders among this view's subviews.
        // The band sliders have a tag value that is >= 0.
        // Perform filtering to exclude the global gain slider.
        let allSliders = view.subviews.compactMap {$0 as? UISlider}
        bandSliders = allSliders.filter {$0.tag >= 0}.sorted(by: {$0.tag < $1.tag})
        
        navigationItem.title = "Equalizer Settings"
        
        // Rotate the sliders by 90 degrees counter-clockwise (to make them vertical).
        allSliders.forEach {
            $0.transform = $0.transform.rotated(by: CGFloat(3 * Float.pi / 2))
        }
        
        btnBypass.tintColor = eqUnit.isActive ? .blue : .gray
        
        bandSliders.forEach {
            $0.value = eqUnit[$0.tag]
        }
        
        initialized = true
    }
    
    @IBAction func eqBypassAction(_ sender: UIButton) {
        
        _ = eqUnit.toggleState()
        btnBypass.tintColor = eqUnit.isActive ? .blue : .gray
    }
    
    @IBAction func eqGlobalGainAction(_ sender: UISlider) {
        eqUnit.globalGain = sender.value
    }
    
    @IBAction func eqBandAction(_ sender: UISlider) {
        eqUnit[sender.tag] = sender.value
    }
}
