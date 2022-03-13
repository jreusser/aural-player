//
//  ButtonStateMachine.swift
//  Aural-macOS
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import Foundation

class ButtonStateMachine<E> where E: Hashable {
    
    private var state: E
    private let button: TintedImageButton
    private(set) var mappings: [E: StateMapping] = [:]
    
    private let colorSchemesManager: ColorSchemesManager = objectGraph.colorSchemesManager
    
    struct StateMapping {
        
        let state: E
        let image: PlatformImage
        let colorProperty: KeyPath<ColorScheme, PlatformColor>
        let toolTip: String?
    }
    
    init(initialState: E, mappings: [StateMapping], button: TintedImageButton) {
        
        self.state = initialState
        self.button = button
        
        for mapping in mappings {
            self.mappings[mapping.state] = mapping
        }

        doSetState(initialState)
    }
    
    // Switches the button's state to a particular state
    func setState(_ newState: E) {
        
        if self.state != newState {
            doSetState(newState)
        }
    }
    
    private func doSetState(_ newState: E) {
        
        guard let mapping = mappings[newState] else {return}
        
        self.state = newState
        
        button.image = mapping.image
        
        colorSchemesManager.removeObserver(button)
        colorSchemesManager.registerObserver(button, forProperty: mapping.colorProperty)
        
        button.toolTip = mapping.toolTip
    }
}
