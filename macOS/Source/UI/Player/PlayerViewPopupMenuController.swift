//
//  PlayerViewPopupMenuController.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

/*
    Handles requests to show/hide or adjust different fields in the player view.
    e.g. show/hide album art or adjust seek time format.
 */
class PlayerViewPopupMenuController: NSObject, NSMenuDelegate {
    
    @IBOutlet weak var showArtMenuItem: NSMenuItem!
    @IBOutlet weak var showMainControlsMenuItem: NSMenuItem!
    @IBOutlet weak var showTrackTimeMenuItem: NSMenuItem!
    
    @IBOutlet weak var showArtistMenuItem: NSMenuItem!
    @IBOutlet weak var showAlbumMenuItem: NSMenuItem!
    @IBOutlet weak var showCurrentChapterMenuItem: NSMenuItem!
    
    @IBOutlet weak var trackTimeElapsedMenuItem: NSMenuItem!
    @IBOutlet weak var trackTimeRemainingMenuItem: NSMenuItem!
    @IBOutlet weak var trackDurationMenuItem: NSMenuItem!
    
    private let player: PlaybackInfoDelegateProtocol = playbackInfoDelegate
    
    private lazy var uiState: PlayerUIState = playerUIState
    
    private lazy var messenger = Messenger(for: self)
    
    // When the menu is about to open, set the menu item states according to the current window/view state
    func menuWillOpen(_ menu: NSMenu) {
        
        // Player view:
        
        var hasArtist: Bool = false
        var hasAlbum: Bool = false
        var hasChapters: Bool = false
        
        if let track = player.playingTrack {
            
            hasArtist = track.artist != nil
            hasAlbum = track.album != nil
            hasChapters = track.hasChapters
        }
        
        showArtistMenuItem.showIf(hasArtist)
        showArtistMenuItem.onIf(uiState.showArtist)
        
        showAlbumMenuItem.showIf(hasAlbum)
        showAlbumMenuItem.onIf(uiState.showAlbum)
        
        showCurrentChapterMenuItem.showIf(hasChapters)
        showCurrentChapterMenuItem.onIf(uiState.showCurrentChapter)
        
        showArtMenuItem.onIf(uiState.showAlbumArt)
        
        showMainControlsMenuItem.onIf(uiState.showControls)
        
        showTrackTimeMenuItem.onIf(uiState.showTrackTime)
        
        [trackTimeElapsedMenuItem, trackTimeRemainingMenuItem, trackDurationMenuItem].forEach {$0.off()}
        
        switch uiState.trackTimeDisplayType {
            
        case .elapsed:          trackTimeElapsedMenuItem.on()
            
        case .remaining:        trackTimeRemainingMenuItem.on()
            
        case .duration:         trackDurationMenuItem.on()
            
        }
    }
    
    @IBAction func showOrHideAlbumArtAction(_ sender: NSMenuItem) {
        
        uiState.showAlbumArt.toggle()
        messenger.publish(.player_showOrHideAlbumArt)
    }
    
    @IBAction func showOrHideArtistAction(_ sender: NSMenuItem) {
        
        uiState.showArtist.toggle()
        messenger.publish(.player_showOrHideArtist)
    }
    
    @IBAction func showOrHideAlbumAction(_ sender: NSMenuItem) {
        
        uiState.showAlbum.toggle()
        messenger.publish(.player_showOrHideAlbum)
    }
    
    @IBAction func showOrHideCurrentChapterAction(_ sender: NSMenuItem) {
        
        uiState.showCurrentChapter.toggle()
        messenger.publish(.player_showOrHideCurrentChapter)
    }
    
    @IBAction func showOrHideMainControlsAction(_ sender: NSMenuItem) {
        
        uiState.showControls.toggle()
        messenger.publish(.player_showOrHideMainControls)
    }
    
    @IBAction func showOrHideTrackTimeAction(_ sender: NSMenuItem) {
        
        uiState.showTrackTime.toggle()
        messenger.publish(.player_showOrHideTrackTime)
    }
    
    @IBAction func trackTimeElapsedDisplayTypeAction(_ sender: NSMenuItem) {
        setTrackTimeDisplayType(to: .elapsed)
    }
    
    @IBAction func trackTimeRemainingDisplayTypeAction(_ sender: NSMenuItem) {
        setTrackTimeDisplayType(to: .remaining)
    }
    
    @IBAction func trackTimeDurationDisplayTypeAction(_ sender: NSMenuItem) {
        setTrackTimeDisplayType(to: .duration)
    }
    
    private func setTrackTimeDisplayType(to type: TrackTimeDisplayType) {
        
        uiState.trackTimeDisplayType = type
        messenger.publish(.Player.setTrackTimeDisplayType, payload: type)
    }
}
