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
    static let defaultScheme: ColorScheme = ColorScheme("_default_", ColorSchemePreset.defaultScheme)
    
    // Displayed name
    var name: String
    
    var key: String {
        
        get {name}
        set {name = newValue}
    }
    
    var userDefined: Bool {!systemDefined}

    // False if defined by the user
    let systemDefined: Bool
    
    /*
     
     background
     caption
     
     primaryText
     secondaryText
     tertiaryText
     
     button
     buttonOffState
     
     activeControl
     bypassedControl
     suppressedControl
     
     sliderBackground
     sliderKnob
     sliderTick
     
     tableSelectionText
     tableSelectionBox
     
     */

    private var defaultPreset: ColorSchemePreset {
        .defaultScheme
    }
    
    @objc dynamic lazy var backgroundColor: NSColor = defaultPreset.backgroundColor
    
    @objc dynamic lazy var captionTextColor: NSColor = defaultPreset.mainCaptionTextColor
    
    @objc dynamic lazy var primaryTextColor: NSColor = defaultPreset.playerTrackInfoPrimaryTextColor
    @objc dynamic lazy var secondaryTextColor: NSColor = defaultPreset.playerTrackInfoSecondaryTextColor
    @objc dynamic lazy var tertiaryTextColor: NSColor = defaultPreset.playerTrackInfoTertiaryTextColor
    
    @objc dynamic lazy var primarySelectedTextColor: NSColor = .white
    @objc dynamic lazy var secondarySelectedTextColor: NSColor = .gray
    
    @objc dynamic lazy var buttonColor: NSColor = defaultPreset.functionButtonColor
    @objc dynamic lazy var buttonOffColor: NSColor = defaultPreset.toggleButtonOffStateColor
    
    @objc dynamic lazy var activeControlColor: NSColor = defaultPreset.effectsActiveUnitStateColor
    @objc dynamic lazy var activeControlGradientColor: NSColor = computeActiveControlGradientColor()
    @objc dynamic lazy var activeControlGradient: NSGradient = computeActiveControlGradient()
    
    private func computeActiveControlGradientColor() -> NSColor {
        activeControlColor.darkened(50)
    }
    
    private func computeActiveControlGradient() -> NSGradient {
        NSGradient(starting: activeControlColor, ending: activeControlGradientColor)!
    }
    
    @objc dynamic lazy var bypassedControlColor: NSColor = defaultPreset.effectsBypassedUnitStateColor
    @objc dynamic lazy var bypassedControlGradientColor: NSColor = computeBypassedControlGradientColor()
    @objc dynamic lazy var bypassedControlGradient: NSGradient = computeBypassedControlGradient()
    
    private func computeBypassedControlGradientColor() -> NSColor {
        bypassedControlColor.darkened(50)
    }
    
    private func computeBypassedControlGradient() -> NSGradient {
        NSGradient(starting: bypassedControlColor, ending: bypassedControlGradientColor)!
    }
    
    @objc dynamic lazy var suppressedControlColor: NSColor = defaultPreset.effectsSuppressedUnitStateColor
    @objc dynamic lazy var suppressedControlGradientColor: NSColor = computeSuppressedControlGradientColor()
    @objc dynamic lazy var suppressedControlGradient: NSGradient = computeSuppressedControlGradient()
    
    private func computeSuppressedControlGradientColor() -> NSColor {
        suppressedControlColor.darkened(50)
    }
    
    private func computeSuppressedControlGradient() -> NSGradient {
        NSGradient(starting: suppressedControlColor, ending: suppressedControlGradientColor)!
    }
    
    @objc dynamic lazy var sliderBackgroundColor: NSColor = defaultPreset.playerSliderBackgroundColor
    @objc dynamic lazy var sliderKnobColor: NSColor = defaultPreset.playerSliderKnobColor
    @objc dynamic lazy var sliderTickColor: NSColor = defaultPreset.effectsSliderTickColor
    
    lazy var sliderForegroundGradientType: ColorSchemeGradientType = defaultPreset.effectsSliderForegroundGradientType {
        
        didSet {
            sliderForegroundGradientTypeString = sliderForegroundGradientType.rawValue
        }
    }
    
    @objc dynamic lazy var sliderForegroundGradientTypeString: String = defaultPreset.effectsSliderForegroundGradientType.rawValue
    @objc dynamic lazy var sliderForegroundGradientAmount: Int = defaultPreset.effectsSliderForegroundGradientAmount
    
    @objc dynamic lazy var tableSelectionBoxColor: NSColor = defaultPreset.playlistSelectionBoxColor
    
    // Copy constructor ... creates a copy of the given scheme (used when creating a user-defined preset)
    init(_ name: String, _ systemDefined: Bool, _ scheme: ColorScheme) {
    
        self.name = name
        self.systemDefined = systemDefined
        
        super.init()
        
        setUpKVO()
    }
    
    // Used when loading app state on startup
    init(_ persistentState: ColorSchemePersistentState?, _ systemDefined: Bool) {
        
        self.name = persistentState?.name ?? ""
        self.systemDefined = systemDefined
        
//        self.general = GeneralColorScheme(persistentState?.general)
//        self.player = PlayerColorScheme(persistentState?.player)
//        self.playlist = PlaylistColorScheme(persistentState?.playlist)
//        self.effects = EffectsColorScheme(persistentState?.effects)
        
        super.init()
        
        setUpKVO()
    }
    
    // Creates a scheme from a preset (eg. default scheme)
    init(_ name: String, _ preset: ColorSchemePreset) {
        
        self.name = name
        self.systemDefined = true
        
        super.init()
        
        backgroundColor = preset.backgroundColor
        
        buttonColor = preset.functionButtonColor
        buttonOffColor = preset.toggleButtonOffStateColor
        
        captionTextColor = preset.mainCaptionTextColor
        
        primaryTextColor = preset.playerTrackInfoPrimaryTextColor
        secondaryTextColor = preset.playerTrackInfoSecondaryTextColor
        tertiaryTextColor = preset.playerTrackInfoTertiaryTextColor
        
        activeControlColor = preset.effectsActiveUnitStateColor
        bypassedControlColor = preset.effectsBypassedUnitStateColor
        suppressedControlColor = preset.effectsSuppressedUnitStateColor
        
//        primarySelectedTextColor = preset.
        
//        self.general = GeneralColorScheme(preset)
//        self.player = PlayerColorScheme(preset)
//        self.playlist = PlaylistColorScheme(preset)
//        self.effects = EffectsColorScheme(preset)
        
        setUpKVO()
    }
    
    deinit {
        
        kvoTokens.forEach {
            $0.invalidate()
        }
        
        kvoTokens.removeAll()
    }
    
    private var kvoTokens: [NSKeyValueObservation] = []
    
    private func setUpKVO() {
        
        kvoTokens.append(self.observe(\.activeControlColor, options: [.initial, .new]) {strongSelf, _ in
            
            strongSelf.activeControlGradientColor = strongSelf.computeActiveControlGradientColor()
            strongSelf.activeControlGradient = strongSelf.computeActiveControlGradient()
        })
        
        kvoTokens.append(self.observe(\.bypassedControlColor, options: [.initial, .new]) {strongSelf, _ in
            
            strongSelf.bypassedControlGradientColor = strongSelf.computeBypassedControlGradientColor()
            strongSelf.bypassedControlGradient = strongSelf.computeBypassedControlGradient()
        })
        
        kvoTokens.append(self.observe(\.suppressedControlColor, options: [.initial, .new]) {strongSelf, _ in
            
            strongSelf.suppressedControlGradientColor = strongSelf.computeSuppressedControlGradientColor()
            strongSelf.suppressedControlGradient = strongSelf.computeSuppressedControlGradient()
        })
    }
    
    // Applies a system-defined preset to this scheme.
