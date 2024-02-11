//
//  MenuBarPVC.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import AppKit

class MenuBarPVC: CommonPlayerViewController {
    
    @IBOutlet weak var rootContainerBox: NSBox!
    @IBOutlet weak var btnQuit: FillableImageButton!
    @IBOutlet weak var logoImage: TintedImageView!
//    @IBOutlet weak var presentationModeMenuItem: TintedIconMenuItem!
    
//    @IBOutlet weak var btnSettingsMenu: NSButton!
//    @IBOutlet weak var settingsMenuIconItem: TintedIconMenuItem!
    
    @IBOutlet weak var settingsMenu: NSMenu!
    
    @IBOutlet weak var showPlayQueueMenuItem: NSMenuItem!
    
    @IBOutlet weak var timeElapsedMenuItem: SeekPositionDisplayTypeMenuItem!
    @IBOutlet weak var timeRemainingMenuItem: SeekPositionDisplayTypeMenuItem!
    @IBOutlet weak var trackDurationMenuItem: SeekPositionDisplayTypeMenuItem!
    
    var seekPositionDisplayTypeItems: [NSMenuItem] = []
    
    override var nibName: NSNib.Name? {"MenuBarPlayer"}
    
    override var shouldEnableSeekTimer: Bool {
        super.shouldEnableSeekTimer && view.superview != nil
    }
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        
        // View settings menu items
        timeElapsedMenuItem.displayType = .elapsed
        timeRemainingMenuItem.displayType = .remaining
        trackDurationMenuItem.displayType = .duration
        
        seekPositionDisplayTypeItems = [timeElapsedMenuItem, timeRemainingMenuItem, trackDurationMenuItem]
    }
    
    override var showTrackTime: Bool {
        compactPlayerUIState.showTrackTime
    }
    
    override var trackTimeFont: NSFont {
        systemFontScheme.smallFont
    }
    
    override var displaysChapterIndicator: Bool {
        false
    }
    
    override func updateTrackTextView(for track: Track?, playingChapterTitle: String? = nil) {
        updateMultilineTrackTextView(for: track, playingChapterTitle: playingChapterTitle)
    }
    
    override var multilineTrackTextTitleFont: NSFont {
        systemFontScheme.normalFont
    }
    
    override var multilineTrackTextArtistAlbumFont: NSFont {
        systemFontScheme.smallFont
    }
    
    override func updateTrackTextViewFonts() {
        updateMultilineTrackTextViewFonts()
    }
    
    override func updateTrackTextViewColors() {
        updateMultilineTrackTextViewColors()
    }
    
    override func colorSchemeChanged() {
        
        super.colorSchemeChanged()
        
        rootContainerBox.fillColor = systemColorScheme.backgroundColor
        btnQuit.colorChanged(systemColorScheme.buttonColor)
        logoImage.colorChanged(systemColorScheme.captionTextColor)
    }
    
    func stopUpdatingSeekPosition() {
        setSeekTimerState(to: false)
    }
    
    func resumeUpdatingSeekPosition() {
        
        updateSeekPosition()
        setSeekTimerState(to: true)
    }
    
    @IBAction func toggleSettingsMenuAction(_ sender: NSButton) {
        messenger.publish(.MenuBarPlayer.toggleSettingsMenu)
    }
    
    @IBAction func presentationModesRadioButtonAction(_ sender: AnyObject) {}
    
    @IBAction func switchPresentationModeAction(_ sender: AnyObject) {
        
//        if radioBtnModularMode.isOn {
//            appModeManager.presentMode(.modular)
//        } else if radioBtnUnifiedMode.isOn {
//            appModeManager.presentMode(.unified)
//        } else {
//            appModeManager.presentMode(.controlBar)
//        }
    }
    
    @IBAction func cancelPresentationModeAction(_ sender: AnyObject) {
        
//        presentationModesBox.hide()
//        infoBox.bringToFront()
    }

    @IBAction func quitAction(_ sender: AnyObject) {
        NSApp.terminate(self)
    }
}

extension MenuBarPVC: NSMenuDelegate {
    
    func menuDidClose(_ menu: NSMenu) {
        
//        if settingsBox.isShown {
//
//            settingsBox.hide()
//            infoBox.bringToFront()
//        }
//
//        if presentationModesBox.isShown {
//
//            presentationModesBox.hide()
//            infoBox.bringToFront()
//        }
        
        // Updating seek position is not necessary when the view has been closed.
        setSeekTimerState(to: false)
    }
    
    func menuWillOpen(_ menu: NSMenu) {
        
        showPlayQueueMenuItem.onIf(menuBarPlayerUIState.showPlayQueue)
        
        seekPositionDisplayTypeItems.forEach {$0.off()}
        
        switch playerUIState.trackTimeDisplayType {
            
        case .elapsed:
            timeElapsedMenuItem.on()
            
        case .remaining:
            timeRemainingMenuItem.on()
            
        case .duration:
            trackDurationMenuItem.on()
        }
        
//        if settingsBox.isShown {
//
//            settingsBox.hide()
//            infoBox.bringToFront()
//        }
//
//        if presentationModesBox.isShown {
//
//            presentationModesBox.hide()
//            infoBox.bringToFront()
//        }
        
        // If the player is playing, we need to resume updating the seek
        // position as the view is now visible.
        updateSeekPosition()
        updateSeekTimerState()
    }
    
    // Shows/hides the Play Queue view
    @IBAction func showPlayQueueAction(_ sender: AnyObject) {
        
        menuBarPlayerUIState.showPlayQueue.toggle()
        messenger.publish(.MenuBarPlayer.togglePlayQueue)
    }

    @IBAction func changeSeekPositionDisplayTypeAction(_ sender: SeekPositionDisplayTypeMenuItem) {
        
        playerUIState.trackTimeDisplayType = sender.displayType
//        messenger.publish(.CompactPlayer.changeTrackTimeDisplayType)
    }
}
