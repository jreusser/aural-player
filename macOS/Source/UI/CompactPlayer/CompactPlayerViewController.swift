//
//  CompactPlayerViewController.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import AppKit

class CompactPlayerViewController: NSViewController {
    
    @IBOutlet weak var containerBox: NSBox!

    @IBOutlet weak var imgArt: NSImageView!
    
    @IBOutlet weak var trackInfoView: PlayingTrackTextView!
    @IBOutlet weak var lblTrackTime: CenterTextLabel!
    @IBOutlet weak var seekSlider: NSSlider!
    @IBOutlet weak var btnRepeat: NSButton!
    
    @IBOutlet weak var playbackView: CompactPlaybackView!
    @IBOutlet weak var seekSliderView: ControlBarSeekSliderView!
    
    @IBOutlet weak var viewSettingsMenuButton: NSPopUpButton!
    
    @IBOutlet weak var scrollingEnabledMenuItem: NSMenuItem!
    @IBOutlet weak var showSeekPositionMenuItem: NSMenuItem!
    @IBOutlet weak var seekPositionDisplayTypeMenuItem: NSMenuItem!
    
    @IBOutlet weak var timeElapsedMenuItem: SeekPositionDisplayTypeMenuItem!
    @IBOutlet weak var timeRemainingMenuItem: SeekPositionDisplayTypeMenuItem!
    @IBOutlet weak var trackDurationMenuItem: SeekPositionDisplayTypeMenuItem!
    
    private var seekPositionDisplayTypeItems: [NSMenuItem] = []
    
    @IBOutlet weak var playbackViewController: CompactPlaybackViewController!
    @IBOutlet weak var audioViewController: ControlBarPlayerAudioViewController!
    @IBOutlet weak var sequencingViewController: ControlBarPlayerSequencingViewController!
    
    // Delegate that conveys all playback requests to the player / playback sequencer
    private let player: PlaybackDelegateProtocol = playbackDelegate
    
    // Delegate that provides access to the Favorites track list.
    private lazy var favorites: FavoritesDelegateProtocol = favoritesDelegate
    
    private let uiState: ControlBarPlayerUIState = controlBarPlayerUIState
    
    private var textViewConstraints: LayoutConstraintsManager!
    private var lblTrackTimeConstraints: LayoutConstraintsManager!
    private var seekSliderConstraints: LayoutConstraintsManager!
    
    private let minWindowWidthToShowSeekPosition: CGFloat = 610
    private let distanceBetweenControlsAndInfo: CGFloat = 31
    
    private lazy var messenger = Messenger(for: self)
    
