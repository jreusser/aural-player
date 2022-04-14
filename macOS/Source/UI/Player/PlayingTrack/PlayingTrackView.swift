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
class PlayingTrackView: MouseTrackingView, ColorSchemeable {
    
    @IBOutlet weak var defaultView: PlayingTrackSubview!
    
    private lazy var uiState: PlayerUIState = playerUIState

    // Info about the currently playing track
    var trackInfo: PlayingTrackInfo? {
        
        didSet {
            defaultView.trackInfo = trackInfo
        }
    }
    
    // Sets up the view for display.
    func showView() {
        
        setUpMouseTracking()
        defaultView.showView()
        
        self.show()
    }
    
    // This is required when the player view is hidden.
    func hideView() {
        
        self.hide()
        
        if isTracking {
            stopTracking()
        }
    }
    
    func update() {
        defaultView.update()
    }
    
    func showOrHidePlayingTrackInfo() {
        defaultView.showOrHidePlayingTrackInfo()
    }
    
    func showOrHidePlayingTrackFunctions() {
        
        defaultView.showOrHidePlayingTrackFunctions()
    }
    
    func showOrHideAlbumArt() {
        
        defaultView.showOrHideAlbumArt()
    }
    
    func showOrHideArtist() {
        defaultView.showOrHideArtist()
    }
    
    func showOrHideAlbum() {
        defaultView.showOrHideAlbum()
    }
    
    func showOrHideCurrentChapter() {
        defaultView.showOrHideCurrentChapter()
    }
    
    func showOrHideMainControls() {
        
        defaultView.showOrHideMainControls()
        setUpMouseTracking()
    }
    
    override func mouseEntered(with event: NSEvent) {
        defaultView.mouseEntered()
    }
    
    override func mouseExited(with event: NSEvent) {

        // If this check is not performed, the track-peeking buttons (previous/next track)
        // will cause a false positive mouse exit event.
        if !self.frame.contains(event.locationInWindow) {
            defaultView.mouseExited()
        }
    }

    // Set up mouse tracking if necessary (for auto-hide).
    private func setUpMouseTracking() {
        
        if defaultView.needsMouseTracking {
            
            if !isTracking {
                startTracking()
            }
            
        } else if isTracking {
            
            stopTracking()
        }
    }
    
    func applyTheme() {
        
        applyFontScheme(fontSchemesManager.systemScheme)
        applyColorScheme(colorSchemesManager.systemScheme)
    }
    
    func applyFontScheme(_ fontScheme: FontScheme) {
        defaultView.applyFontScheme(fontScheme)
    }
    
    func applyColorScheme(_ scheme: ColorScheme) {
        defaultView.applyColorScheme(scheme)
    }
    
    func changeBackgroundColor(_ color: NSColor) {
        defaultView.changeBackgroundColor(color)
    }
    
    func changePrimaryTextColor(_ color: NSColor) {
        defaultView.changePrimaryTextColor(color)
    }
    
    func changeSecondaryTextColor(_ color: NSColor) {
        defaultView.changeSecondaryTextColor(color)
    }
    
    func changeTertiaryTextColor(_ color: NSColor) {
        defaultView.changeTertiaryTextColor(color)
    }
}
