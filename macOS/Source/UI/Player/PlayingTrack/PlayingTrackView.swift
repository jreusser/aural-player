//
//  PlayingTrackView.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

/*
 A container view for the 2 types of player views - Default / Expanded Art view.
 Switches between the 2 views, shows/hides individual UI components, and handles functions such as auto-hide.
 */
class PlayingTrackView: MouseTrackingView, FontSchemeObserver, ColorSchemeObserver {
    
    private lazy var uiState: PlayerUIState = playerUIState
    
    private let infoBoxDefaultPosition: NSPoint = NSPoint(x: 85, y: 85)
    private let infoBoxCenteredPosition: NSPoint = NSPoint(x: 85, y: 65)
    
    private let infoBoxDefaultWidth: CGFloat = 381
    private let infoBoxWidth_noArt: CGFloat = 451
    
    private let textViewDefaultWidth: CGFloat = 305
    private let textViewWidth_noArt: CGFloat = 375
    
    private let infoBoxDefaultPosition_noArt: NSPoint = NSPoint(x: 15, y: 85)
    private let infoBoxCenteredPosition_noArt: NSPoint = NSPoint(x: 15, y: 65)
    
    @IBOutlet weak var infoBox: NSBox!
    @IBOutlet weak var artView: NSImageView!
    @IBOutlet weak var textView: PlayingTrackTextView!
    
    @IBOutlet weak var controlsBox: NSBox!
    @IBOutlet weak var functionsButton: NSPopUpButton!
    @IBOutlet weak var functionsMenuItem: TintedIconMenuItem!
    
    @IBOutlet weak var lblTrackTime: CenterTextLabel!
    
    private var autoHideFields_showing: Bool = false
    
    private lazy var messenger = Messenger(for: self)
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        
        artView.showIf(uiState.showAlbumArt)
        lblTrackTime.showIf(trackInfo != nil && uiState.showTrackTime)
        functionsButton.showIf(trackInfo != nil)
        
        // TODO: Hide functionsMenuItem on trackTransitioned (if endTrack == nil, i.e. playback stopped)
        
        repositionInfoBox()

        controlsBox?.showIf(trackInfo == nil || uiState.showControls)
        controlsBox?.bringToFront()
        
        startTracking()
        
        colorSchemesManager.registerSchemeObserver(self)
        colorSchemesManager.registerPropertyObserver(self, forProperty: \.backgroundColor, changeReceiver: infoBox)
        colorSchemesManager.registerPropertyObserver(self, forProperty: \.backgroundColor, handler: textView.backgroundColorChanged(_:))
        colorSchemesManager.registerPropertyObserver(self, forProperties: [\.primaryTextColor, \.secondaryTextColor, \.tertiaryTextColor], changeReceiver: textView)
        colorSchemesManager.registerPropertyObserver(self, forProperty: \.secondaryTextColor, handler: secondaryTextColorChanged(_:))
        colorSchemesManager.registerPropertyObserver(self, forProperty: \.buttonColor, changeReceiver: functionsMenuItem)

        fontSchemesManager.registerObserver(self)
        
