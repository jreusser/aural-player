//
//  PlayingTrackSubview.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

// TODO: Consolidate these 2 classes into one, unless there will be an expanded art view.

/*
    A base class for the 2 player views - Default and Expanded Art
 */
@IBDesignable
class PlayingTrackSubview: MouseTrackingView, ColorSchemeable {
    
    @IBOutlet weak var infoBox: NSBox!
    @IBOutlet weak var artView: NSImageView!
    @IBOutlet weak var textView: PlayingTrackTextView!
    
    @IBOutlet weak var controlsBox: NSBox!
    @IBOutlet weak var functionsButton: NSPopUpButton!
    
    fileprivate var autoHideFields_showing: Bool = false
    
    fileprivate lazy var uiState: PlayerUIState = playerUIState
    
    var trackInfo: PlayingTrackInfo? {
        
        didSet {
            trackInfoSet()
        }
    }
    
    func showView() {
    }
    
    func hideView() {
    }
    
    func update() {
        trackInfoSet()
    }
    
    fileprivate func trackInfoSet() {
        
        textView.trackInfo = self.trackInfo
        artView.image = trackInfo?.art ?? Images.imgPlayingArt
//        functionsButton.showIf(trackInfo != nil && uiState.showPlayingTrackFunctions)
    }

    fileprivate func moveInfoBoxTo(_ point: NSPoint) {
        
        infoBox.setFrameOrigin(point)
        
        // Vertically center functions box w.r.t. info box
//        functionsBox.frame.origin.y = infoBox.frame.maxY - functionsBox.frame.height - 5
    }
    
    func showOrHidePlayingTrackInfo() {
        infoBox.showIf(uiState.showTrackInfo || autoHideFields_showing)
    }
    
    func showOrHideAlbumArt() {
        artView.showIf(uiState.showAlbumArt)
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
    
    func showOrHidePlayingTrackFunctions() {
//        functionButtons.forEach {$0.showIf(trackInfo != nil && uiState.showPlayingTrackFunctions)}
    }
    
    func showOrHideMainControls() {
        controlsBox.showIf(uiState.showControls)
    }
    
    override func mouseEntered(with event: NSEvent) {
        autoHideFields_showing = true
    }
    
    override func mouseExited(with event: NSEvent) {
        autoHideFields_showing = false
    }
    
    var needsMouseTracking: Bool {
        return false
    }
    
    // MARK: Appearance functions
    
    func applyFontScheme(_ fontScheme: FontScheme) {
        textView.applyFontScheme(fontScheme)
    }
    
    func applyColorScheme(_ scheme: ColorScheme) {
        
        changeBackgroundColor(scheme.backgroundColor)
        textView.applyColorScheme(scheme)
    }
    
    func changeBackgroundColor(_ color: NSColor) {

        // Solid color
        infoBox.fillColor = color
        
        // The art view's shadow color will depend on the window background color (it needs to have contrast relative to it).
        artView.layer?.shadowColor = color.visibleShadowColor.cgColor
    }
    
    func changePrimaryTextColor(_ color: NSColor) {
        textView.changeTextColor()
    }
    
    func changeSecondaryTextColor(_ color: NSColor) {
        textView.changeTextColor()
    }
    
    func changeTertiaryTextColor(_ color: NSColor) {
        textView.changeTextColor()
    }
}

/*
   The "Default" player view.
*/
@IBDesignable
class DefaultPlayingTrackSubview: PlayingTrackSubview {
    
    private let infoBoxDefaultPosition: NSPoint = NSPoint(x: 85, y: 85)
    private let infoBoxCenteredPosition: NSPoint = NSPoint(x: 85, y: 65)
    
    override var needsMouseTracking: Bool {
//        return !uiState.showControls
        true
    }
    
    override func showView() {

        super.showView()
        
        artView.showIf(uiState.showAlbumArt)
//        functionsButton.showIf(trackInfo != nil && uiState.showPlayingTrackFunctions)
        moveInfoBoxTo(uiState.showControls ? infoBoxDefaultPosition : infoBoxCenteredPosition)

        controlsBox.showIf(uiState.showControls)
        controlsBox.bringToFront()
        
        startTracking()
    }
    
    override fileprivate func moveInfoBoxTo(_ point: NSPoint) {
        
        super.moveInfoBoxTo(point)
        artView.frame.origin.y = infoBox.frame.origin.y - 2 // 5 is half the difference in height between infoBox and artView
    }
    
    override func showOrHideMainControls() {
        
        super.showOrHideMainControls()
        
        // Re-position the info box, art view, and functions box
        moveInfoBoxTo(uiState.showControls ? infoBoxDefaultPosition : infoBoxCenteredPosition)
    }
    
    // Do nothing (this function is not allowed on the default player view)
    override func showOrHidePlayingTrackInfo() {}
    
    override func mouseEntered(with event: NSEvent) {
        
        super.mouseEntered(with: event)
        
        if trackInfo != nil {
            functionsButton.show()
        }
        
        if !uiState.showControls {
            autoHideControls_show()
        }
    }
    
    override func mouseExited(with event: NSEvent) {
        
        super.mouseExited(with: event)
        
        functionsButton.hide()
        
        if !uiState.showControls {
            autoHideControls_hide()
        }
    }
    
    private func autoHideControls_show() {
        
        // Show controls
        controlsBox.show()
        moveInfoBoxTo(infoBoxDefaultPosition)
    }
    
    private func autoHideControls_hide() {
        
        // Hide controls
        controlsBox.hide()
        moveInfoBoxTo(infoBoxCenteredPosition)
    }
}