//    func applyPreset(_ preset: ColorSchemePreset) {
//        
//        backgroundColor = preset.backgroundColor
//        buttonColor = preset.functionButtonColor
//        buttonOffColor = preset.toggleButtonOffStateColor
//        
////        self.general.applyPreset(preset)
////        self.player.applyPreset(preset)
////        self.playlist.applyPreset(preset)
////        self.effects.applyPreset(preset)
//    }
    
    // Applies another color scheme to this scheme.
    func applyScheme(_ scheme: ColorScheme) {
        
        backgroundColor = scheme.backgroundColor
        buttonColor = scheme.buttonColor
        buttonOffColor = scheme.buttonOffColor
        
        primaryTextColor = scheme.primaryTextColor
        secondaryTextColor = scheme.secondaryTextColor
        tertiaryTextColor = scheme.tertiaryTextColor
        
        activeControlColor = scheme.activeControlColor
        bypassedControlColor = scheme.bypassedControlColor
        suppressedControlColor = scheme.suppressedControlColor
        sliderBackgroundColor = scheme.sliderBackgroundColor
        
//        self.general.applyScheme(scheme.general)
//        self.player.applyScheme(scheme.player)
//        self.playlist.applyScheme(scheme.playlist)
//        self.effects.applyScheme(scheme.effects)
    }
    
    // Creates an identical copy of this color scheme
    func clone() -> ColorScheme {
        return ColorScheme(self.name + "_clone", self.systemDefined, self)
    }
    
    // State that can be persisted to disk
    var persistentState: ColorSchemePersistentState {
        return ColorSchemePersistentState(self)
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
