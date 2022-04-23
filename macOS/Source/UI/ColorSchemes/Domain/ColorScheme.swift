//
//  ColorScheme.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

/*
    Encapsulates all colors that determine a color scheme that can be appplied to the entire application.
 */
class ColorScheme: NSObject, UserManagedObject {
    
    // Default color scheme (uses colors from the default system-defined preset)
    static let defaultScheme: ColorScheme = ColorScheme("_default_", true, .blackAttack)
    
    // Displayed name
    var name: String
    
    var key: String {
        
        get {name}
        set {name = newValue}
    }
    
    var userDefined: Bool {!systemDefined}

    // False if defined by the user
    let systemDefined: Bool
    
    @objc dynamic var backgroundColor: NSColor
    @objc dynamic var iconColor: NSColor
    
    // MARK: Text colors ----------------------------------------------------------------------------------------
    
    @objc dynamic var captionTextColor: NSColor
    
    @objc dynamic var primaryTextColor: NSColor
    @objc dynamic var secondaryTextColor: NSColor
    @objc dynamic var tertiaryTextColor: NSColor
    
    @objc dynamic var primarySelectedTextColor: NSColor
    @objc dynamic var secondarySelectedTextColor: NSColor
    @objc dynamic var tertiarySelectedTextColor: NSColor
    
    // MARK: Button colors ----------------------------------------------------------------------------------------
    
    @objc dynamic var buttonColor: NSColor
    @objc dynamic var buttonOffColor: NSColor
    
    // MARK: Activity state colors ----------------------------------------------------------------------------------------
    
    @objc dynamic var activeControlColor: NSColor
    @objc dynamic var activeControlGradientColor: NSColor!
    @objc dynamic var activeControlGradient: NSGradient!
    
    private func computeActiveControlGradientColor() -> NSColor {
        activeControlColor.darkened(50)
    }
    
    private func computeActiveControlGradient() -> NSGradient {
        NSGradient(starting: activeControlColor, ending: activeControlGradientColor)!
    }
    
    @objc dynamic var bypassedControlColor: NSColor
    @objc dynamic var bypassedControlGradientColor: NSColor!
    @objc dynamic var bypassedControlGradient: NSGradient!
    
    private func computeBypassedControlGradientColor() -> NSColor {
        bypassedControlColor.darkened(50)
    }
    
    private func computeBypassedControlGradient() -> NSGradient {
        NSGradient(starting: bypassedControlColor, ending: bypassedControlGradientColor)!
    }
    
    @objc dynamic var suppressedControlColor: NSColor
    @objc dynamic var suppressedControlGradientColor: NSColor!
    @objc dynamic var suppressedControlGradient: NSGradient!
    
    private func computeSuppressedControlGradientColor() -> NSColor {
        suppressedControlColor.darkened(50)
    }
    
    private func computeSuppressedControlGradient() -> NSGradient {
        NSGradient(starting: suppressedControlColor, ending: suppressedControlGradientColor)!
    }
    
    // MARK: Miscellaneous colors ----------------------------------------------------------------------------------------
    
    @objc dynamic var textSelectionColor: NSColor
    
    // TODO: Do we need these ???
    @objc dynamic var sliderBackgroundColor: NSColor
    @objc dynamic var sliderTickColor: NSColor
    
    // MARK: Functions ----------------------------------------------------------------------------------------
    
    init(name: String, systemDefined: Bool,
         backgroundColor: NSColor, captionTextColor: NSColor,
         primaryTextColor: NSColor, secondaryTextColor: NSColor, tertiaryTextColor: NSColor,
         primarySelectedTextColor: NSColor, secondarySelectedTextColor: NSColor, tertiarySelectedTextColor: NSColor,
         buttonColor: NSColor, buttonOffColor: NSColor,
         activeControlColor: NSColor, bypassedControlColor: NSColor, suppressedControlColor: NSColor,
         sliderBackgroundColor: NSColor, sliderTickColor: NSColor,
         textSelectionColor: NSColor, iconColor: NSColor) {
        
        self.name = name
        self.systemDefined = systemDefined
        
        self.backgroundColor = backgroundColor
        self.captionTextColor = captionTextColor
        
        self.primaryTextColor = primaryTextColor
        self.secondaryTextColor = secondaryTextColor
        self.tertiaryTextColor = tertiaryTextColor
        
        self.primarySelectedTextColor = primarySelectedTextColor
        self.secondarySelectedTextColor = secondarySelectedTextColor
        self.tertiarySelectedTextColor = tertiarySelectedTextColor
        
        self.buttonColor = buttonColor
        self.buttonOffColor = buttonOffColor
        
        self.activeControlColor = activeControlColor
        self.bypassedControlColor = bypassedControlColor
        self.suppressedControlColor = suppressedControlColor
        
        self.sliderBackgroundColor = sliderBackgroundColor
        self.sliderTickColor = sliderTickColor
        
        self.textSelectionColor = textSelectionColor
        self.iconColor = iconColor
        
        super.init()
        
        computeGradients()
        setUpKVO()
    }
    
