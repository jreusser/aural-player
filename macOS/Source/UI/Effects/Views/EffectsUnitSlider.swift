//
//  EffectsUnitSlider.swift
//  Aural
//
//  Copyright © 2023 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

protocol EffectsUnitSliderProtocol {
    
    var effectsUnit: EffectsUnitDelegateProtocol! {get set}
}

protocol EffectsUnitSliderCellProtocol {
    
    var effectsUnit: EffectsUnitDelegateProtocol! {get set}
}

extension NSSlider {

    public override func setNeedsDisplay(_ invalidRect: NSRect) {
        super.setNeedsDisplay(bounds)
    }
}

class EffectsUnitSlider: NSSlider, FXUnitStateObserver {
    
    override var isFlipped: Bool {false}
}
