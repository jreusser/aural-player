////
////  PlayingTrackSubview.swift
////  Aural
////
////  Copyright © 2021 Kartik Venugopal. All rights reserved.
////
////  This software is licensed under the MIT software license.
////  See the file "LICENSE" in the project root directory for license terms.
////
//import Cocoa
//
//// TODO: Consolidate these 2 classes into one, unless there will be an expanded art view.
//
///*
//    A base class for the 2 player views - Default and Expanded Art
// */
//@IBDesignable
//class PlayingTrackSubview: MouseTrackingView, ColorSchemeable {
//    
//    @IBOutlet weak var infoBox: NSBox!
//    @IBOutlet weak var artView: NSImageView!
//    @IBOutlet weak var textView: PlayingTrackTextView!
//    
//    @IBOutlet weak var controlsBox: NSBox!
//    @IBOutlet weak var functionsButton: NSPopUpButton!
//    
//    @IBOutlet weak var lblTrackTime: NSTextField!
//    
//    fileprivate var autoHideFields_showing: Bool = false
//    
//    fileprivate lazy var uiState: PlayerUIState = playerUIState
//    
//    var trackInfo: PlayingTrackInfo? {
//        
//        didSet {
//            trackInfoSet()
//        }
//    }
//    
//    func showView() {
//    }
//    
//    func hideView() {
//    }
//    
//    func update() {
//        trackInfoSet()
//    }
//    
//    fileprivate func trackInfoSet() {
//        
//        textView.trackInfo = self.trackInfo
//        artView.image = trackInfo?.art ?? Images.imgPlayingArt
////        functionsButton.showIf(trackInfo != nil && uiState.showPlayingTrackFunctions)
//    }
//
//    fileprivate func moveInfoBoxTo(_ point: NSPoint) {
//        
//        infoBox.setFrameOrigin(point)
//        
//        // Vertically center functions box w.r.t. info box
////        functionsBox.frame.origin.y = infoBox.frame.maxY - functionsBox.frame.height - 5
//    }
//    
//    func showOrHideAlbumArt() {
//        artView.showIf(uiState.showAlbumArt)
//    }
//    
//    func showOrHideArtist() {
//        textView.displayedTextChanged()
//    }
//    
//    func showOrHideAlbum() {
//        textView.displayedTextChanged()
//    }
//    
//    func showOrHideCurrentChapter() {
//        textView.displayedTextChanged()
//    }
//    
//    func showOrHideMainControls() {
//        controlsBox.showIf(uiState.showControls)
//    }
//    
//    func showOrHideTrackTime() {
//        lblTrackTime.showIf(uiState.showTrackTime)
//    }
//    
//    override func mouseEntered(with event: NSEvent) {
//        autoHideFields_showing = true
//    }
//    
//    override func mouseExited(with event: NSEvent) {
//        autoHideFields_showing = false
//    }
//    
//    var needsMouseTracking: Bool {
//        return false
//    }
//    
//    // MARK: Appearance functions
//    
//    func applyFontScheme(_ fontScheme: FontScheme) {
//        textView.applyFontScheme(fontScheme)
//    }
//    
//    func applyColorScheme(_ scheme: ColorScheme) {
//        
//        changeBackgroundColor(scheme.backgroundColor)
//        textView.applyColorScheme(scheme)
//    }
//    
//    func changeBackgroundColor(_ color: NSColor) {
//
//        // Solid color
//        infoBox.fillColor = color
//        
//        // The art view's shadow color will depend on the window background color (it needs to have contrast relative to it).
//        artView.layer?.shadowColor = color.visibleShadowColor.cgColor
//    }
//    
//    func changePrimaryTextColor(_ color: NSColor) {
//        textView.changeTextColor()
//    }
//    
//    func changeSecondaryTextColor(_ color: NSColor) {
//        textView.changeTextColor()
//    }
//    
//    func changeTertiaryTextColor(_ color: NSColor) {
//        textView.changeTextColor()
//    }
//}
//
///*
//   The "Default" player view.
//*/
//@IBDesignable
//class DefaultPlayingTrackSubview: PlayingTrackSubview {
//    
//    private let infoBoxDefaultPosition: NSPoint = NSPoint(x: 85, y: 85)
//    private let infoBoxCenteredPosition: NSPoint = NSPoint(x: 85, y: 65)
//    
//    private let infoBoxDefaultWidth: CGFloat = 381
//    private let infoBoxWidth_noArt: CGFloat = 451
//    
//    private let textViewDefaultWidth: CGFloat = 305
//    private let textViewWidth_noArt: CGFloat = 375
//    
//    private let infoBoxDefaultPosition_noArt: NSPoint = NSPoint(x: 15, y: 85)
//    private let infoBoxCenteredPosition_noArt: NSPoint = NSPoint(x: 15, y: 65)
//    
//    override var needsMouseTracking: Bool {
////        return !uiState.showControls
//        true
//    }
//    
//    override func showView() {
//
//        super.showView()
//        
//        artView.showIf(uiState.showAlbumArt)
//        lblTrackTime.showIf(trackInfo != nil && uiState.showTrackTime)
////        functionsButton.showIf(trackInfo != nil && uiState.showPlayingTrackFunctions)
//        
//        repositionInfoBox()
//
//        controlsBox.showIf(uiState.showControls)
//        controlsBox.bringToFront()
//        
//        startTracking()
//    }
//    
//    override fileprivate func moveInfoBoxTo(_ point: NSPoint) {
//        
//        super.moveInfoBoxTo(point)
//        artView.frame.origin.y = infoBox.frame.origin.y - 2 // 5 is half the difference in height between infoBox and artView
//    }
//    
//    override func showOrHideAlbumArt() {
//        
//        super.showOrHideAlbumArt()
//        repositionInfoBox()
//    }
//    
//    private func repositionInfoBox() {
//        
//        if uiState.showAlbumArt {
//            
//            moveInfoBoxTo(uiState.showControls ? infoBoxDefaultPosition : infoBoxCenteredPosition)
//            infoBox.resize(infoBoxDefaultWidth, infoBox.height)
//            
//            textView.clipView.enclosingScrollView?.resize(width: textViewDefaultWidth)
//            textView.resized()
//            
//        } else {
//            
//            moveInfoBoxTo(uiState.showControls ? infoBoxDefaultPosition_noArt : infoBoxCenteredPosition_noArt)
//            infoBox.resize(infoBoxWidth_noArt, infoBox.height)
//            
//            textView.clipView.enclosingScrollView?.resize(width: textViewWidth_noArt)
//            textView.resized()
//        }
//    }
//    
//    override func showOrHideMainControls() {
//        
//        super.showOrHideMainControls()
//        
//        // Re-position the info box, art view, and functions box
//        
//        if uiState.showAlbumArt {
//            moveInfoBoxTo(uiState.showControls ? infoBoxDefaultPosition : infoBoxCenteredPosition)
//        } else {
//            moveInfoBoxTo(uiState.showControls ? infoBoxDefaultPosition_noArt : infoBoxCenteredPosition_noArt)
//        }
//    }
//    
//    override func mouseEntered(with event: NSEvent) {
//        
//        super.mouseEntered(with: event)
//        
//        if trackInfo != nil {
//            functionsButton.show()
//        }
//        
//        if !uiState.showControls {
//            autoHideControls_show()
//        }
//    }
//    
//    override func mouseExited(with event: NSEvent) {
//        
//        super.mouseExited(with: event)
//        
//        functionsButton.hide()
//        
//        if !uiState.showControls {
//            autoHideControls_hide()
//        }
//    }
//    
//    private func autoHideControls_show() {
//        
//        // Show controls
//        controlsBox.show()
//        moveInfoBoxTo(uiState.showAlbumArt ? infoBoxDefaultPosition : infoBoxDefaultPosition_noArt)
//    }
//    
//    private func autoHideControls_hide() {
//        
//        // Hide controls
//        controlsBox.hide()
//        moveInfoBoxTo(uiState.showAlbumArt ? infoBoxCenteredPosition : infoBoxCenteredPosition_noArt)
//    }
//}
