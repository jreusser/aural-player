//
//  ReverbUnitView.swift
//  Aural
//
//  Copyright © 2023 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

class ReverbUnitView: NSView {
    
    // ------------------------------------------------------------------------
    
    // MARK: UI fields
    
    @IBOutlet weak var reverbSpaceMenu: NSPopUpButton!
    @IBOutlet weak var reverbAmountSlider: EffectsUnitSlider!
    @IBOutlet weak var lblReverbAmountValue: NSTextField!
    
    // ------------------------------------------------------------------------
    
    // MARK: View init
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        
        fontSchemesManager.registerObserver(reverbSpaceMenu, forProperties: [\.effectsPrimaryFont])
//        colorSchemesManager.registerSchemeObserver(reverbSpaceMenu, forProperties: [\.buttonColor, \.primaryTextColor])
        
        if let popupMenuCell = reverbSpaceMenu.cell as? EffectsUnitPopupMenuCell {
            fxUnitStateObserverRegistry.registerObserver(popupMenuCell, forFXUnit: audioGraphDelegate.reverbUnit)
        }
        
//        colorSchemesManager.registerSchemeObserver(self, forProperties: [\.activeControlColor, \.inactiveControlColor, \.suppressedControlColor])
    }
    
    // ------------------------------------------------------------------------
    
    // MARK: Properties
    
    var spaceString: String {
        reverbSpaceMenu.titleOfSelectedItem!
    }
    
    var amount: Float {
        reverbAmountSlider.floatValue
    }
    
    // ------------------------------------------------------------------------
    
    // MARK: View update
    
    func setState(space: String, amount: Float, amountString: String) {
        
        setSpace(space)
        setAmount(amount, amountString: amountString)
    }
    
    func setSpace(_ space: String) {
        reverbSpaceMenu.selectItem(withTitle: space)
    }
    
    func setAmount(_ amount: Float, amountString: String) {
        
        reverbAmountSlider.floatValue = amount
        lblReverbAmountValue.stringValue = amountString
    }
    
    func applyPreset(_ preset: ReverbPreset) {
        
        setSpace(preset.space.description)
        setAmount(preset.amount, amountString: ValueFormatter.formatReverbAmount(preset.amount))
    }
    
    func updatePopupMenuColor(_ newColor: PlatformColor) {
        
        if let popupMenuCell = reverbSpaceMenu.cell as? EffectsUnitPopupMenuCell {
            popupMenuCell.tintColor = newColor
//            popupMenuCell.tintColor = systemColorScheme.colorForEffectsUnitState(audioGraphDelegate.reverbUnit.state)
        }
    }
}