    override func awakeFromNib() {
        
        // Constraint managers
//        lblTrackTimeConstraints = LayoutConstraintsManager(for: lblTrackTime)
//        seekSliderConstraints = LayoutConstraintsManager(for: seekSlider)
        
        applyTheme()
        
        colorSchemesManager.registerSchemeObserver(trackInfoView, forProperties: [\.backgroundColor, \.primaryTextColor, \.secondaryTextColor, \.tertiaryTextColor])
        fontSchemesManager.registerSchemeObserver(trackInfoView, forProperties: [\.playerPrimaryFont, \.playerSecondaryFont, \.playerTertiaryFont])
        
        // Seek slider
//        seekSliderConstraints.setLeading(relatedToLeadingOf: textView, offset: -1)
//        seekSliderConstraints.setTrailing(relatedToLeadingOf: btnRepeat, offset: -distanceBetweenControlsAndInfo)
//        seekSliderView.showSeekPosition = false
        
        // Text view
//        textViewConstraints.setLeading(relatedToTrailingOf: imgArt, offset: 10)
//        textViewConstraints.setHeight(26)
//        textViewConstraints.centerVerticallyInSuperview(offset: -2)
        
//        lblTrackTimeConstraints.setHeight(textView.height)
//        lblTrackTimeConstraints.centerVerticallyInSuperview(offset: 0)
        
//        layoutTextView()
//        textView.scrollingEnabled = uiState.trackInfoScrollingEnabled
        
        updateTrackInfo()
        
        // View settings menu items
//        timeElapsedMenuItem.displayType = .elapsed
//        timeRemainingMenuItem.displayType = .remaining
//        trackDurationMenuItem.displayType = .duration
//        
//        seekPositionDisplayTypeItems = [timeElapsedMenuItem, timeRemainingMenuItem, trackDurationMenuItem]
        
        // MARK: Notification subscriptions
        
        messenger.subscribeAsync(to: .player_trackTransitioned, handler: trackTransitioned(_:))
        messenger.subscribeAsync(to: .player_trackInfoUpdated, handler: trackInfoUpdated(_:))
        messenger.subscribeAsync(to: .player_trackNotPlayed, handler: trackNotPlayed(_:))
        
        messenger.subscribe(to: .favoritesList_addOrRemove, handler: addOrRemoveFavorite)
        
        messenger.subscribe(to: .applyTheme, handler: applyTheme)
        messenger.subscribe(to: .applyFontScheme, handler: applyFontScheme(_:))
        messenger.subscribe(to: .applyColorScheme, handler: applyColorScheme(_:))
    }
    
//    var windowWideEnoughForSeekPosition: Bool {
//        (view.window?.width ?? 0) >= minWindowWidthToShowSeekPosition
//    }
//    
//    ///
//    /// Computes the maximum required width for the seek position label, given
//    /// 1. the duration of the track currently playing, and
//    /// 2. the current font scheme.
//    ///
//    var widthForSeekPosLabel: CGFloat {
//        
//        guard let track = player.playingTrack else {return 0}
//        
//        let widthOfWidestNumber = String.widthOfWidestNumber(forFont: systemFontScheme.playerPrimaryFont)
//        let duration = track.duration
//        
//        let trackTimes = ValueFormatter.formatTrackTimes(0, duration, 0)
//        let widthOfTimeRemainingString = CGFloat(trackTimes.remaining.count)
//
//        return widthOfTimeRemainingString * widthOfWidestNumber
//    }
//    
//    func layoutTextView(forceChange: Bool = true) {
//        
//        let showSeekPosition: Bool = uiState.showSeekPosition && windowWideEnoughForSeekPosition
//        
//        guard forceChange || (seekSliderView.showSeekPosition != showSeekPosition) else {return}
//        
//        // Seek Position label
//        seekSliderView.showSeekPosition = showSeekPosition
//        
//        var labelWidth: CGFloat = 0
//        
//        if showSeekPosition {
//            
//            lblTrackTimeConstraints.removeAll(withAttributes: [.width, .trailing])
//            labelWidth = widthForSeekPosLabel + 5 // Compute the required width and add some padding.
//            
//            lblTrackTimeConstraints.setWidth(labelWidth)
//            lblTrackTimeConstraints.setTrailing(relatedToLeadingOf: btnRepeat, offset: -distanceBetweenControlsAndInfo)
//        }
//        
//        // Text view
//        textViewConstraints.removeAll(withAttributes: [.trailing])
//        textViewConstraints.setTrailing(relatedToLeadingOf: btnRepeat,
//                                        offset: -(distanceBetweenControlsAndInfo + (showSeekPosition ? labelWidth : 1)))
//    }
    
    // MARK: Track playback actions/functions ------------------------------------------------------------
    
    /// An image to display when the currently playing track does not have any associated cover art, resized to an optimal size for display in Control Center.
    private lazy var defaultArtwork: PlatformImage = {
        
        var image = PlatformImage.imgPlayingArt.copy(ofSize: imgArt.size).filledWithColor(.white)
        image.isTemplate = false
        return image
    }()
    
    private func updateTrackInfo() {
        
        if let theTrack = player.playingTrack {
            trackInfoView.trackInfo = PlayingTrackInfo(track: theTrack, playingChapterTitle: player.playingChapter?.chapter.title)
            
        } else {
            trackInfoView.trackInfo = nil
        }
        
        lblTrackTime.show()
        
        imgArt.image = player.playingTrack?.art?.image ?? defaultArtwork
//        imgArt.showIf(imgArt.image != nil && uiState.showAlbumArt)
        
//        infoBox.bringToFront()
        
//        if settingsBox.isShown {
//            settingsBox.bringToFront()
//        }
//        
//        if presentationModesBox.isShown {
//            presentationModesBox.bringToFront()
//        }
    }
    
