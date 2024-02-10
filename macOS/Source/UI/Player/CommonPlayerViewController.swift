//
//  CommonPlayerViewController.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import AppKit

class CommonPlayerViewController: NSViewController, FontSchemeObserver, ColorSchemeObserver {
    
    @IBOutlet weak var artView: NSImageView!
    @IBOutlet weak var multilineTrackTextView: MultilineTrackTextView!
    @IBOutlet weak var scrollingTrackTextView: ScrollingTrackTextView!
    
    @IBOutlet weak var lblTrackTime: NSTextField!
    
    // Toggle buttons (their images change)
    @IBOutlet weak var btnPlayPause: NSButton!
    
    private lazy var btnPlayPauseStateMachine: ButtonStateMachine<PlaybackState> =
    
    ButtonStateMachine(initialState: playbackDelegate.state,
                       mappings: [
                        ButtonStateMachine.StateMapping(state: .stopped, image: .imgPlay, colorProperty: \.buttonColor, toolTip: "Play"),
                        ButtonStateMachine.StateMapping(state: .playing, image: .imgPause, colorProperty: \.buttonColor, toolTip: "Pause"),
                        ButtonStateMachine.StateMapping(state: .paused, image: .imgPlay, colorProperty: \.buttonColor, toolTip: "Play")
                       ],
                       button: btnPlayPause)
    
    @IBOutlet weak var btnLoop: NSButton!
    
    private lazy var btnLoopStateMachine: ButtonStateMachine<PlaybackLoopState> = ButtonStateMachine(initialState: playbackDelegate.playbackLoopState,
                                                                                                     mappings: [
                                                                                                        ButtonStateMachine.StateMapping(state: .none, image: .imgLoop, colorProperty: \.inactiveControlColor, toolTip: "Initiate a segment loop"),
                                                                                                        ButtonStateMachine.StateMapping(state: .started, image: .imgLoopStarted, colorProperty: \.activeControlColor, toolTip: "Complete the segment loop"),
                                                                                                        ButtonStateMachine.StateMapping(state: .complete, image: .imgLoop, colorProperty: \.activeControlColor, toolTip: "Remove the segment loop")
                                                                                                     ],
                                                                                                     button: btnLoop)
    
    // Buttons whose tool tips may change
    @IBOutlet weak var btnPreviousTrack: NSButton!
    @IBOutlet weak var btnNextTrack: NSButton!
    
    @IBOutlet weak var btnSeekBackward: NSButton!
    @IBOutlet weak var btnSeekForward: NSButton!
    
    // Volume/pan controls
    @IBOutlet weak var btnVolume: NSButton!
    @IBOutlet weak var volumeSlider: NSSlider!
    
    @IBOutlet weak var lblVolume: VALabel!
    
    // Wrappers around the feedback labels that automatically hide them after showing them for a brief interval
    var autoHidingVolumeLabel: AutoHidingView!
    
    // Numerical ranges
    let highVolumeRange: ClosedRange<Float> = 200.0/3...100
    let mediumVolumeRange: Range<Float> = 100.0/3..<200.0/3
    let lowVolumeRange: Range<Float> = 1..<100.0/3
    
    // Time intervals for which feedback labels or views that are to be auto-hidden are displayed, before being hidden.
    static let feedbackLabelAutoHideIntervalSeconds: TimeInterval = 1
    
    var trackTimeFont: NSFont {
        systemFontScheme.normalFont
    }
    
    var trackTimeColor: NSColor {
        systemColorScheme.secondaryTextColor
    }
    
    var volumeLevelFont: NSFont {
        systemFontScheme.smallFont
    }
    
    var volumeLevelColor: NSColor {
        systemColorScheme.secondaryTextColor
    }
    
    var multilineTrackTextTitleFont: NSFont {
        systemFontScheme.prominentFont
    }
    
    var multilineTrackTextTitleColor: NSColor {
        systemColorScheme.primaryTextColor
    }
    
    var multilineTrackTextArtistAlbumFont: NSFont {
        systemFontScheme.normalFont
    }
    
