////
////  ModularPlayerView.swift
////  Aural
////
////  Copyright © 2024 Kartik Venugopal. All rights reserved.
////
////  This software is licensed under the MIT software license.
////  See the file "LICENSE" in the project root directory for license terms.
////
//import Cocoa
//
///*
// A container view for the 2 types of player views - Default / Expanded Art view.
// Switches between the 2 views, shows/hides individual UI components, and handles functions such as auto-hide.
// */
//class ModularPlayerView: MouseTrackingView {
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
//    @IBOutlet weak var infoBox: NSBox!
//    @IBOutlet weak var artView: NSImageView!
//    @IBOutlet weak var textView: MultilineTrackTextView!
//    @IBOutlet weak var functionsButton: NSPopUpButton!
//    
//    @IBOutlet weak var controlsBox: NSBox!
//    private var autoHideFields_showing: Bool = false
//    
//    private lazy var messenger = Messenger(for: self)
//    
//    override func awakeFromNib() {
//        
//        super.awakeFromNib()
//        
//        // TODO: Hide functionsMenuItem on trackTransitioned (if endTrack == nil, i.e. playback stopped)
//        
//        repositionInfoBox()
//
//        controlsBox?.showIf((!isPlayingTrack) || playerUIState.showControls)
//        controlsBox?.bringToFront()
//        
//        startTracking()
//    }
//    
//    var isPlayingTrack: Bool {
//        playbackDelegate.state != .stopped
//    }
//    
//    func trackInfoSet() {
//        
////        lblTrackTime.showIf(trackInfo != nil && playerUIState.showTrackTime)
//        
//        controlsBox?.showIf((!isPlayingTrack) || playerUIState.showControls)
//        controlsBox?.bringToFront()
//    }
//    
//    
//    
//    func showOrHideAlbumArt() {
//        
//        artView.showIf(playerUIState.showAlbumArt)
//        repositionInfoBox()
//    }
//    
//    func showOrHideMainControls() {
//        
//        controlsBox?.showIf(playerUIState.showControls)
//        
//        // Re-position the info box, art view, and functions box
//        
//        if playerUIState.showAlbumArt {
//            moveInfoBoxTo(playerUIState.showControls ? infoBoxDefaultPosition : infoBoxCenteredPosition)
//        } else {
//            moveInfoBoxTo(playerUIState.showControls ? infoBoxDefaultPosition_noArt : infoBoxCenteredPosition_noArt)
//        }
//    }
//    
//    override func mouseEntered(with event: NSEvent) {
//        
////        guard trackInfo != nil else {return}
////        
////        autoHideFields_showing = true
////        
////        if trackInfo != nil {
////            functionsButton.show()
////        }
////        
////        if !playerUIState.showControls {
////            autoHideControls_show()
////        }
//    }
//    
//    override func mouseExited(with event: NSEvent) {
//        
////        guard trackInfo != nil else {return}
////        
////        autoHideFields_showing = false
////        
////        functionsButton.hide()
////        
////        if !playerUIState.showControls {
////            autoHideControls_hide()
////        }
//    }
//    
//    
//}
