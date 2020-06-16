import Cocoa

class MasterViewController: FXUnitViewController {
    
    @IBOutlet weak var masterView: MasterView!
    
    private let player: PlaybackInfoDelegateProtocol = ObjectGraph.playbackInfoDelegate
    private let soundPreferences: SoundPreferences = ObjectGraph.preferencesDelegate.preferences.soundPreferences
    private let playbackPreferences: PlaybackPreferences = ObjectGraph.preferencesDelegate.preferences.playbackPreferences
    
    private var masterUnit: MasterUnitDelegateProtocol {return graph.masterUnit}
    private var eqUnit: EQUnitDelegateProtocol {return graph.eqUnit}
    private var pitchUnit: PitchUnitDelegateProtocol {return graph.pitchUnit}
    private var timeUnit: TimeUnitDelegateProtocol {return graph.timeUnit}
    private var reverbUnit: ReverbUnitDelegateProtocol {return graph.reverbUnit}
    private var delayUnit: DelayUnitDelegateProtocol {return graph.delayUnit}
    private var filterUnit: FilterUnitDelegateProtocol {return graph.filterUnit}
    
    private let soundProfiles: SoundProfiles = ObjectGraph.audioGraphDelegate.soundProfiles
    
    override var nibName: String? {return "Master"}
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        
        unitType = .master
        fxUnit = masterUnit
        presetsWrapper = PresetsWrapper<MasterPreset, MasterPresets>(masterUnit.presets)
    }
    
    override func oneTimeSetup() {
        
        super.oneTimeSetup()
        
        masterView.initialize(graph.eqUnit.stateFunction, graph.pitchUnit.stateFunction, graph.timeUnit.stateFunction, graph.reverbUnit.stateFunction, graph.delayUnit.stateFunction, graph.filterUnit.stateFunction)
    }
    
    override func initSubscriptions() {
        
        super.initSubscriptions()
        
        Messenger.subscribeAsync(self, .trackTransition, self.trackChanged(_:),
                                 filter: {msg in msg.trackChanged && self.soundPreferences.rememberEffectsSettings},
                                 queue: .main)
        
        Messenger.subscribe(self, .masterFXUnit_toggleEffects, self.toggleEffects)
    }
    
    override func initControls() {
        
        super.initControls()
        updateButtons()
        broadcastStateChangeNotification()
    }
    
    @IBAction override func bypassAction(_ sender: AnyObject) {
        
        super.bypassAction(sender)
        updateButtons()
        broadcastStateChangeNotification()
    }
    
    private func toggleEffects() {
        bypassAction(self)
    }
    
    @IBAction override func presetsAction(_ sender: AnyObject) {
        
        super.presetsAction(sender)
        _ = SyncMessenger.publishActionMessage(EffectsViewActionMessage(.updateEffectsView, .master))
    }
    
    private func updateButtons() {
        btnBypass.updateState()
        masterView.stateChanged()
    }
    
    private func broadcastStateChangeNotification() {
        // Update the bypass buttons for the effects units
        Messenger.publish(.fxUnitStateChanged)
    }
    
    @IBAction func eqBypassAction(_ sender: AnyObject) {
        
        _ = eqUnit.toggleState()
        updateButtons()
        broadcastStateChangeNotification()
    }
    
    // Activates/deactivates the Pitch effects unit
    @IBAction func pitchBypassAction(_ sender: AnyObject) {
        
        _ = pitchUnit.toggleState()
        updateButtons()
        broadcastStateChangeNotification()
    }
    
    // Activates/deactivates the Time stretch effects unit
    @IBAction func timeBypassAction(_ sender: AnyObject) {
        
        _ = timeUnit.toggleState()
        
        Messenger.publish(PlaybackRateChangedNotification(newPlaybackRate: timeUnit.effectiveRate))
        
        updateButtons()
        broadcastStateChangeNotification()
    }
    
    // Activates/deactivates the Reverb effects unit
    @IBAction func reverbBypassAction(_ sender: AnyObject) {
        
        _ = reverbUnit.toggleState()
        updateButtons()
        broadcastStateChangeNotification()
    }
    
    // Activates/deactivates the Delay effects unit
    @IBAction func delayBypassAction(_ sender: AnyObject) {
        
        _ = delayUnit.toggleState()
        updateButtons()
        broadcastStateChangeNotification()
    }
    
    // Activates/deactivates the Filter effects unit
    @IBAction func filterBypassAction(_ sender: AnyObject) {
        
        _ = filterUnit.toggleState()
        updateButtons()
        broadcastStateChangeNotification()
    }
    
    func trackChanged(_ notification: TrackTransitionNotification) {
        
        // Apply sound profile if there is one for the new track and if the preferences allow it
        if let newTrack = notification.endTrack, soundProfiles.hasFor(newTrack) {
            
            updateButtons()
            _ = SyncMessenger.publishActionMessage(EffectsViewActionMessage(.updateEffectsView, .master))
        }
    }
    
    override func changeTextSize(_ textSize: TextSize) {
        
        lblCaption.font = Fonts.Effects.unitCaptionFont
        
        functionLabels.forEach({
            $0.font = $0 is EffectsUnitTriStateLabel ? Fonts.Effects.masterUnitFunctionFont : Fonts.Effects.unitFunctionFont
        })
        
        presetsMenu.font = Fonts.Effects.menuFont
    }
    
    override func changeFunctionCaptionTextColor(_ color: NSColor) {
    }
    
    override func changeActiveUnitStateColor(_ color: NSColor) {
        
        super.changeActiveUnitStateColor(color)
        masterView.changeActiveUnitStateColor(color)
    }
    
    override func changeBypassedUnitStateColor(_ color: NSColor) {
        
        super.changeBypassedUnitStateColor(color)
        masterView.changeBypassedUnitStateColor(color)
    }
    
    override func changeSuppressedUnitStateColor(_ color: NSColor) {
        
        // Master unit can never be suppressed, but update other unit state buttons
        masterView.changeSuppressedUnitStateColor(color)
    }
    
    // MARK: Message handling
    
    override func stateChanged() {
        updateButtons()
    }
}