        messenger.subscribeAsync(to: .player_trackTransitioned, handler: trackTransitioned(_:))
    }
    
    var trackInfo: PlayingTrackInfo? {
        
        didSet {
            trackInfoSet()
        }
    }
    
    func artUpdated() {
        
        if let trackArt = trackInfo?.art {
            
            artView.contentTintColor = nil
            artView.image = trackArt
            
        } else {

            artView.contentTintColor = systemColorScheme.secondaryTextColor
            artView.image = .imgPlayingArt
        }
    }
    
    private func trackInfoSet() {
        
        textView.trackInfo = self.trackInfo
        artUpdated()
        
        lblTrackTime.showIf(trackInfo != nil && uiState.showTrackTime)
        
        controlsBox?.showIf(trackInfo == nil || uiState.showControls)
        controlsBox?.bringToFront()
    }
    
    private func secondaryTextColorChanged(_ newColor: PlatformColor) {
        artUpdated()
    }
    
    private func moveInfoBoxTo(_ point: NSPoint) {
        
        infoBox.setFrameOrigin(point)
        artView.frame.origin.y = infoBox.frame.origin.y + 2 // 5 is half the difference in height between infoBox and artView
    }
    
    func showOrHideAlbumArt() {
        
        artView.showIf(uiState.showAlbumArt)
        repositionInfoBox()
    }
    
    func showOrHideArtist() {
        textView.displayedTextChanged()
    }
    
    func showOrHideAlbum() {
        textView.displayedTextChanged()
    }
    
    func showOrHideCurrentChapter() {
        textView.displayedTextChanged()
    }
    
    func showOrHideMainControls() {
        
        controlsBox?.showIf(uiState.showControls)
        
        // Re-position the info box, art view, and functions box
        
        if uiState.showAlbumArt {
            moveInfoBoxTo(uiState.showControls ? infoBoxDefaultPosition : infoBoxCenteredPosition)
        } else {
            moveInfoBoxTo(uiState.showControls ? infoBoxDefaultPosition_noArt : infoBoxCenteredPosition_noArt)
        }
    }
    
    func showOrHideTrackTime() {
        lblTrackTime.showIf(uiState.showTrackTime)
    }
    
    override func mouseEntered(with event: NSEvent) {
        
        guard trackInfo != nil else {return}
        
        autoHideFields_showing = true
        
        if trackInfo != nil {
            functionsButton.show()
        }
        
        if !uiState.showControls {
            autoHideControls_show()
        }
    }
    
    override func mouseExited(with event: NSEvent) {
        
        guard trackInfo != nil else {return}
        
        autoHideFields_showing = false
        
        functionsButton.hide()
        
        if !uiState.showControls {
            autoHideControls_hide()
        }
    }
    
    private func autoHideControls_show() {
        
        // Show controls
        controlsBox?.show()
        moveInfoBoxTo(uiState.showAlbumArt ? infoBoxDefaultPosition : infoBoxDefaultPosition_noArt)
    }
    
    private func autoHideControls_hide() {
        
        // Hide controls
        controlsBox?.hide()
        moveInfoBoxTo(uiState.showAlbumArt ? infoBoxCenteredPosition : infoBoxCenteredPosition_noArt)
    }
    
    private func repositionInfoBox() {
        
        if uiState.showAlbumArt {
            
            moveInfoBoxTo(uiState.showControls ? infoBoxDefaultPosition : infoBoxCenteredPosition)
            infoBox.resize(infoBoxDefaultWidth, infoBox.height)
            
            textView.clipView.enclosingScrollView?.resize(width: textViewDefaultWidth)
            
        } else {
            
            moveInfoBoxTo(uiState.showControls ? infoBoxDefaultPosition_noArt : infoBoxCenteredPosition_noArt)
            infoBox.resize(infoBoxWidth_noArt, infoBox.height)
            
            textView.clipView.enclosingScrollView?.resize(width: textViewWidth_noArt)
        }
        
        textView.resized()
    }
    
    private func trackTransitioned(_ notif: TrackTransitionNotification) {
        
        // If playback stopped, hide/dismiss the functions menu.
        if notif.endTrack == nil {
            
            functionsButton.hide()
            functionsButton.menu?.cancelTracking()
        }
    }
    
    // MARK: Theming ------------------------------------------------------------------
    
    func colorSchemeChanged() {
        
        infoBox.fillColor = systemColorScheme.backgroundColor
        functionsMenuItem.colorChanged(systemColorScheme.buttonColor)
        
        textView.backgroundColor = systemColorScheme.backgroundColor
        textView.update()
        
        if trackInfo?.art == nil {
            artView.contentTintColor = systemColorScheme.secondaryTextColor
        }
    }
    
    func fontSchemeChanged() {
        
        lblTrackTime.font = systemFontScheme.normalFont
        textView.update()
    }
}