    // Copy constructor ... creates a copy of the given scheme (used when creating a user-defined preset)
    init(_ name: String, _ systemDefined: Bool, _ scheme: ColorScheme) {
    
        self.name = name
        self.systemDefined = systemDefined
        
        backgroundColor = scheme.backgroundColor
        captionTextColor = scheme.captionTextColor
        
        primaryTextColor = scheme.primaryTextColor
        secondaryTextColor = scheme.secondaryTextColor
        tertiaryTextColor = scheme.tertiaryTextColor
        
        primarySelectedTextColor = scheme.primarySelectedTextColor
        secondarySelectedTextColor = scheme.secondarySelectedTextColor
        tertiarySelectedTextColor = scheme.tertiarySelectedTextColor
        
        buttonColor = scheme.buttonColor
        buttonOffColor = scheme.buttonOffColor
        
        activeControlColor = scheme.activeControlColor
        bypassedControlColor = scheme.bypassedControlColor
        suppressedControlColor = scheme.suppressedControlColor
        
        sliderBackgroundColor = scheme.sliderBackgroundColor
        sliderTickColor = scheme.sliderTickColor
        
        textSelectionColor = scheme.textSelectionColor
        iconColor = scheme.iconColor
        
        super.init()
        
        computeGradients()
        setUpKVO()
    }
    
    // Used when loading app state on startup
    init(_ persistentState: ColorSchemePersistentState?, _ systemDefined: Bool) {
        
        self.name = persistentState?.name ?? ""
        self.systemDefined = systemDefined
        
        backgroundColor = persistentState?.backgroundColor?.toColor() ?? Self.defaultScheme.backgroundColor
        captionTextColor = persistentState?.captionTextColor?.toColor() ?? Self.defaultScheme.captionTextColor
        
        primaryTextColor = persistentState?.primaryTextColor?.toColor() ?? Self.defaultScheme.primaryTextColor
        secondaryTextColor = persistentState?.secondaryTextColor?.toColor() ?? Self.defaultScheme.secondaryTextColor
        tertiaryTextColor = persistentState?.tertiaryTextColor?.toColor() ?? Self.defaultScheme.tertiaryTextColor
        
        primarySelectedTextColor = persistentState?.primarySelectedTextColor?.toColor() ?? Self.defaultScheme.primarySelectedTextColor
        secondarySelectedTextColor = persistentState?.secondarySelectedTextColor?.toColor() ?? Self.defaultScheme.secondarySelectedTextColor
        tertiarySelectedTextColor = persistentState?.tertiarySelectedTextColor?.toColor() ?? Self.defaultScheme.tertiarySelectedTextColor
        
        buttonColor = persistentState?.buttonColor?.toColor() ?? Self.defaultScheme.buttonColor
        buttonOffColor = persistentState?.buttonOffColor?.toColor() ?? Self.defaultScheme.buttonOffColor
        
        activeControlColor = persistentState?.activeControlColor?.toColor() ?? Self.defaultScheme.activeControlColor
        bypassedControlColor = persistentState?.bypassedControlColor?.toColor() ?? Self.defaultScheme.bypassedControlColor
        suppressedControlColor = persistentState?.suppressedControlColor?.toColor() ?? Self.defaultScheme.suppressedControlColor
        
        sliderBackgroundColor = persistentState?.sliderBackgroundColor?.toColor() ?? Self.defaultScheme.sliderBackgroundColor
        sliderTickColor = persistentState?.sliderTickColor?.toColor() ?? Self.defaultScheme.sliderTickColor
        
        textSelectionColor = persistentState?.textSelectionColor?.toColor() ?? Self.defaultScheme.textSelectionColor
        iconColor = persistentState?.iconColor?.toColor() ?? Self.defaultScheme.iconColor
        
        super.init()
        
        computeGradients()
        setUpKVO()
    }
    
