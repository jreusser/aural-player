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
class OnOffImageButton: NSButton, ColorSchemeable {
    
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
        
        kvoTokens.append(systemColorScheme.observe(keyPath, options: [.initial, .new]) {[weak self] _, changedValue in
            
            if let strongSelf = self, strongSelf is EffectsUnitTriStateBypassButton {
                
                print("State HERE is: \(strongSelf.state.rawValue)")
                
                if strongSelf.state == state, let newColor = changedValue.newValue {
                    
                    if state == .mixed {
                        print("RESPONDED TO MIXED STATE COLOR CHANGE !")
                    }
                    strongSelf.contentTintColor = newColor
                }
            }
        })
    }
    
    // The button's tooltip when the button is in an "Off" state
    @IBInspectable var offStateTooltip: String?
    
    // The button's tooltip when the button is in an "On" state
    @IBInspectable var onStateTooltip: String?
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        image?.isTemplate = true
    }
    
    // Sets the button state to be "Off"
    override func off() {
        
        contentTintColor = systemColorScheme.inactiveControlColor
        toolTip = offStateTooltip
        
        super.off()
    }
    
    // Sets the button state to be "On"
    override func on() {

        contentTintColor = systemColorScheme.buttonColor
        toolTip = onStateTooltip
        
        super.on()
    }
    
    // Convenience function to set the button to "On" if the specified condition is true, and "Off" if not.
    override func onIf(_ condition: Bool) {
        condition ? on() : off()
    }
    
    // Toggles the On/Off state
    override func toggle() {
        isOn ? off() : on()
    }
    
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
