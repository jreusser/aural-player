//
//  PlayingTrackView.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

/*
 A container view for the 2 types of player views - Default / Expanded Art view.
 Switches between the 2 views, shows/hides individual UI components, and handles functions such as auto-hide.
 */
class PlayingTrackView: MouseTrackingView {
    
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
    
    @IBOutlet weak var lblTrackTime: NSTextField!
    
    private var autoHideFields_showing: Bool = false
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        
        artView.showIf(uiState.showAlbumArt)
        lblTrackTime.showIf(trackInfo != nil && uiState.showTrackTime)
        functionsButton.showIf(trackInfo != nil)
        
        repositionInfoBox()

        controlsBox.showIf(trackInfo == nil || uiState.showControls)
        controlsBox.bringToFront()
        
        startTracking()
        
        colorSchemesManager.registerObserver(infoBox, forProperty: \.backgroundColor)
        colorSchemesManager.registerObserver(textView, forProperties: [\.primaryTextColor, \.secondaryTextColor, \.tertiaryTextColor])
        
        fontSchemesManager.registerObserver(textView, forProperties: [\.playerPrimaryFont, \.playerSecondaryFont, \.playerTertiaryFont])
    }
    
    var trackInfo: PlayingTrackInfo? {
        
        didSet {
            trackInfoSet()
        }
    }
    
    func update() {
        trackInfoSet()
    }
    
    private func trackInfoSet() {
        
        textView.trackInfo = self.trackInfo
        artView.image = trackInfo?.art ?? Images.imgPlayingArt
        
        controlsBox.showIf(trackInfo == nil || uiState.showControls)
        controlsBox.bringToFront()
    }
    
    private func moveInfoBoxTo(_ point: NSPoint) {
        
        infoBox.setFrameOrigin(point)
        artView.frame.origin.y = infoBox.frame.origin.y - 2 // 5 is half the difference in height between infoBox and artView
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
        
        controlsBox.showIf(uiState.showControls)
        
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
        controlsBox.show()
        moveInfoBoxTo(uiState.showAlbumArt ? infoBoxDefaultPosition : infoBoxDefaultPosition_noArt)
    }
    
    private func autoHideControls_hide() {
        
        // Hide controls
        controlsBox.hide()
        moveInfoBoxTo(uiState.showAlbumArt ? infoBoxCenteredPosition : infoBoxCenteredPosition_noArt)
    }
    
    private func repositionInfoBox() {
        
        if uiState.showAlbumArt {
            
            moveInfoBoxTo(uiState.showControls ? infoBoxDefaultPosition : infoBoxCenteredPosition)
            infoBox.resize(infoBoxDefaultWidth, infoBox.height)
            
            textView.clipView.enclosingScrollView?.resize(width: textViewDefaultWidth)
            textView.resized()
            
        } else {
            
            moveInfoBoxTo(uiState.showControls ? infoBoxDefaultPosition_noArt : infoBoxCenteredPosition_noArt)
            infoBox.resize(infoBoxWidth_noArt, infoBox.height)
            
            textView.clipView.enclosingScrollView?.resize(width: textViewWidth_noArt)
            textView.resized()
        }
    }
    
    // MARK: Appearance functions
    
    func applyTheme() {
        applyFontScheme(systemFontScheme)
    }
    
    func applyFontScheme(_ fontScheme: FontScheme) {
        textView.applyFontScheme(fontScheme)
    }
}