    private func computeGradients() {
        
        self.activeControlGradientColor = computeActiveControlGradientColor()
        self.activeControlGradient = computeActiveControlGradient()
        
        self.bypassedControlGradientColor = computeBypassedControlGradientColor()
        self.bypassedControlGradient = computeBypassedControlGradient()
        
        self.suppressedControlGradientColor = computeSuppressedControlGradientColor()
        self.suppressedControlGradient = computeSuppressedControlGradient()
    }
    
    deinit {
        kvoTokens.invalidate()
    }
    
    private var kvoTokens: KVOTokens<ColorScheme, PlatformColor> = KVOTokens()
    
    private func setUpKVO() {
        
        kvoTokens.addObserver(forObject: self, keyPath: \.activeControlColor) {strongSelf, _ in
            
            strongSelf.activeControlGradientColor = strongSelf.computeActiveControlGradientColor()
            strongSelf.activeControlGradient = strongSelf.computeActiveControlGradient()
        }
        
        kvoTokens.addObserver(forObject: self, keyPath: \.bypassedControlColor) {strongSelf, _ in
            
            strongSelf.bypassedControlGradientColor = strongSelf.computeBypassedControlGradientColor()
            strongSelf.bypassedControlGradient = strongSelf.computeBypassedControlGradient()
        }
        
        kvoTokens.addObserver(forObject: self, keyPath: \.suppressedControlColor) {strongSelf, _ in
            
            strongSelf.suppressedControlGradientColor = strongSelf.computeSuppressedControlGradientColor()
            strongSelf.suppressedControlGradient = strongSelf.computeSuppressedControlGradient()
        }
    }
    
    // Applies another color scheme to this scheme.
    func applyScheme(_ scheme: ColorScheme) {
        
        backgroundColor = scheme.backgroundColor
        captionTextColor = scheme.captionTextColor
        
        primaryTextColor = scheme.primaryTextColor
        secondaryTextColor = scheme.secondaryTextColor
        tertiaryTextColor = scheme.tertiaryTextColor
        
        primarySelectedTextColor = scheme.primarySelectedTextColor
        secondarySelectedTextColor = scheme.secondarySelectedTextColor
        tertiarySelectedTextColor = scheme.tertiarySelectedTextColor
        
        buttonColor = scheme.buttonColor
        buttonOffColor = scheme.buttonOffColor
        
        activeControlColor = scheme.activeControlColor
        bypassedControlColor = scheme.bypassedControlColor
        suppressedControlColor = scheme.suppressedControlColor
        
        sliderBackgroundColor = scheme.sliderBackgroundColor
        sliderTickColor = scheme.sliderTickColor
        
        textSelectionColor = scheme.textSelectionColor
        iconColor = scheme.iconColor
    }
    
    // Creates an identical copy of this color scheme
    func clone() -> ColorScheme {
        ColorScheme(self.name + "_clone", self.systemDefined, self)
    }
    
    // State that can be persisted to disk
    var persistentState: ColorSchemePersistentState {
        ColorSchemePersistentState(self)
    }
}

/*
    Enumerates all different types of gradients that can be applied to colors in a color scheme.
 */
enum ColorSchemeGradientType: String, CaseIterable, Codable {
    
    case none
    case darken
    case brighten
}

// A contract for any UI component that marks it as being able to apply a color scheme to itself.
protocol ColorSchemeable {
    
    // Apply the given color scheme to this component.
    func applyColorScheme(_ scheme: ColorScheme)
    
    func observeColorSchemeProperty(_ keyPath: KeyPath<ColorScheme, NSColor>)
}

extension ColorSchemeable {
    
    func observeColorSchemeProperty(_ keyPath: KeyPath<ColorScheme, NSColor>) {}
    
    func applyColorScheme(_ scheme: ColorScheme) {}
}
