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
    
    // Buttons whose tool tips may change
    @IBOutlet weak var btnPreviousTrack: NSButton!
    @IBOutlet weak var btnNextTrack: NSButton!
    
    @IBOutlet weak var btnRepeat: NSButton!
    @IBOutlet weak var btnShuffle: NSButton!
    @IBOutlet weak var btnLoop: NSButton!
    
    lazy var btnPlayPauseStateMachine: ButtonStateMachine<PlaybackState> =
    
    ButtonStateMachine(initialState: playbackDelegate.state,
                       mappings: [
                        ButtonStateMachine.StateMapping(state: .stopped, image: .imgPlay, colorProperty: \.buttonColor, toolTip: "Play"),
                        ButtonStateMachine.StateMapping(state: .playing, image: .imgPause, colorProperty: \.buttonColor, toolTip: "Pause"),
                        ButtonStateMachine.StateMapping(state: .paused, image: .imgPlay, colorProperty: \.buttonColor, toolTip: "Play")
                       ],
                       button: btnPlayPause)
    
    lazy var btnRepeatStateMachine: ButtonStateMachine<RepeatMode> = ButtonStateMachine(initialState: playQueueDelegate.repeatAndShuffleModes.repeatMode,
                                                                                                mappings: [
                                                                                                    ButtonStateMachine.StateMapping(state: .off, image: .imgRepeat, colorProperty: \.inactiveControlColor, toolTip: "Repeat"),
                                                                                                    ButtonStateMachine.StateMapping(state: .all, image: .imgRepeat, colorProperty: \.activeControlColor, toolTip: "Repeat"),
                                                                                                    ButtonStateMachine.StateMapping(state: .one, image: .imgRepeatOne, colorProperty: \.activeControlColor, toolTip: "Repeat")
                                                                                                ],
                                                                                                button: btnRepeat)
    
    lazy var btnShuffleStateMachine: ButtonStateMachine<ShuffleMode> = ButtonStateMachine(initialState: playQueueDelegate.repeatAndShuffleModes.shuffleMode,
                                                                                                  mappings: [
                                                                                                    ButtonStateMachine.StateMapping(state: .off, image: .imgShuffle, colorProperty: \.inactiveControlColor, toolTip: "Shuffle"),
                                                                                                    ButtonStateMachine.StateMapping(state: .on, image: .imgShuffle, colorProperty: \.activeControlColor, toolTip: "Shuffle")
                                                                                                  ],
                                                                                                  button: btnShuffle)
    
    lazy var btnLoopStateMachine: ButtonStateMachine<PlaybackLoopState> = ButtonStateMachine(initialState: playbackDelegate.playbackLoopState,
                                                                                                     mappings: [
                                                                                                        ButtonStateMachine.StateMapping(state: .none, image: .imgLoop, colorProperty: \.inactiveControlColor, toolTip: "Initiate a segment loop"),
                                                                                                        ButtonStateMachine.StateMapping(state: .started, image: .imgLoopStarted, colorProperty: \.activeControlColor, toolTip: "Complete the segment loop"),
                                                                                                        ButtonStateMachine.StateMapping(state: .complete, image: .imgLoop, colorProperty: \.activeControlColor, toolTip: "Remove the segment loop")
                                                                                                     ],
                                                                                                     button: btnLoop)
    
    @IBOutlet weak var btnSeekBackward: NSButton!
    @IBOutlet weak var btnSeekForward: NSButton!
    
    // Shows the time elapsed for the currently playing track, and allows arbitrary seeking within the track
    @IBOutlet weak var seekSlider: NSSlider!
    @IBOutlet weak var seekSliderCell: SeekSliderCell!
    
    // Volume/pan controls
    @IBOutlet weak var btnVolume: NSButton!
    @IBOutlet weak var volumeSlider: NSSlider!
    
    @IBOutlet weak var lblVolume: VALabel!
    
    // Wrappers around the feedback labels that automatically hide them after showing them for a brief interval
    lazy var autoHidingVolumeLabel: AutoHidingView = AutoHidingView(lblVolume, Self.feedbackLabelAutoHideIntervalSeconds)
    
    // Timer that periodically updates the seek position slider and label
    lazy var seekTimer: RepeatingTaskExecutor = RepeatingTaskExecutor(intervalMillis: (1000 / (2 * audioGraphDelegate.timeStretchUnit.effectiveRate)).roundedInt,
                                                                      task: {[weak self] in
                                                                        self?.updateSeekPosition()},
                                                                      queue: .main)
    
    let seekTimerTaskQueue: SeekTimerTaskQueue = .instance
    
    // Keeps track of the last known value of the current chapter (used to detect chapter changes)
    var curChapter: IndexedChapter? = nil
    
    lazy var messenger = Messenger(for: self)
    
    // Numerical ranges
    let highVolumeRange: ClosedRange<Float> = 200.0/3...100
    let mediumVolumeRange: Range<Float> = 100.0/3..<200.0/3
    let lowVolumeRange: Range<Float> = 1..<100.0/3
    
    // Time intervals for which feedback labels or views that are to be auto-hidden are displayed, before being hidden.
    static let feedbackLabelAutoHideIntervalSeconds: TimeInterval = 1
    
    private static let chapterChangePollingTaskId: String = "ChapterChangePollingTask"
    
    var showTrackTime: Bool {
        playerUIState.showTrackTime
    }
    
    var displaysChapterIndicator: Bool {
        true
    }
    
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
        
        setUpPlaybackControls()
        setUpTheming()
        
        trackChanged(to: playbackDelegate.playingTrack)
        
        setUpNotificationHandling()
    }
    
    func setUpPlaybackControls() {
        
        lblTrackTime.addGestureRecognizer(NSClickGestureRecognizer(target: self, action: #selector(self.toggleTrackTimeDisplayTypeAction(_:))))
        
        if var peekingPreviousTrackButton = btnPreviousTrack as? TrackPeekingButtonProtocol {
            
            peekingPreviousTrackButton.toolTipFunction = {
                
                if let prevTrack = playQueueDelegate.peekPrevious() {
                    return String(format: "Previous track: '%@'", prevTrack.displayName)
                }
                
                return nil
            }
            
            peekingPreviousTrackButton.updateTooltip()
        }
        
        if var peekingNextTrackButton = btnNextTrack as? TrackPeekingButtonProtocol {
            
            peekingNextTrackButton.toolTipFunction = {
                
                if let nextTrack = playQueueDelegate.peekNext() {
                    return String(format: "Next track: '%@'", nextTrack.displayName)
                }

                return nil
            }
            
            peekingNextTrackButton.updateTooltip()
        }
    }
    
    func trackChanged(to newTrack: Track?) {
        
        updateTrackInfo(for: newTrack, playingChapterTitle: playbackDelegate.playingChapter?.chapter.title)
        updatePlaybackControls(for: newTrack)
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
    
    func updatePlaybackControls(for track: Track?) {
        
        // Button state
        
        btnPlayPauseStateMachine.setState(playbackDelegate.state)
        [btnPreviousTrack, btnNextTrack].forEach {
            ($0 as? TrackPeekingButtonProtocol)?.updateTooltip()
        }
        
        updateRepeatAndShuffleControls(modes: playQueueDelegate.repeatAndShuffleModes)
        
        // Seek controls state
        
        let isPlayingTrack = track != nil
        seekSlider.enableIf(isPlayingTrack)
        seekSlider.showIf(isPlayingTrack)
        lblTrackTime.showIf(isPlayingTrack && showTrackTime)
        playbackLoopChanged()
        
        // Seek timer tasks
        
        if displaysChapterIndicator {
            
            if track?.hasChapters ?? false {
                beginPollingForChapterChange()
            } else {
                stopPollingForChapterChange()
            }
        }
        
        updateSeekTimerState()
        
        // Volume controls
        
        // Volume may have changed because of sound profiles
        volumeChanged(volume: audioGraphDelegate.volume, muted: audioGraphDelegate.muted)
    }
    
    // Creates a recurring task that polls the player to detect a change in the currently playing track chapter.
    // This only occurs when the currently playing track actually has chapters.
    func beginPollingForChapterChange() {
        
        seekTimerTaskQueue.enqueueTask(Self.chapterChangePollingTaskId, {
            
            let playingChapter: IndexedChapter? = playbackDelegate.playingChapter
            
            // Compare the current chapter with the last known value of current chapter.
            if self.curChapter != playingChapter {
                
                // There has been a change ... notify observers and update the variable.
                self.messenger.publish(ChapterChangedNotification(oldChapter: self.curChapter, newChapter: playingChapter))
                self.curChapter = playingChapter
            }
        })
    }
    
    // Disables the chapter change polling task
    func stopPollingForChapterChange() {
        seekTimerTaskQueue.dequeueTask(Self.chapterChangePollingTaskId)
    }
    
    func setUpTheming() {
        
        fontSchemesManager.registerObserver(self)
        colorSchemesManager.registerSchemeObservers(self)
        
        setUpColorSchemePropertyObservation()
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
    
    @IBAction func togglePlayPauseAction(_ sender: NSButton) {
     
        let priorState = playbackDelegate.state
        playbackDelegate.togglePlayPause()
        
        // If a track change occurred, we don't need to do these updates. A notif will take care of it.
        if priorState.isPlayingOrPaused {
            
            btnPlayPauseStateMachine.setState(playbackDelegate.state)
            updateSeekTimerState()
        }
    }
    
    @IBAction func previousTrackAction(_ sender: NSButton) {
        previousTrack()
    }
    
    func previousTrack() {
        playbackDelegate.previousTrack()
    }
    
    @IBAction func nextTrackAction(_ sender: NSButton) {
        nextTrack()
    }

    func nextTrack() {
        playbackDelegate.nextTrack()
    }
    
    @IBAction func seekBackwardAction(_ sender: NSButton) {
        
    }
    
    @IBAction func seekForwardAction(_ sender: NSButton) {
        
    }
    
    @IBAction func seekSliderAction(_ sender: NSSlider) {
        
        playbackDelegate.seekToPercentage(seekSlider.doubleValue)
        updateSeekPosition()
    }
    
    @IBAction func toggleLoopAction(_ sender: NSButton) {
        
        guard playbackDelegate.state.isPlayingOrPaused else {return}
        
        playbackDelegate.toggleLoop()
        messenger.publish(.player_playbackLoopChanged)
    }
    
    @IBAction func toggleTrackTimeDisplayTypeAction(_ sender: NSTextField) {
        
        playerUIState.trackTimeDisplayType = playerUIState.trackTimeDisplayType.toggle()
        setTrackTimeDisplayType(to: playerUIState.trackTimeDisplayType)
    }
    
    func updateSeekPosition() {
        
        let seekPosn = playbackDelegate.seekPosition
        seekSlider.doubleValue = seekPosn.percentageElapsed
        
        lblTrackTime.stringValue = ValueFormatter.formatTrackTime(elapsedSeconds: seekPosn.timeElapsed, duration: seekPosn.trackDuration,
                                                                  percentageElapsed: seekPosn.percentageElapsed, trackTimeDisplayType: playerUIState.trackTimeDisplayType)
        
        for task in seekTimerTaskQueue.tasks {
            task()
        }
    }
    
    var shouldEnableSeekTimer: Bool {
        
        var needTimer = false
        let isPlaying = playbackDelegate.state == .playing
        
        if isPlaying {
            
            let hasTasks = seekTimerTaskQueue.hasTasks
            
            let labelShown = showTrackTime
            let trackTimeDisplayType = playerUIState.trackTimeDisplayType
            let trackTimeNotStatic = labelShown && trackTimeDisplayType != .duration
            
            needTimer = hasTasks || trackTimeNotStatic
        }
        
        return needTimer
    }
    
    func updateSeekTimerState() {
        
        setSeekTimerState(to: shouldEnableSeekTimer)
        print("Updated timer state: \(shouldEnableSeekTimer)")
    }
    
    func setSeekTimerState(to timerOn: Bool) {
        timerOn ? seekTimer.startOrResume() : seekTimer.pause()
    }
    
    func playbackLoopChanged() {
        
        btnLoopStateMachine.setState(playbackDelegate.playbackLoopState)

        // When the playback loop for the current playing track is changed, the seek slider needs to be updated (redrawn) to show the current loop state
        
        if let playingTrack = playbackDelegate.playingTrack, let loop = playbackDelegate.playbackLoop {
            
            // If loop start has not yet been marked, mark it (e.g. when marking chapter loops)
            
            let trackDuration = playingTrack.duration
            let startPerc = loop.startTime * 100 / trackDuration
            seekSliderCell.markLoopStart(startPerc: startPerc)
            
            // Use the seek slider clone to mark the exact position of the center of the slider knob, at both the start and end points of the playback loop (for rendering)
            if let loopEndTime = loop.endTime {
                
                let endPerc = (loopEndTime / trackDuration) * 100
                seekSliderCell.markLoopEnd(endPerc: endPerc)
            }
            
        } else {
            seekSliderCell.removeLoop()
        }

        seekSlider.redraw()
        updateSeekPosition()
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
        toggleRepeatMode()
    }
    
    func toggleRepeatMode() {
        updateRepeatAndShuffleControls(modes: playQueueDelegate.toggleRepeatMode())
    }
    
    @IBAction func toggleShuffleModeAction(_ sender: NSButton) {
        toggleShuffleMode()
    }
    
    func toggleShuffleMode() {
        updateRepeatAndShuffleControls(modes: playQueueDelegate.toggleShuffleMode())
    }
    
    func updateRepeatAndShuffleControls(modes: RepeatAndShuffleModes) {
        
        btnRepeatStateMachine.setState(modes.repeatMode)
        btnShuffleStateMachine.setState(modes.shuffleMode)
    }
    
    func setRepeatMode(to repeatMode: RepeatMode) {
        updateRepeatAndShuffleControls(modes: playQueueDelegate.setRepeatMode(repeatMode))
    }
    
    func setShuffleMode(to shuffleMode: ShuffleMode) {
        updateRepeatAndShuffleControls(modes: playQueueDelegate.setShuffleMode(shuffleMode))
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
        
        lblTrackTime.showIf(playbackDelegate.playingTrack != nil && showTrackTime)
        updateSeekTimerState()
    }
    
    func setTrackTimeDisplayType(to format: TrackTimeDisplayType) {
        
        let seekPosn = playbackDelegate.seekPosition
        lblTrackTime.stringValue = ValueFormatter.formatTrackTime(elapsedSeconds: seekPosn.timeElapsed, duration: seekPosn.trackDuration,
                                                                  percentageElapsed: seekPosn.percentageElapsed, trackTimeDisplayType: playerUIState.trackTimeDisplayType)
        
        updateSeekTimerState()
    }
    
    // MARK: Notification handling ---------------------------------------------------------------------
    
    func setUpNotificationHandling() {
        
        messenger.subscribeAsync(to: .player_trackTransitioned, handler: trackTransitioned(_:))
        messenger.subscribe(to: .player_playbackLoopChanged, handler: playbackLoopChanged)
        messenger.subscribe(to: .player_trackNotPlayed, handler: trackNotPlayed(_:))
        
//        messenger.subscribe(to: .effects_playbackRateChanged, handler: playbackRateChanged(_:))
//        messenger.subscribe(to: .player_playbackLoopChanged, handler: playbackLoopChanged)
    }
    
    func trackTransitioned(_ notification: TrackTransitionNotification) {
        trackChanged(to: notification.endTrack)
    }
    
    func chapterChanged(_ notification: ChapterChangedNotification) {
        
    }
    
    func playingTrackInfoUpdated(_ notification: TrackInfoUpdatedNotification) {
        
    }
    
    func trackNotPlayed(_ notification: TrackNotPlayedNotification) {
        
    }
    
    override func destroy() {
        messenger.unsubscribeFromAll()
    }
}
 
