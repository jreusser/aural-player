import AVFoundation

class DelayUnit: FXUnit, DelayUnitProtocol {
    
    private let node: AVAudioUnitDelay = AVAudioUnitDelay()
    let presets: DelayPresets
    
    init(persistentState: DelayUnitPersistentState?) {
        
        presets = DelayPresets(persistentState: persistentState)
        super.init(.delay, persistentState?.state ?? AudioGraphDefaults.delayState)
        
        time = persistentState?.time ?? AudioGraphDefaults.delayTime
        amount = persistentState?.amount ?? AudioGraphDefaults.delayAmount
        feedback = persistentState?.feedback ?? AudioGraphDefaults.delayFeedback
        lowPassCutoff = persistentState?.lowPassCutoff ?? AudioGraphDefaults.delayLowPassCutoff
    }
    
    override var avNodes: [AVAudioNode] {[node]}
    
    override func reset() {
        node.reset()
    }
    
    var amount: Float {
        
        get {node.wetDryMix}
        set {node.wetDryMix = newValue}
    }
    
    var time: Double {
        
        get {node.delayTime}
        set {node.delayTime = newValue}
    }
    
    var feedback: Float {
        
        get {node.feedback}
        set {node.feedback = newValue}
    }
    
    var lowPassCutoff: Float {
        
        get {node.lowPassCutoff}
        set {node.lowPassCutoff = newValue}
    }
    
    override func stateChanged() {
        
        super.stateChanged()
        node.bypass = !isActive
    }
    
    override func savePreset(_ presetName: String) {
        presets.addPreset(DelayPreset(presetName, .active, amount, time, feedback, lowPassCutoff, false))
    }
    
    override func applyPreset(_ presetName: String) {
        
        if let preset = presets.preset(named: presetName) {
            applyPreset(preset)
        }
    }
    
    func applyPreset(_ preset: DelayPreset) {
        
        time = preset.time
        amount = preset.amount
        feedback = preset.feedback
        lowPassCutoff = preset.lowPassCutoff
    }
    
    var settingsAsPreset: DelayPreset {
        DelayPreset("delaySettings", state, amount, time, feedback, lowPassCutoff, false)
    }
    
    var persistentState: DelayUnitPersistentState {

        let unitState = DelayUnitPersistentState()

        unitState.state = state
        unitState.time = time
        unitState.amount = amount
        unitState.feedback = feedback
        unitState.lowPassCutoff = lowPassCutoff
        unitState.userPresets = presets.userDefinedPresets.map {DelayPresetPersistentState(preset: $0)}

        return unitState
    }
}
