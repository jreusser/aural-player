//
//  CompactPlayerViewModel.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import AppKit

class CompactPlayerViewModel: NSObject, ObservableObject {
    
    @Published private(set) var coverArt: NSImage = .imgPlayingArt
    
    @Published private(set) var artist: String? = nil
    @Published private(set) var title: String = ""
    
    @Published private(set) var seekPositionText: String = ""
    @Published private(set) var seekPercentage: Double = 0
    
    @Published private(set) var playButtonImage: NSImage = .imgPlay
    @Published private(set) var playButtonTooltip: String = "Play"
    
    @Published private(set) var volume: Float = 0
    @Published private(set) var volumeButtonImage: NSImage = .imgVolumeLow
    
    @Published private(set) var repeatButtonImage: NSImage = .imgRepeat
    @Published private(set) var repeatButtonImageColor: NSColor = .white
    @Published private(set) var shuffleButtonImageColor: NSColor = .white
    
    @Published private(set) var backgroundColor: NSColor = .black
    
    @Published private(set) var primaryTextColor: NSColor = .white
    @Published private(set) var primaryTextFont: NSFont = .auxCaptionFont
    
    @Published private(set) var secondaryTextColor: NSColor = .lightGray
    @Published private(set) var secondaryTextFont: NSFont = .auxCaptionFont
    
    @Published private(set) var buttonColor: NSColor = .white
    @Published private(set) var activeControlColor: NSColor = .white
    @Published private(set) var inactiveControlColor: NSColor = .gray
    
    @Published private(set) var previousTrackDisplayName: String = ""
    @Published private(set) var nextTrackDisplayName: String = ""
    
    private var seekTimer: RepeatingTaskExecutor!
    
//    static let shared: CompactPlayerViewModel = .init()
    private lazy var messenger: Messenger = .init(for: self)
    
    override init() {
        
        super.init()
        
        update(forTrack: playbackInfoDelegate.playingTrack, playbackState: playbackInfoDelegate.state)
        
        volume = audioGraphDelegate.volume
        
        repeatModeUpdated()
        shuffleModeUpdated()
        muteStateUpdated()
        volumeUpdated()
        
        updateSeekPosition()
        
        colorSchemeChanged()
        
//        colorSchemesManager.registerObserver(self, forProperties: [\.backgroundColor, \.primaryTextColor, \.secondaryTextColor, \.buttonColor, \.activeControlColor, \.inactiveControlColor])
//        //fontSchemesManager.registerObserver(self, forProperties: [\.prominentFont, \.normalFont])
        
        messenger.subscribeAsync(to: .player_trackTransitioned, handler: trackTransitioned(_:))
        messenger.subscribeAsync(to: .player_playbackStateChanged) {[weak self] in
            self?.playPauseStateToggled()
        }
        
        seekTimer = RepeatingTaskExecutor(intervalMillis: 500,
                                          task: {[weak self] in
            self?.updateSeekPosition()},
                                          queue: .main)
        
        seekTimer.startOrResume()
    }
    
    func playPauseStateToggled() {
        
        let isPlaying = playbackInfoDelegate.state == .playing
        self.playButtonImage = isPlaying ? .imgPause : .imgPlay
        self.playButtonTooltip = isPlaying ? "Pause" : "Play"
    }
    
    private func updateSeekPosition() {
        
        let seekPos = playbackDelegate.seekPosition
        seekPercentage = seekPos.percentageElapsed
        seekPositionText = ValueFormatter.formatTrackTime(elapsedSeconds: seekPos.timeElapsed, duration: seekPos.trackDuration,
                                                                  percentageElapsed: seekPos.percentageElapsed, trackTimeDisplayType: playerUIState.trackTimeDisplayType)
    }
    
    private func trackTransitioned(_ notif: TrackTransitionNotification) {
        update(forTrack: notif.endTrack, playbackState: notif.endState)
    }
    