    // MARK: Message handling

    func trackTransitioned(_ notification: TrackTransitionNotification) {
        
//        layoutTextView()
        updateTrackInfo()
    }
    
    // When track info for the playing track changes, display fields need to be updated
    func trackInfoUpdated(_ notification: TrackInfoUpdatedNotification) {
        
        if notification.updatedTrack == player.playingTrack {
            
//            if notification.updatedFields.contains(.duration) {
//                layoutTextView()
//            }
            
            updateTrackInfo()
        }
    }
    
    func trackNotPlayed(_ notification: TrackNotPlayedNotification) {
        
        updateTrackInfo()
        
        let errorDialog = DialogsAndAlerts.genericErrorAlert("Track not played",
                                                             notification.errorTrack.file.lastPathComponent,
                                                             notification.error.message)
            
        errorDialog.runModal()
    }
    
    // Required for dock menu function "Add/Remove playing track to/from Favorites".
    private func addOrRemoveFavorite() {
        
//        guard let playingTrack = player.playingTrack else {return}
//
//        if favorites.favoriteTrackExists(playingTrack) {
//            favorites.deleteFavoriteWithFile(playingTrack.file)
//
//        } else {
//            _ = favorites.addFavorite(track: playingTrack)
//        }
    }
    
    // MARK: Appearance ----------------------------------------
    
    func applyTheme() {
        
        applyFontScheme(systemFontScheme)
        applyColorScheme(systemColorScheme)
    }
    
    func applyFontScheme(_ fontScheme: FontScheme) {
        
//        textView.font = fontScheme.playerSecondaryFont
//        layoutTextView()
    }
    
    func applyColorScheme(_ colorScheme: ColorScheme) {
//        textView.textColor = colorScheme.player.trackInfoPrimaryTextColor
    }
    
    // MARK: View settings menu delegate functions and action handlers -----------------
    
    func menuNeedsUpdate(_ menu: NSMenu) {
        
//        scrollingEnabledMenuItem.onIf(textView.scrollingEnabled)
        
//        let windowWideEnoughForSeekPosition = self.windowWideEnoughForSeekPosition
//        showSeekPositionMenuItem.showIf(windowWideEnoughForSeekPosition)
//        seekPositionDisplayTypeMenuItem.showIf(windowWideEnoughForSeekPosition && uiState.showSeekPosition)
//        
//        guard windowWideEnoughForSeekPosition else {return}
//        
//        showSeekPositionMenuItem.onIf(uiState.showSeekPosition)
//        guard uiState.showSeekPosition else {return}
//        
//        seekPositionDisplayTypeItems.forEach {$0.off()}
//        
//        switch seekSliderView.seekPositionDisplayType {
//        
//        case .elapsed:
//            
//            timeElapsedMenuItem.on()
//            
//        case .remaining:
//            
//            timeRemainingMenuItem.on()
//            
//        case .duration:
//            
//            trackDurationMenuItem.on()
//        }
    }
    
//    @IBAction func toggleTrackInfoScrollingAction(_ sender: NSMenuItem) {
//        textView.scrollingEnabled.toggle()
//    }
    
    @IBAction func toggleShowSeekPositionAction(_ sender: NSMenuItem) {
        
//        uiState.showSeekPosition.toggle()
//        layoutTextView()
    }
    
    @IBAction func changeSeekPositionDisplayTypeAction(_ sender: SeekPositionDisplayTypeMenuItem) {
        seekSliderView.seekPositionDisplayType = sender.displayType
    }
    
    // MARK: Tear down ------------------------------------------
    
    override func destroy() {
        
        [playbackViewController, audioViewController, sequencingViewController].forEach {
            $0?.destroy()
        }
        
        messenger.unsubscribeFromAll()
    }
}