    var multilineTrackTextArtistAlbumColor: NSColor {
        systemColorScheme.secondaryTextColor
    }
    
    var multilineTrackTextChapterTitleFont: NSFont {
        systemFontScheme.smallFont
    }
    
    var multilineTrackTextChapterTitleColor: NSColor {
        systemColorScheme.tertiaryTextColor
    }
    
    var scrollingTrackTextFont: NSFont {
        systemFontScheme.normalFont
    }
    
    var scrollingTrackTextTitleColor: NSColor {
        systemColorScheme.primaryTextColor
    }
    
    var scrollingTrackTextArtistColor: NSColor {
        systemColorScheme.secondaryTextColor
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        setUpTheming()
        
        updateTrackInfo(for: playbackDelegate.playingTrack, playingChapterTitle: playbackDelegate.playingChapter?.chapter.title)
        btnPlayPauseStateMachine.setState(playbackDelegate.state)
        updateSeekTimerState()
        
        autoHidingVolumeLabel = AutoHidingView(lblVolume, Self.feedbackLabelAutoHideIntervalSeconds)
        volumeSlider.floatValue = audioGraphDelegate.volume
        volumeChanged(volume: audioGraphDelegate.volume, muted: audioGraphDelegate.muted, updateSlider: true, showFeedback: false)
    }
    
    func updateTrackInfo(for track: Track?, playingChapterTitle: String? = nil) {
        
        updateTrackTextView(for: track, playingChapterTitle: playingChapterTitle)
        updateCoverArt(for: track)
    }
    
    func updateTrackTextView(for track: Track?, playingChapterTitle: String? = nil) {
        // To be overriden!
    }
    
    func updateMultilineTrackTextView(for track: Track?, playingChapterTitle: String? = nil) {
        
        if let theTrack = track {
            multilineTrackTextView.trackInfo = PlayingTrackInfo(track: theTrack, playingChapterTitle: playingChapterTitle)
            
        } else {
            multilineTrackTextView.trackInfo = nil
        }
    }
    
    func updateScrollingTrackTextView(for track: Track?) {
        
        if let theTrack = track {
            scrollingTrackTextView.update(artist: theTrack.artist, title: theTrack.title ?? theTrack.defaultDisplayName)
            
        } else {
            scrollingTrackTextView.clear()
        }
    }
    
    func updateCoverArt(for track: Track?) {
        
        if let trackArt = track?.art {
            
            artView.image = trackArt.image
            artView.contentTintColor = nil
            artView.image?.isTemplate = false
            
        } else {

            artView.image = .imgPlayingArt
            artView.contentTintColor = systemColorScheme.secondaryTextColor
            artView.image?.isTemplate = true
        }
    }
    
    func setUpTheming() {
        
        fontSchemesManager.registerObserver(self)
        colorSchemesManager.registerSchemeObserver(self)
    }
    
    func setUpColorSchemePropertyObservation() {
        
    }
    
    func fontSchemeChanged() {
        
        updateTrackTextViewFonts()
        lblTrackTime.font = trackTimeFont
        lblVolume.font = volumeLevelFont
    }
    
    func updateTrackTextViewFonts() {
        // To be overriden!
    }
    
    func updateMultilineTrackTextViewFonts() {
        
        multilineTrackTextView.titleFont = multilineTrackTextTitleFont
        multilineTrackTextView.artistAlbumFont = multilineTrackTextArtistAlbumFont
        multilineTrackTextView.chapterTitleFont = multilineTrackTextChapterTitleFont
    }
    
    func updateScrollingTrackTextViewFonts() {
        scrollingTrackTextView.font = scrollingTrackTextFont
    }
    
    func colorSchemeChanged() {
        
        updateTrackTextViewColors()
        lblTrackTime.textColor = trackTimeColor
        
        btnVolume.colorChanged(systemColorScheme.buttonColor)
        volumeSlider.redraw()
        lblVolume.textColor = volumeLevelColor
    }
    
    func updateTrackTextViewColors() {
        // To be overriden!
    }
    
