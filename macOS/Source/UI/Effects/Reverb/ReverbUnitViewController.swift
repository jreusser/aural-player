//
//  ReverbUnitViewController.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

/*
    View controller for the Reverb effects unit
 */
class ReverbUnitViewController: EffectsUnitViewController {
    
    override var nibName: String? {"ReverbUnit"}
    
    // ------------------------------------------------------------------------
    
    // MARK: UI fields
    
    @IBOutlet weak var reverbUnitView: ReverbUnitView!
    
    // ------------------------------------------------------------------------
    
    // MARK: Services, utilities, helpers, and properties
    
    var reverbUnit: ReverbUnitDelegateProtocol = audioGraphDelegate.reverbUnit
    
    // ------------------------------------------------------------------------
    
    // MARK: UI initialization / life-cycle
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        
        effectsUnit = graph.reverbUnit
        presetsWrapper = PresetsWrapper<ReverbPreset, ReverbPresets>(reverbUnit.presets)
    }
    
    override func initControls() {
        
        super.initControls()
        
        reverbUnitView.setState(space: reverbUnit.space.description,
                                amount: reverbUnit.amount,
                                amountString: reverbUnit.formattedAmount)
    }
    
    // ------------------------------------------------------------------------
    
    // MARK: Actions

    // Updates the Reverb preset
    @IBAction func reverbSpaceAction(_ sender: AnyObject) {
        reverbUnit.space = ReverbSpace.fromDescription(reverbUnitView.spaceString)
    }

    // Updates the Reverb amount parameter
    @IBAction func reverbAmountAction(_ sender: AnyObject) {
        
        reverbUnit.amount = reverbUnitView.amount
        reverbUnitView.setAmount(reverbUnit.amount, amountString: reverbUnit.formattedAmount)
    }
}
