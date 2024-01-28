//
//  MasterUnitViewController.swift
//  Aural
//
//  Copyright © 2023 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

class MasterUnitViewController: EffectsUnitViewController, FontSchemePropertyObserver {
    
    override var nibName: String? {"MasterUnit"}
    
    // ------------------------------------------------------------------------
    
    // MARK: UI fields
    
    @IBOutlet weak var masterUnitView: MasterUnitView!
    @IBOutlet weak var audioUnitsTable: NSTableView!
    
    @IBOutlet weak var btnRememberSettings: TintedImageButton!
    
    private lazy var btnRememberSettingsStateMachine: ButtonStateMachine<Bool> = ButtonStateMachine(initialState: false, mappings: [
        ButtonStateMachine.StateMapping(state: false, image: .imgRememberSettings, colorProperty: \.inactiveControlColor, toolTip: "Remember all sound settings for this track"),
        ButtonStateMachine.StateMapping(state: true, image: .imgRememberSettings, colorProperty: \.activeControlColor, toolTip: "Don't remember sound settings for this track"),
      ],
      button: btnRememberSettings)
    
    // ------------------------------------------------------------------------
    
    // MARK: Services, utilities, helpers, and properties
    
    private var masterUnit: MasterUnitDelegateProtocol {graph.masterUnit}
    private var eqUnit: EQUnitDelegateProtocol {graph.eqUnit}
    private var pitchShiftUnit: PitchShiftUnitDelegateProtocol {graph.pitchShiftUnit}
    private var timeStretchUnit: TimeStretchUnitDelegateProtocol {graph.timeStretchUnit}
    private var reverbUnit: ReverbUnitDelegateProtocol {graph.reverbUnit}
    private var delayUnit: DelayUnitDelegateProtocol {graph.delayUnit}
    private var filterUnit: FilterUnitDelegateProtocol {graph.filterUnit}
    
    private let soundProfiles: SoundProfiles = audioGraphDelegate.soundProfiles
    
    private let soundPreferences: SoundPreferences = preferences.soundPreferences
    private let playbackPreferences: PlaybackPreferences = preferences.playbackPreferences
    
    // ------------------------------------------------------------------------
    
    // MARK: UI initialization / life-cycle
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        
        effectsUnit = masterUnit
        presetsWrapper = PresetsWrapper<MasterPreset, MasterPresets>(masterUnit.presets)
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        btnRememberSettingsStateMachine.setState(false)
        
