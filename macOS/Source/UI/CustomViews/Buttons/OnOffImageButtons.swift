//
//  OnOffImageButtons.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

/*
    An image button that can be toggled On/Off and displays different images depending on its state. It conforms to the current system color scheme by conforming to Tintable.
 */
@IBDesignable
class OnOffImageButton: NSButton, Tintable, ColorSchemeable {
    
    var weight: NSFont.Weight = .heavy {
        
        didSet {
            image = image?.withSymbolConfiguration(.init(pointSize: 12, weight: weight))
        }
    }
    
    private var kvoTokens: [NSKeyValueObservation] = []
    
    override var image: NSImage? {
        
        didSet {
            image?.isTemplate = true
        }
    }
    
    func observeColorSchemeProperty(_ keyPath: KeyPath<ColorScheme, NSColor>, forState state: NSControl.StateValue) {
        
        if state == .off {
            
            kvoTokens.append(systemColorScheme.observe(keyPath, options: [.initial, .new]) {[weak self] _, changedValue in
                
                if let newColor = changedValue.newValue {
                    self?.offStateTintColor = newColor
                }
            })
            
        } else {
            
            kvoTokens.append(systemColorScheme.observe(keyPath, options: [.initial, .new]) {[weak self] _, changedValue in
                
                if let newColor = changedValue.newValue {
                    self?.onStateTintColor = newColor
                }
            })
        }
    }
    
    // Tint to be applied when the button is in an "Off" state.
    var offStateTintColor: NSColor = systemColorScheme.buttonOffColor {
        
        didSet {
            
            if !_isOn {
                contentTintColor = offStateTintColor
            }
        }
    }
    
    // Tint to be applied when the button is in an "On" state.
    var onStateTintColor: NSColor = systemColorScheme.buttonColor {
        
        didSet {
            
            if _isOn {
                contentTintColor = onStateTintColor
            }
        }
    }
    
    // The button's tooltip when the button is in an "Off" state
    @IBInspectable var offStateTooltip: String?
    
    // The button's tooltip when the button is in an "On" state
    @IBInspectable var onStateTooltip: String?
    
    var _isOn: Bool = false
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        image?.isTemplate = true
    }
    
    // Sets the button state to be "Off"
    override func off() {
        
        contentTintColor = offStateTintColor
        toolTip = offStateTooltip
        
        _isOn = false
    }
    
    // Sets the button state to be "On"
    override func on() {

        contentTintColor = onStateTintColor
        toolTip = onStateTooltip
        
        _isOn = true
    }
    
    // Convenience function to set the button to "On" if the specified condition is true, and "Off" if not.
    override func onIf(_ condition: Bool) {
        condition ? on() : off()
    }
    
    // Toggles the On/Off state
    override func toggle() {
        _isOn ? off() : on()
    }
    
    // Returns true if the button is in the On state, false otherwise.
    override var isOn: Bool {_isOn}
    
    deinit {
        
        kvoTokens.forEach {
            $0.invalidate()
        }
        
        kvoTokens.removeAll()
    }
}

// Special button used in the effects presets manager.
class EffectsUnitTriStateBypassPreviewButton: EffectsUnitTriStateBypassButton {
    
    override func awakeFromNib() {
        
//        offStateTintFunction = {Colors.Effects.defaultBypassedUnitColor}
//        onStateTintFunction = {Colors.Effects.defaultActiveUnitColor}
//        mixedStateTintFunction = {Colors.Effects.defaultSuppressedUnitColor}
    }
}