    func updateMultilineTrackTextViewColors() {
        
        multilineTrackTextView.titleColor = multilineTrackTextTitleColor
        multilineTrackTextView.artistAlbumColor = multilineTrackTextArtistAlbumColor
        multilineTrackTextView.chapterTitleColor = multilineTrackTextChapterTitleColor
    }
    
    func updateScrollingTrackTextViewColors() {
        
        scrollingTrackTextView.titleTextColor = scrollingTrackTextTitleColor
        scrollingTrackTextView.artistTextColor = scrollingTrackTextArtistColor
    }
    
    func setUpCommandHandling() {
        
    }
    
    func setUpNotificationHandling() {
        
    }
    
    @IBAction func togglePlayPauseAction(_ sender: NSButton) {
        
        playbackDelegate.togglePlayPause()
        btnPlayPauseStateMachine.setState(playbackDelegate.state)
        updateSeekTimerState()
    }
    
    @IBAction func previousTrackAction(_ sender: NSButton) {
        
    }
    
    @IBAction func nextTrackAction(_ sender: NSButton) {
        
    }
    
    @IBAction func seekBackwardAction(_ sender: NSButton) {
        
    }
    
    @IBAction func seekForwardAction(_ sender: NSButton) {
        
    }
    
    @IBAction func seekSliderAction(_ sender: NSSlider) {
        
    }
    
    @IBAction func toggleLoopAction(_ sender: NSButton) {
        
    }
    
    func updateSeekTimerState() {
    }
    
    func playChapter(index: Int) {
        
    }
    
    func previousChapter() {
        
    }
    
    func nextChapter() {
        
    }
    
    func replayChapter() {
        
    }
    
    func toggleChapterLoop() {
        
    }
    
    @IBAction func volumeAction(_ sender: NSSlider) {
        
        audioGraphDelegate.volume = volumeSlider.floatValue
        volumeChanged(volume: audioGraphDelegate.volume, muted: audioGraphDelegate.muted, updateSlider: false)
    }
    
    @IBAction func muteOrUnmuteAction(_ sender: NSButton) {
        muteOrUnmute()
    }
    
    func muteOrUnmute() {
        
        audioGraphDelegate.muted.toggle()
        updateVolumeMuteButtonImage(volume: audioGraphDelegate.volume, muted: audioGraphDelegate.muted)
    }
    
    // updateSlider should be true if the action was not triggered by the slider in the first place.
    func volumeChanged(volume: Float, muted: Bool, updateSlider: Bool = true, showFeedback: Bool = true) {
        
        if updateSlider {
            volumeSlider.floatValue = volume
        }
        
        lblVolume.stringValue = audioGraphDelegate.formattedVolume
        
        updateVolumeMuteButtonImage(volume: volume, muted: muted)
        
        // Shows and automatically hides the volume label after a preset time interval
        if showFeedback {
            autoHidingVolumeLabel.showView()
        }
    }
    
    func updateVolumeMuteButtonImage(volume: Float, muted: Bool) {

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
    
    @IBAction func toggleRepeatModeAction(_ sender: NSButton) {
        
    }
    
    @IBAction func toggleShuffleModeAction(_ sender: NSButton) {
        
    }
    
    func setRepeatMode(to repeatMode: RepeatMode) {
        
    }
    
    func setShuffleMode(to shuffleMode: ShuffleMode) {
        
    }
    
    func showOrHideAlbumArt() {
        
    }
    
    func showOrHideArtist() {
        
    }
    
    func showOrHideAlbum() {
        
    }
    
    func showOrHideCurrentChapter() {
        
    }
    
    func showOrHideMainControls() {
        
    }
    
    func showOrHideTrackTime() {
        
    }
    
    func toggleTrackTimeDisplayType() {
        
    }
    
    func setTrackTimeDisplayType(to format: TrackTimeDisplayType) {
        
    }
    
    func trackTransitioned(_ notification: TrackTransitionNotification) {
        
    }
    
    func chapterChanged(_ notification: ChapterChangedNotification) {
        
    }
    
    func playingTrackInfoUpdated(_ notification: TrackInfoUpdatedNotification) {
        
    }
    
    func trackNotPlayed(_ notification: TrackNotPlayedNotification) {
        
    }
}
