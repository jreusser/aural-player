//
//  EffectsUnitLabels.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  
import Cocoa

// Marker classes / protocols to differentiate between different types of labels when
// recursively traversing through a view tree.

protocol FunctionLabel {}

protocol FunctionCaptionLabel: FunctionLabel {}

protocol FunctionValueLabel: FunctionLabel {}

class CenterTextFunctionCaptionLabel: CenterTextLabel, FunctionCaptionLabel {
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        observeColorSchemeProperty(\.secondaryTextColor)
    }
}

class TopTextFunctionCaptionLabel: TopTextLabel, FunctionCaptionLabel {
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        observeColorSchemeProperty(\.secondaryTextColor)
    }
}

class BottomTextFunctionCaptionLabel: BottomTextLabel, FunctionCaptionLabel {
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        observeColorSchemeProperty(\.secondaryTextColor)
    }
}

class CenterTextFunctionValueLabel: CenterTextLabel, FunctionValueLabel {
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        observeColorSchemeProperty(\.primaryTextColor)
    }
}