    private func update(forTrack playingTrack: Track?, playbackState: PlaybackState) {
        
        coverArt = playingTrack?.art?.image ?? .imgPlayingArt
        artist = playingTrack?.artist
        title = playingTrack?.title ?? ""
        
        playPauseStateToggled()
        
        previousTrackDisplayName = playQueueDelegate.peekPrevious()?.displayName ?? "<None>"
        nextTrackDisplayName = playQueueDelegate.peekNext()?.displayName ?? "<None>"
    }
    
    func repeatModeUpdated() {
        
        let mode = playQueueDelegate.repeatAndShuffleModes.repeatMode
        self.repeatButtonImage = mode == .one ? .imgRepeatOne : .imgRepeat
        self.repeatButtonImageColor = mode == .off ? systemColorScheme.buttonColor : systemColorScheme.activeControlColor
    }
    
    func shuffleModeUpdated() {
        
        let mode = playQueueDelegate.repeatAndShuffleModes.shuffleMode
        self.shuffleButtonImageColor = mode == .off ? systemColorScheme.buttonColor : systemColorScheme.activeControlColor
    }
    
    // Numerical ranges
    private static let highVolumeRange: ClosedRange<Float> = 200.0/3...100
    private static let mediumVolumeRange: Range<Float> = 100.0/3..<200.0/3
    private static let lowVolumeRange: Range<Float> = 1..<100.0/3
    
    func volumeUpdated() {
        
        if !audioGraphDelegate.muted {
            updateVolumeButtonImage()
        }
    }
    
    func muteStateUpdated() {
        
        if audioGraphDelegate.muted {
            volumeButtonImage = .imgMute
        } else {
            updateVolumeButtonImage()
        }
    }
    
    private func updateVolumeButtonImage() {
        
        // Zero / Low / Medium / High (different images)
        
        switch audioGraphDelegate.volume {
            
        case Self.highVolumeRange:
            
            volumeButtonImage = .imgVolumeHigh
            
        case Self.mediumVolumeRange:
            
            volumeButtonImage = .imgVolumeMedium
            
        case Self.lowVolumeRange:
            
            volumeButtonImage = .imgVolumeLow
            
        default:
            
            volumeButtonImage = .imgVolumeZero
        }
    }
}

extension CompactPlayerViewModel: ColorSchemeObserver {
    
    func colorSchemeChanged() {
        
        backgroundColor = systemColorScheme.backgroundColor
        primaryTextColor = systemColorScheme.primaryTextColor
        secondaryTextColor = systemColorScheme.secondaryTextColor
        buttonColor = systemColorScheme.buttonColor
        activeControlColor = systemColorScheme.activeControlColor
        inactiveControlColor = systemColorScheme.inactiveControlColor
    }
    
    func colorChanged(to newColor: PlatformColor, forProperty property: ColorSchemeProperty) {
        
        switch property {
            
        case \.backgroundColor:
            backgroundColor = systemColorScheme.backgroundColor
            
        case \.primaryTextColor:
            primaryTextColor = systemColorScheme.primaryTextColor
            
        case \.secondaryTextColor:
            secondaryTextColor = systemColorScheme.secondaryTextColor
            
        case \.buttonColor:
            buttonColor = systemColorScheme.buttonColor
            
        case \.activeControlColor:
            activeControlColor = systemColorScheme.activeControlColor
            
        case \.inactiveControlColor:
            inactiveControlColor = systemColorScheme.inactiveControlColor
            
        default:
            return
        }
    }
}

extension CompactPlayerViewModel: FontSchemeObserver {
    
    func fontSchemeChanged() {
        
        primaryTextFont = systemFontScheme.prominentFont
        secondaryTextFont = systemFontScheme.normalFont
    }
    
    func fontChanged(to newFont: PlatformFont, forProperty property: KeyPath<FontScheme, PlatformFont>) {
        
        primaryTextFont = systemFontScheme.prominentFont
        secondaryTextFont = systemFontScheme.normalFont
    }
}
