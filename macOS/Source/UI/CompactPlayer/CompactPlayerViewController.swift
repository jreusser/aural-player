//
//  CompactPlayerViewController.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import AppKit

class CompactPlayerViewController: NSViewController {
    
    @IBOutlet weak var containerBox: NSBox!

    @IBOutlet weak var trackInfoContainerBox: NSBox!
    @IBOutlet weak var imgArt: NSImageView!
    @IBOutlet weak var textView: ScrollingTrackInfoView!
    @IBOutlet weak var lblTrackTime: CenterTextLabel!
    
    @IBOutlet weak var playbackView: CompactPlaybackView!
    @IBOutlet weak var seekSliderView: ControlBarSeekSliderView!
    
    @IBOutlet weak var showPlayerMenuItem: NSMenuItem!
    @IBOutlet weak var showPlayQueueMenuItem: NSMenuItem!
    
    @IBOutlet weak var scrollingEnabledMenuItem: NSMenuItem!
    @IBOutlet weak var showSeekPositionMenuItem: NSMenuItem!
    @IBOutlet weak var seekPositionDisplayTypeMenuItem: NSMenuItem!
    
    @IBOutlet weak var timeElapsedMenuItem: SeekPositionDisplayTypeMenuItem!
    @IBOutlet weak var timeRemainingMenuItem: SeekPositionDisplayTypeMenuItem!
    @IBOutlet weak var trackDurationMenuItem: SeekPositionDisplayTypeMenuItem!
    
    @IBOutlet weak var cornerRadiusStepper: NSStepper!
    @IBOutlet weak var lblCornerRadius: NSTextField!
    
    var seekPositionDisplayTypeItems: [NSMenuItem] = []
    
    @IBOutlet weak var playbackViewController: CompactPlaybackViewController!
    @IBOutlet weak var audioViewController: ControlBarPlayerAudioViewController!
    @IBOutlet weak var sequencingViewController: ControlBarPlayerSequencingViewController!
    
    // Delegate that conveys all playback requests to the player / playback sequencer
    private let player: PlaybackDelegateProtocol = playbackDelegate
    
    // Delegate that provides access to the Favorites track list.
    private lazy var favorites: FavoritesDelegateProtocol = favoritesDelegate
    
    private lazy var messenger = Messenger(for: self)
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        
        initFromPersistentState()
        
        updateTrackInfo()
        
        // View settings menu items
        timeElapsedMenuItem.displayType = .elapsed
        timeRemainingMenuItem.displayType = .remaining
        trackDurationMenuItem.displayType = .duration
        
        seekPositionDisplayTypeItems = [timeElapsedMenuItem, timeRemainingMenuItem, trackDurationMenuItem]
        
        // MARK: Notification subscriptions
        
        fontSchemesManager.registerObserver(self)
        colorSchemesManager.registerSchemeObserver(self)
        
        messenger.subscribeAsync(to: .player_trackTransitioned, handler: trackTransitioned(_:))
        messenger.subscribeAsync(to: .player_trackInfoUpdated, handler: trackInfoUpdated(_:))
        messenger.subscribeAsync(to: .player_trackNotPlayed, handler: trackNotPlayed(_:))
        
        messenger.subscribe(to: .favoritesList_addOrRemove, handler: addOrRemoveFavorite)
    }
    
    private func initFromPersistentState() {
        
        layoutTextView()
        textView.scrollingEnabled = compactPlayerUIState.trackInfoScrollingEnabled
    }
    
    func layoutTextView(forceChange: Bool = true) {
        
        let showSeekPosition: Bool = compactPlayerUIState.showSeekPosition
        
        guard forceChange || (seekSliderView.showSeekPosition != showSeekPosition) else {return}
        
        // Seek Position label
        seekSliderView.showSeekPosition = showSeekPosition
        
        trackInfoContainerBox.setFrameSize(NSSize(width: showSeekPosition ? 200 : 280, height: 26))
        textView.setFrameSize(NSSize(width: showSeekPosition ? 200 : 280, height: 26))
        
        textView.update()
    }
    
    // MARK: Track playback actions/functions ------------------------------------------------------------
    
    private func updateTrackInfo() {
        
        if let theTrack = player.playingTrack {
            textView.update(artist: theTrack.artist, title: theTrack.title ?? theTrack.defaultDisplayName)
            
        } else {
            textView.clear()
        }
        
        lblTrackTime.showIf(player.state.isPlayingOrPaused)
        
        if let playingTrackArt = player.playingTrack?.art?.image {
            
            imgArt.image = playingTrackArt
            imgArt.contentTintColor = nil
            imgArt.image?.isTemplate = false
            
        } else {
            
            imgArt.image = .imgPlayingArt
            imgArt.contentTintColor = systemColorScheme.secondaryTextColor
            imgArt.image?.isTemplate = true
        }
    }
    
    // MARK: Message handling --------------------------------------

    func trackTransitioned(_ notification: TrackTransitionNotification) {
        updateTrackInfo()
    }
    
    // When track info for the playing track changes, display fields need to be updated
    func trackInfoUpdated(_ notification: TrackInfoUpdatedNotification) {
        
        if notification.updatedTrack == player.playingTrack {
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
    
    override func destroy() {
        
        [playbackViewController, audioViewController, sequencingViewController].forEach {
            $0?.destroy()
        }
        
        messenger.unsubscribeFromAll()
    }
}

extension CompactPlayerViewController: FontSchemeObserver {
    
    func fontSchemeChanged() {
        
        textView.font = systemFontScheme.normalFont
        lblTrackTime.font = systemFontScheme.normalFont
        layoutTextView()
    }
}

extension CompactPlayerViewController: ColorSchemeObserver {
    
    func colorSchemeChanged() {
        
        lblTrackTime.textColor = systemColorScheme.secondaryTextColor
        textView.update()
    }
}