        colorSchemesManager.registerPropertyObserver(self, forProperty: \.backgroundColor, handler: backgroundColorChanged(_:))
    }
    
    override func initControls() {
        
        super.initControls()
        broadcastStateChangeNotification()
    }
    
    // ------------------------------------------------------------------------
    
    // MARK: Actions
    
    @IBAction override func bypassAction(_ sender: AnyObject) {
        
        super.bypassAction(sender)
        broadcastStateChangeNotification()
        
        messenger.publish(.effects_playbackRateChanged, payload: timeStretchUnit.effectiveRate)
        
        audioUnitsTable.reloadData()
    }
    
    @IBAction override func presetsAction(_ sender: AnyObject) {
        
        super.presetsAction(sender)
        messenger.publish(.effects_updateEffectsUnitView, payload: EffectsUnitType.master)
    }
    
    @IBAction func eqBypassAction(_ sender: AnyObject) {
        
        _ = eqUnit.toggleState()
        broadcastStateChangeNotification()
    }
    
    // Activates/deactivates the Pitch effects unit
    @IBAction func pitchBypassAction(_ sender: AnyObject) {
        
        _ = pitchShiftUnit.toggleState()
        broadcastStateChangeNotification()
    }
    
    // Activates/deactivates the Time stretch effects unit
    @IBAction func timeBypassAction(_ sender: AnyObject) {
        
        _ = timeStretchUnit.toggleState()
        
        messenger.publish(.effects_playbackRateChanged, payload: timeStretchUnit.effectiveRate)
        
        broadcastStateChangeNotification()
    }
    
    // Activates/deactivates the Reverb effects unit
    @IBAction func reverbBypassAction(_ sender: AnyObject) {
        
        _ = reverbUnit.toggleState()
        broadcastStateChangeNotification()
    }
    
    // Activates/deactivates the Delay effects unit
    @IBAction func delayBypassAction(_ sender: AnyObject) {
        
        _ = delayUnit.toggleState()
        broadcastStateChangeNotification()
    }
    
    // Activates/deactivates the Filter effects unit
    @IBAction func filterBypassAction(_ sender: AnyObject) {
        
        _ = filterUnit.toggleState()
        broadcastStateChangeNotification()
    }
    
    // Sound profile for current track.
    @IBAction func rememberSettingsAction(_ sender: AnyObject) {
        
        guard let playingTrack = playQueueDelegate.currentTrack else {return}
        
        let soundProfiles = audioGraphDelegate.soundProfiles
        
        if soundProfiles.hasFor(playingTrack) {
            
            messenger.publish(.effects_deleteSoundProfile)
            btnRememberSettingsStateMachine.setState(false)
            
        } else {
            
            messenger.publish(.effects_saveSoundProfile)
            btnRememberSettingsStateMachine.setState(true)
        }
    }
    
    // ------------------------------------------------------------------------
    
    // MARK: Message handling
    
    override func initSubscriptions() {
        
        super.initSubscriptions()
        
        messenger.subscribeAsync(to: .player_trackTransitioned, handler: trackChanged(_:),
                                 filter: {msg in msg.trackChanged})
        
        messenger.subscribe(to: .masterEffectsUnit_toggleEffects, handler: toggleEffects)
        messenger.subscribe(to: .auEffectsUnit_audioUnitsAddedOrRemoved, handler: audioUnitsTable.reloadData)
    }
    
    override func stateChanged() {
        
        messenger.publish(.effects_playbackRateChanged, payload: timeStretchUnit.effectiveRate)
        audioUnitsTable.reloadAllRows(columns: [1])
    }
    
    private func toggleEffects() {
        bypassAction(self)
    }
    
    func trackChanged(_ notification: TrackTransitionNotification) {
        
        // Apply sound profile if there is one for the new track and if the preferences allow it
        if let newTrack = notification.endTrack {
            
            if soundProfiles.hasFor(newTrack) {
                
                messenger.publish(.effects_updateEffectsUnitView, payload: EffectsUnitType.master)
                
                btnRememberSettingsStateMachine.setState(true)
                
            } else {
                btnRememberSettingsStateMachine.setState(false)
            }

            // HACK: To make the tool tip appear (without hiding / showing)
            btnRememberSettings.moveX(to: 13)
            
        } else {
            
            // HACK: To make the tool tip disappear (without hiding / showing)
            btnRememberSettings.moveX(to: -50)
        }
    }
    
    // ------------------------------------------------------------------------
    
    // MARK: Helper functions
    
    private func broadcastStateChangeNotification() {
        
        // Update the bypass buttons for the effects units
        messenger.publish(.effects_unitStateChanged)
    }
    
    // ------------------------------------------------------------------------
    
    // MARK: Theming
    
    func fontChanged(to newFont: PlatformFont, forProperty property: KeyPath<FontScheme, PlatformFont>) {
        
        switch property {
            
        case \.effectsPrimaryFont:
            
            audioUnitsTable.reloadAllRows(columns: [1])
            
        default:
            
            return
        }
    }
    
    override func colorSchemeChanged() {
        
        super.colorSchemeChanged()
        audioUnitsTable.colorSchemeChanged()
    }
    
    private func backgroundColorChanged(_ newColor: PlatformColor) {
        audioUnitsTable.setBackgroundColor(newColor)
    }
    
    override func activeControlColorChanged(_ newColor: PlatformColor) {
        
        super.activeControlColorChanged(newColor)
        
        let rowsForActiveUnits: [Int] = audioUnitsTable.allRowIndices.filter {graph.audioUnits[$0].state == .active}
        audioUnitsTable.reloadRows(rowsForActiveUnits, columns: [1])
        
        updateBypassButtons(forUnitState: .active, newColor: newColor)
    }
    
    override func inactiveControlColorChanged(_ newColor: PlatformColor) {
        
        super.inactiveControlColorChanged(newColor)
        
        let rowsForBypassedUnits: [Int] = audioUnitsTable.allRowIndices.filter {graph.audioUnits[$0].state == .bypassed}
        audioUnitsTable.reloadRows(rowsForBypassedUnits, columns: [1])
        
        updateBypassButtons(forUnitState: .bypassed, newColor: newColor)
    }
    
    override func suppressedControlColorChanged(_ newColor: PlatformColor) {
        
        super.suppressedControlColorChanged(newColor)
        
        let rowsForSuppressedUnits: [Int] = audioUnitsTable.allRowIndices.filter {graph.audioUnits[$0].state == .suppressed}
        audioUnitsTable.reloadRows(rowsForSuppressedUnits, columns: [1])
        
        updateBypassButtons(forUnitState: .suppressed, newColor: newColor)
    }
    
    private func updateBypassButtons(forUnitState unitState: EffectsUnitState, newColor: PlatformColor) {
        
        if eqUnit.state == unitState {
            masterUnitView.updateEQUnitToggle(newColor)
        }
        
        if pitchShiftUnit.state == unitState {
            masterUnitView.updatePitchShiftUnitToggle(newColor)
        }
        
        if timeStretchUnit.state == unitState {
            masterUnitView.updateTimeStretchUnitToggle(newColor)
        }
        
        if reverbUnit.state == unitState {
            masterUnitView.updateReverbUnitToggle(newColor)
        }
        
        if delayUnit.state == unitState {
            masterUnitView.updateDelayUnitToggle(newColor)
        }
        
        if filterUnit.state == unitState {
            masterUnitView.updateFilterUnitToggle(newColor)
        }
    }
}
