//
//  MultiStateImageButton.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

/*
    An image button that is capable of switching between any finite number of states, and displays a preset image corresponding to each state (example - repeat/shuffle mode buttons)
 */
class MultiStateImageButton: NSButton, Tintable {
    
    private var kvoToken: NSKeyValueObservation?
    
    override var image: NSImage? {
        
        didSet {
            image?.isTemplate = true
        }
    }
    
    // 1-1 mappings of a particular state to a particular image. Intended to be set by code using this button.
    var stateImageMappings: [(state: Any, imageAndColorProperty: (image: NSImage, colorProperty: KeyPath<ColorScheme, NSColor>))]! {
        
        didSet {
            // Each state value is converted to a String representation for storing in a lookup map (map keys needs to be Hashable)
            stateImageMappings.forEach {stateImageMap[String(describing: $0.state)] = $0.imageAndColorProperty}
        }
    }
    
    // 1-1 mappings of a particular state to a particular image. Intended to be set by code using this button.
    var stateToolTipMappings: [(state: Any, toolTip: String)]! {
        
        didSet {
            // Each state value is converted to a String representation for storing in a lookup map (map keys needs to be Hashable)
            stateToolTipMappings.forEach {stateToolTipMap[String(describing: $0.state)] = $0.toolTip}
        }
    }
    
    // Quick lookup for state -> image mappings
    private var stateImageMap: [String: (image: NSImage, colorProperty: KeyPath<ColorScheme, NSColor>)] = [:]
    
    // Quick lookup for state -> image mappings
    private var stateToolTipMap: [String: String] = [:]
    
    // _state is not to be confused with NSButton.state
    private var _state: Any!
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        image?.isTemplate = true
        observeColorSchemeProperty(\.buttonColor)
    }
    
    func observeColorSchemeProperty(_ keyPath: KeyPath<ColorScheme, NSColor>) {
        
        kvoToken?.invalidate()
        
        kvoToken = systemColorScheme.observe(keyPath, options: [.initial, .new]) {[weak self] _, changedValue in
            self?.contentTintColor = changedValue.newValue
        }
    }
    
    // Switches the button's state to a particular state
    func switchState(_ newState: Any) {
        
        _state = newState
        
        // Set the button's image based on the new state
        if let imageAndColorProperty = stateImageMap[String(describing: newState)] {
            
            self.image = imageAndColorProperty.image
            observeColorSchemeProperty(imageAndColorProperty.colorProperty)
        }
        
        if let toolTip = stateToolTipMap[String(describing: newState)] {
            self.toolTip = toolTip
        }
    }
    
    deinit {
        
        kvoToken?.invalidate()
        kvoToken = nil
    }
}
