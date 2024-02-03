//
//  ButtonStateMachine.swift
//  Aural-macOS
//
//  Copyright © 2023 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import Cocoa

class ButtonStateMachine<E>: NSObject, ColorSchemeObserver where E: Hashable {
    
    var state: E
    private let button: NSButton
    private(set) var mappings: [E: StateMapping] = [:]
    
//    var hashValue: Int {
//        button.hashValue
//    }
    
    struct StateMapping {
        
        let state: E
        let image: PlatformImage
        let colorProperty: ColorSchemeProperty
        let toolTip: String?
    }
    
    init(initialState: E, mappings: [StateMapping], button: NSButton) {
        
        self.state = initialState
        self.button = button
        
        for mapping in mappings {
            self.mappings[mapping.state] = mapping
        }
        
        super.init()

        doSetState(initialState)
        colorSchemesManager.registerSchemeObserver(self)
    }
    
    // Switches the button's state to a particular state
    func setState(_ newState: E) {
        
        if self.state != newState {
            doSetState(newState)
        }
    }
    
    private func doSetState(_ newState: E) {
        
        guard let mapping = mappings[newState] else {return}
        
        let oldState = self.state
        self.state = newState
        
        button.image = mapping.image
        
        if let oldColorProp = mappings[oldState]?.colorProperty {
            colorSchemesManager.removePropertyObserver(self, forProperty: oldColorProp)
        }
        
        colorSchemesManager.registerPropertyObserver(self, forProperty: mapping.colorProperty, changeReceiver: button)
        
        button.toolTip = mapping.toolTip
    }
    
    func colorSchemeChanged() {
        
        if let colorProp = mappings[state]?.colorProperty {
            button.colorChanged(systemColorScheme[keyPath: colorProp])
        }
    }
}
