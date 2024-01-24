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

class CompactPlayerViewModel: ObservableObject {
    
    @Published private(set) var coverArt: NSImage = .imgPlayingArt
    
    @Published private(set) var artist: String? = nil
    @Published private(set) var title: String = ""
    
    @Published private(set) var seekPositionText: String = ""
    @Published private(set) var seekPercentage: Double = 0
    
    @Published private(set) var isPlaying: Bool = false
    @Published private(set) var isMuted: Bool = false
    @Published private(set) var volume: Float = 0
    @Published private(set) var volumeButtonImage: NSImage = .imgVolumeLow
    
    @Published private(set) var repeatMode: RepeatMode = .off
    @Published private(set) var shuffleMode: ShuffleMode = .off
    
    @Published private(set) var backgroundColor: NSColor = .black
    
    @Published private(set) var primaryTextColor: NSColor = .white
    @Published private(set) var primaryTextFont: NSFont = .auxCaptionFont
    
    @Published private(set) var secondaryTextColor: NSColor = .lightGray
    @Published private(set) var secondaryTextFont: NSFont = .auxCaptionFont
    
    @Published private(set) var buttonColor: NSColor = .white
    @Published private(set) var activeControlColor: NSColor = .white
    
    @Published private(set) var previousTrackDisplayName: String = ""
    @Published private(set) var nextTrackDisplayName: String = ""
    
    private var seekTimer: RepeatingTaskExecutor!
    
//    static let shared: CompactPlayerViewModel = .init()
    private lazy var messenger: Messenger = .init(for: self)
    
    init() {
        
        update(forTrack: playbackInfoDelegate.playingTrack, playbackState: playbackInfoDelegate.state)
        
        isPlaying = playbackInfoDelegate.state == .playing
        isMuted = audioGraphDelegate.muted
        volume = audioGraphDelegate.volume
        
        let modes = playQueueDelegate.repeatAndShuffleModes
        repeatMode = modes.repeatMode
        shuffleMode = modes.shuffleMode
        
        updateSeekPosition()
        
        colorSchemeChanged()
        
        colorSchemesManager.registerObserver(self, forProperties: [\.backgroundColor, \.primaryTextColor, \.secondaryTextColor, \.buttonColor, \.activeControlColor])
        fontSchemesManager.registerObserver(self, forProperties: [\.playerPrimaryFont, \.playerSecondaryFont])
        
        messenger.subscribe(to: .player_trackTransitioned, handler: trackTransitioned(_:))
        messenger.subscribe(to: .player_playbackStateChanged) {[weak self] in
            self?.isPlaying = playbackInfoDelegate.state == .playing
        }
        
        seekTimer = RepeatingTaskExecutor(intervalMillis: 500,
                                          task: {[weak self] in
            self?.updateSeekPosition()},
                                          queue: .main)
        
        seekTimer.startOrResume()
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
        
        isPlaying = playbackState == .playing
        
        previousTrackDisplayName = playQueueDelegate.peekPrevious()?.displayName ?? "<None>"
        nextTrackDisplayName = playQueueDelegate.peekNext()?.displayName ?? "<None>"
    }
    
    // Numerical ranges
    private static let highVolumeRange: ClosedRange<Float> = 200.0/3...100
    private static let mediumVolumeRange: Range<Float> = 100.0/3..<200.0/3
    private static let lowVolumeRange: Range<Float> = 1..<100.0/3
    
    private func updateVolumeMuteButtonImage(_ volume: Float, _ muted: Bool) {
        
        if muted {
            
            volumeButtonImage = .imgMute
            
        } else {

            // Zero / Low / Medium / High (different images)
            
            switch volume {
                
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
}

extension CompactPlayerViewModel: ColorSchemeObserver {
    
    func colorSchemeChanged() {
        
        backgroundColor = systemColorScheme.backgroundColor
        primaryTextColor = systemColorScheme.primaryTextColor
        secondaryTextColor = systemColorScheme.secondaryTextColor
        buttonColor = systemColorScheme.buttonColor
        activeControlColor = systemColorScheme.activeControlColor
    }
    
    func colorChanged(to newColor: PlatformColor, forProperty property: KeyPath<ColorScheme, PlatformColor>) {
        
        backgroundColor = systemColorScheme.backgroundColor
        primaryTextColor = systemColorScheme.primaryTextColor
        secondaryTextColor = systemColorScheme.secondaryTextColor
        buttonColor = systemColorScheme.buttonColor
        activeControlColor = systemColorScheme.activeControlColor
    }
}

extension CompactPlayerViewModel: FontSchemeObserver {
    
    func fontSchemeChanged() {
        
        primaryTextFont = systemFontScheme.playerPrimaryFont
        secondaryTextFont = systemFontScheme.playerSecondaryFont
    }
    
    func fontChanged(to newFont: PlatformFont, forProperty property: KeyPath<FontScheme, PlatformFont>) {
        
        primaryTextFont = systemFontScheme.playerPrimaryFont
        secondaryTextFont = systemFontScheme.playerSecondaryFont
    }
}
