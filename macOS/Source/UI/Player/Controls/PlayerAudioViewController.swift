//
//  PlayerAudioViewController.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

/*
    View controller for player volume and pan
 */
class PlayerAudioViewController: NSViewController {
    
    var showsPanControl: Bool {true}
    
    // Volume/pan controls
    @IBOutlet weak var btnVolume: TintedImageButton!
    @IBOutlet weak var volumeSlider: NSSlider!
    @IBOutlet weak var panSlider: NSSlider!
    
    // These are feedback labels that are shown briefly and automatically hidden
    @IBOutlet weak var lblVolume: VALabel!
    
    // Wrappers around the feedback labels that automatically hide them after showing them for a brief interval
    var autoHidingVolumeLabel: AutoHidingView!
    var autoHidingPanLabel: AutoHidingView!
    
    // Delegate that conveys all volume/pan adjustments to the audio graph
    var audioGraph: AudioGraphDelegateProtocol = audioGraphDelegate
    let soundProfiles: SoundProfiles = audioGraphDelegate.soundProfiles
    let soundPreferences: SoundPreferences = preferences.soundPreferences
    
    lazy var messenger = Messenger(for: self)
    
    // Numerical ranges
    let highVolumeRange: ClosedRange<Float> = 200.0/3...100
    let mediumVolumeRange: Range<Float> = 100.0/3..<200.0/3
    let lowVolumeRange: Range<Float> = 1..<100.0/3
    
    // Time intervals for which feedback labels or views that are to be auto-hidden are displayed, before being hidden.
    static let feedbackLabelAutoHideIntervalSeconds: TimeInterval = 1
    
    override func viewDidLoad() {
        
        autoHidingVolumeLabel = AutoHidingView(lblVolume, Self.feedbackLabelAutoHideIntervalSeconds)
        volumeSlider.floatValue = audioGraph.volume
        volumeChanged(audioGraph.volume, audioGraph.muted, true, false)
        
        fontSchemesManager.registerObserver(lblVolume, forProperty: \.playerTertiaryFont)
        
        colorSchemesManager.registerObserver(btnVolume, forProperty: \.buttonColor)
        colorSchemesManager.registerSchemeObserver(volumeSlider, forProperties: [\.backgroundColor, \.activeControlColor, \.inactiveControlColor])
        colorSchemesManager.registerObserver(lblVolume, forProperty: \.secondaryTextColor)
        
        initSubscriptions()
    }
    
    func initSubscriptions() {}
    
    override func destroy() {
        messenger.unsubscribeFromAll()
    }
    
    // Updates the volume
    @IBAction func volumeAction(_ sender: AnyObject) {
        
        audioGraph.volume = volumeSlider.floatValue
        volumeChanged(audioGraph.volume, audioGraph.muted, false)
    }
    
    // Mutes or unmutes the player
    @IBAction func muteOrUnmuteAction(_ sender: AnyObject) {
        muteOrUnmute()
    }
    
    func muteOrUnmute() {
        
        audioGraph.muted.toggle()
        updateVolumeMuteButtonImage(audioGraph.volume, audioGraph.muted)
    }
    
    // Decreases the volume by a certain preset decrement
    func decreaseVolume(_ inputMode: UserInputMode) {
        
        let newVolume = audioGraph.decreaseVolume(inputMode: inputMode)
        volumeChanged(newVolume, audioGraph.muted)
    }
    
    // Increases the volume by a certain preset increment
    func increaseVolume(_ inputMode: UserInputMode) {
        
        let newVolume = audioGraph.increaseVolume(inputMode: inputMode)
        volumeChanged(newVolume, audioGraph.muted)
    }
    
    // updateSlider should be true if the action was not triggered by the slider in the first place.
    func volumeChanged(_ volume: Float, _ muted: Bool, _ updateSlider: Bool = true, _ showFeedback: Bool = true) {
        
        if updateSlider {
            volumeSlider.floatValue = volume
        }
        
        lblVolume.stringValue = audioGraph.formattedVolume
        
        updateVolumeMuteButtonImage(volume, muted)
        
        // Shows and automatically hides the volume label after a preset time interval
        if showFeedback {
            autoHidingVolumeLabel.showView()
        }
    }
    
    func updateVolumeMuteButtonImage(_ volume: Float, _ muted: Bool) {

        if muted {
            
            btnVolume.image = .imgMute
            
        } else {

            // Zero / Low / Medium / High (different images)
            
            switch volume {
                
            case highVolumeRange:
                
                btnVolume.image = .imgVolumeHigh
                
            case mediumVolumeRange:
                
                btnVolume.image = .imgVolumeMedium
                
            case lowVolumeRange:
                
                btnVolume.image = .imgVolumeLow
                
            default:
                
                btnVolume.image = .imgVolumeZero
            }
        }
    }
    
    func trackChanged(_ newTrack: Track?) {
        
        // Apply sound profile if there is one for the new track and the preferences allow it
        if let theNewTrack = newTrack, soundProfiles.hasFor(theNewTrack) {
            volumeChanged(audioGraph.volume, audioGraph.muted)
        }
    }
    
    // MARK: Message handling
    
    func trackTransitioned(_ notification: TrackTransitionNotification) {
        trackChanged(notification.endTrack)
    }
    
    func applyTheme() {
        applyColorScheme(systemColorScheme)
    }
    
    func applyColorScheme(_ scheme: ColorScheme) {
    }
}
