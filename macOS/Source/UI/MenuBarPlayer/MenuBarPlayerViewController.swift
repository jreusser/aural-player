//
//  MenuBarPlayerViewController.swift
//  Aural
//
//  Copyright © 2023 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

class MenuBarPlayerViewController: NSViewController {

    override var nibName: String? {"MenuBarPlayer"}
    
    @IBOutlet weak var appLogo: TintedImageView!
    @IBOutlet weak var btnQuit: WhiteImageButton!
    
    @IBOutlet weak var btnPresentationModes: WhiteImageButton!
    @IBOutlet weak var presentationModesBox: NSBox!
    
    @IBOutlet weak var radioBtnModularMode: NSButton!
    @IBOutlet weak var radioBtnUnifiedMode: NSButton!
    @IBOutlet weak var radioBtnControlBarMode: NSButton!
    
    @IBOutlet weak var infoBox: NSBox!
    @IBOutlet weak var trackInfoView: MenuBarPlayingTrackTextView!
    @IBOutlet weak var imgArt: NSImageView!
    
    @IBOutlet weak var playbackView: MenuBarPlaybackView!
    @IBOutlet weak var seekSliderView: MenuBarSeekSliderView!
    
    @IBOutlet weak var btnSettings: NSButton!
    @IBOutlet weak var settingsBox: NSBox!
    
    @IBOutlet weak var playbackViewController: MenuBarPlaybackViewController!
    @IBOutlet weak var audioViewController: MenuBarPlayerAudioViewController!
    @IBOutlet weak var sequencingViewController: MenuBarPlayerSequencingViewController!
    
    // Delegate that conveys all playback requests to the player / playback sequencer
    private let player: PlaybackDelegateProtocol = playbackDelegate
    
    private lazy var uiState: MenuBarPlayerUIState = menuBarPlayerUIState
    
    private lazy var messenger = Messenger(for: self)
    
    /// An image to display when the currently playing track does not have any associated cover art, resized to an optimal size for display in Control Center.
    private lazy var defaultArtwork: PlatformImage = {
        
        var image = PlatformImage.imgPlayingArt.copy(ofSize: imgArt.size).filledWithColor(.white)
        image.isTemplate = false
        return image
    }()
    
    override func awakeFromNib() {
        
        appLogo.contentTintColor = .white90Percent
        
        // MARK: Notification subscriptions
        
        messenger.subscribeAsync(to: .player_trackTransitioned, handler: trackTransitioned(_:))
        messenger.subscribeAsync(to: .player_trackInfoUpdated, handler: trackInfoUpdated(_:))
        messenger.subscribe(to: .player_chapterChanged, handler: chapterChanged(_:))
        messenger.subscribeAsync(to: .player_trackNotPlayed, handler: trackNotPlayed(_:))
    }
    
    override func destroy() {
        
        [playbackViewController, audioViewController, sequencingViewController].forEach {
            $0?.destroy()
        }
        
        messenger.unsubscribeFromAll()
    }
    
    override func viewDidLoad() {
        
        updateTrackInfo()

        // When the view first loads, the menu bar's menu is closed (not visible), so
        // don't bother updating the seek position unnecessarily.
        if view.superview == nil {
            seekSliderView.stopUpdatingSeekPosition()
        }
        
//        colorSchemesManager.registerObservers([btnQuit],
//                                              forProperty: \.buttonColor)
    }
    
    // MARK: Track playback actions/functions ------------------------------------------------------------
    
    private func updateTrackInfo() {
        
        if let theTrack = player.playingTrack {
            trackInfoView.trackInfo = PlayingTrackInfo(track: theTrack, playingChapterTitle: player.playingChapter?.chapter.title)
            
        } else {
            trackInfoView.trackInfo = nil
        }
        
        imgArt.image = player.playingTrack?.art?.image ?? defaultArtwork
        imgArt.showIf(imgArt.image != nil && uiState.showAlbumArt)
        
        infoBox.bringToFront()
        
        if settingsBox.isShown {
            settingsBox.bringToFront()
        }
        
        if presentationModesBox.isShown {
            presentationModesBox.bringToFront()
        }
    }
    
    @IBAction func showOrHideSettingsAction(_ sender: NSButton) {
        
        if settingsBox.isHidden {

            settingsBox.show()
            settingsBox.bringToFront()

        } else {
            
            settingsBox.hide()
            infoBox.bringToFront()
        }
    }
    
    @IBAction func showOrHidePresentationModesAction(_ sender: NSButton) {
        
        if presentationModesBox.isHidden {

            presentationModesBox.show()
            presentationModesBox.bringToFront()

        } else {
            
            presentationModesBox.hide()
            infoBox.bringToFront()
        }
    }
    
    func menuBarMenuOpened() {
        
        if settingsBox.isShown {
            
            settingsBox.hide()
            infoBox.bringToFront()
        }
        
        if presentationModesBox.isShown {

            presentationModesBox.hide()
            infoBox.bringToFront()
        }
        
        // If the player is playing, we need to resume updating the seek
        // position as the view is now visible.
        if player.state == .playing {
            seekSliderView.resumeUpdatingSeekPosition()
        } else {
            seekSliderView.updateSeekPosition()
        }
    }
    
    func menuBarMenuClosed() {
        
        if settingsBox.isShown {
            
            settingsBox.hide()
            infoBox.bringToFront()
        }
        
        if presentationModesBox.isShown {

            presentationModesBox.hide()
            infoBox.bringToFront()
        }
        
        // Updating seek position is not necessary when the view has been closed.
        seekSliderView.stopUpdatingSeekPosition()
    }
    
    // MARK: Message handling

    func trackTransitioned(_ notification: TrackTransitionNotification) {
        updateTrackInfo()
    }
    
    // When track info for the playing track changes, display fields need to be updated
    func trackInfoUpdated(_ notification: TrackInfoUpdatedNotification) {
        
        if notification.updatedTrack == player.playingTrack {
            updateTrackInfo()
        }
    }
    
    func chapterChanged(_ notification: ChapterChangedNotification) {
        
        if let playingTrack = player.playingTrack {
            trackInfoView.trackInfo = PlayingTrackInfo(track: playingTrack, playingChapterTitle: notification.newChapter?.chapter.title)
        }
    }
    
    func trackNotPlayed(_ notification: TrackNotPlayedNotification) {
        
        updateTrackInfo()
        
        let errorDialog = DialogsAndAlerts.genericErrorAlert("Track not played",
                                                             notification.errorTrack.file.lastPathComponent,
                                                             notification.error.message)
            
        errorDialog.runModal()
    }
    
    @IBAction func presentationModesRadioButtonAction(_ sender: AnyObject) {}
    
    @IBAction func switchPresentationModeAction(_ sender: AnyObject) {
        
        if radioBtnModularMode.isOn {
            appModeManager.presentMode(.modular)
        } else if radioBtnUnifiedMode.isOn {
            appModeManager.presentMode(.unified)
        } else {
            appModeManager.presentMode(.controlBar)
        }
    }
    
    @IBAction func cancelPresentationModeAction(_ sender: AnyObject) {
        
        presentationModesBox.hide()
        infoBox.bringToFront()
    }

    @IBAction func quitAction(_ sender: AnyObject) {
        NSApp.terminate(self)
    }
}
