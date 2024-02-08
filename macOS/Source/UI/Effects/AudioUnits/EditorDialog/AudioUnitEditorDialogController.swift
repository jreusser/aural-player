//
//  AudioUnitEditorDialogController.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

class AudioUnitEditorDialogController: NSWindowController {
    
    override var windowNibName: String? {"AudioUnitEditorDialog"}
    
    // ------------------------------------------------------------------------
    
    // MARK: UI fields
    
    @IBOutlet weak var rootContainer: NSBox!
    @IBOutlet weak var btnClose: TintedImageButton!
    
    @IBOutlet weak var lblTitle: NSTextField!
    @IBOutlet weak var viewContainer: NSBox!
    
    @IBOutlet weak var lblFactoryPresets: NSTextField!
    @IBOutlet weak var btnFactoryPresets: NSPopUpButton!
    
    @IBOutlet weak var lblUserPresets: NSTextField!
    @IBOutlet weak var btnUserPresets: NSPopUpButton!
    @IBOutlet weak var btnSavePreset: TintedImageButton!
    
    lazy var userPresetsPopover: StringInputPopoverViewController = .create(self)
    
    // ------------------------------------------------------------------------
    
    // MARK: Services, utilities, helpers, and properties
    
    var audioUnit: HostedAudioUnitDelegateProtocol!
    
    var factoryPresetsMenuDelegate: AudioUnitFactoryPresetsMenuDelegate!
    var userPresetsMenuDelegate: AudioUnitUserPresetsMenuDelegate!
    
    // ------------------------------------------------------------------------
    
    // MARK: UI initialization / life-cycle
    
    convenience init(for audioUnit: HostedAudioUnitDelegateProtocol) {
        
        self.init()
        self.audioUnit = audioUnit
        
        self.factoryPresetsMenuDelegate = AudioUnitFactoryPresetsMenuDelegate(for: audioUnit)
        self.userPresetsMenuDelegate = AudioUnitUserPresetsMenuDelegate(for: audioUnit)
    }
    
    override func windowDidLoad() {
        
        window?.isMovableByWindowBackground = true
        rootContainer.anchorToSuperview()
        
        audioUnit.presentView {[weak self] auView in
            
            guard let strongSelf = self else {return}
            
            strongSelf.viewContainer.addSubview(auView)
            auView.anchorToSuperview()
            
            // Resize the window to exactly contain the audio unit's view.
            
            let curWindowSize: NSSize = strongSelf.theWindow.size
            let viewContainerSize: NSSize = strongSelf.viewContainer.size
            
            let widthDelta = viewContainerSize.width - auView.width
            let heightDelta = viewContainerSize.height - auView.height
            
            strongSelf.theWindow.resize(curWindowSize.width - widthDelta, curWindowSize.height - heightDelta)
        }
        
        lblTitle.stringValue = "\(audioUnit.name) v\(audioUnit.version)"
        
        initFactoryPresets()
        initUserPresets()
        
//        //fontSchemesManager.registerObserver(lblTitle, forProperty: \.captionFont)
        
//        colorSchemesManager.registerObserver(rootContainer, forProperty: \.backgroundColor)
//        colorSchemesManager.registerObserver(btnClose, forProperty: \.buttonColor)
//        colorSchemesManager.registerObserver(lblTitle, forProperty: \.captionTextColor)
    }
    
    private func initFactoryPresets() {
        
        let shouldShowFactoryPresets: Bool = self.audioUnit?.factoryPresets.isNonEmpty ?? false
        [lblFactoryPresets, btnFactoryPresets].forEach {$0?.showIf(shouldShowFactoryPresets)}
        btnFactoryPresets.menu?.delegate = self.factoryPresetsMenuDelegate
    }
    
    private func initUserPresets() {
        
        let shouldShowUserPresets: Bool = self.audioUnit?.supportsUserPresets ?? false
        [lblUserPresets, btnUserPresets, btnSavePreset].forEach {$0?.showIf(shouldShowUserPresets)}
        btnUserPresets.menu?.delegate = self.userPresetsMenuDelegate
    }
    
    // ------------------------------------------------------------------------
    
    // MARK: Actions
    
    override func showWindow(_ sender: Any?) {
        theWindow.showCenteredOnScreen()
    }
    
    @IBAction func applyFactoryPresetAction(_ sender: Any) {
        
        if let presetName = btnFactoryPresets.titleOfSelectedItem {
            audioUnit.applyFactoryPreset(named: presetName)
        }
    }
    
    @IBAction func applyUserPresetAction(_ sender: Any) {
        
        if let presetName = btnUserPresets.titleOfSelectedItem {
            audioUnit.applyPreset(named: presetName)
        }
    }
    
    // Displays a popover to allow the user to name the new custom preset.
    @IBAction func saveUserPresetAction(_ sender: AnyObject) {
        userPresetsPopover.show(btnSavePreset, NSRectEdge.minY)
    }
    
    @IBAction func closeAction(_ sender: Any) {
        theWindow.close()
    }
}

// ------------------------------------------------------------------------

// MARK: StringInputReceiver

extension AudioUnitEditorDialogController: StringInputReceiver {
    
    var inputPrompt: String {
        return "Enter a new preset name:"
    }
    
    var defaultValue: String? {
        return "<New preset>"
    }
    
    func validate(_ string: String) -> (valid: Bool, errorMsg: String?) {
        
        let presets = audioUnit.presets
        
        if presets.objectExists(named: string) {
            return (false, "Preset with this name already exists !")
        } else {
            return (true, nil)
        }
    }
    
    // Receives a new EQ preset name and saves the new preset
    func acceptInput(_ string: String) {
        audioUnit.savePreset(named: string)
    }
}

class AudioUnitUserPresetsMenuDelegate: NSObject, NSMenuDelegate {
    
    var audioUnit: HostedAudioUnitDelegateProtocol!
    
    convenience init(for audioUnit: HostedAudioUnitDelegateProtocol) {

        self.init()
        self.audioUnit = audioUnit
    }
    
    func menuNeedsUpdate(_ menu: NSMenu) {
        
        while menu.items.count > 1 {
            menu.removeItem(at: 1)
        }
        
        if let userPresets = audioUnit?.presets {
            
            for preset in userPresets.userDefinedObjects.sorted(by: {$0.name < $1.name}) {
                menu.addItem(withTitle: preset.name)
            }
        }
    }
}

class AudioUnitFactoryPresetsMenuDelegate: NSObject, NSMenuDelegate {
    
    var audioUnit: HostedAudioUnitDelegateProtocol!
    
    convenience init(for audioUnit: HostedAudioUnitDelegateProtocol) {

        self.init()
        self.audioUnit = audioUnit
    }
    
    func menuNeedsUpdate(_ menu: NSMenu) {

        while menu.items.count > 1 {
            menu.removeItem(at: 1)
        }
        
        if let factoryPresets = audioUnit?.factoryPresets {
            
            for preset in factoryPresets.sorted(by: {$0.name < $1.name}) {
                menu.addItem(withTitle: preset.name)
            }
        }
    }
}
