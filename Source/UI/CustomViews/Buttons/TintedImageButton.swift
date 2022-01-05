//
//  TintedImageButton.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

/*
    A special image button to which a tint can be applied, to conform to the current system color scheme.
 */
@IBDesignable
class TintedImageButton: NSButton, Tintable {
    
    private var kvoToken: NSKeyValueObservation?
    
    func observeColorProperty<Object>(_ keyPath: KeyPath<Object, NSColor>, of object: Object) where Object : NSObject {
        
        kvoToken = object.observe(keyPath, options: [.initial, .new]) {[weak self] changedObject, changedValue in
            self?.contentTintColor = changedValue.newValue
        }
    }
    
    override var image: NSImage? {
        
        didSet {
            image?.isTemplate = true
        }
    }
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        image?.isTemplate = true
    }
 
    // A function that produces a color used to tint the base image.
    var tintFunction: () -> NSColor = {Colors.functionButtonColor} {
        
        // Re-tint the image whenever the function is updated.
        didSet {
            reTint()
        }
    }
    
    // Reapplies the tint (eg. when the tint color has changed or the base image has changed).
    func reTint() {
        
        if !(image?.isTemplate ?? true) {
            print("\n\(self): NOT TEMPLATE !!!")
        }
        
        contentTintColor = tintFunction()
    }
    
    deinit {
        
        kvoToken?.invalidate()
        kvoToken = nil
    }
}

// A contract for any object to which a tint can be applied (and re-applied). This is used by various UI elements to conform to the system color scheme.
protocol Tintable {
    
    func observeColorProperty<Object, Value>(_ keyPath: KeyPath<Object, Value>, of object: Object) where Object: NSObject
    
    func reTint()
}

extension Tintable {
    
    func observeColorProperty<Object, Value>(_ keyPath: KeyPath<Object, Value>, of object: Object) where Object: NSObject {}
}

typealias TintFunction = () -> NSColor
