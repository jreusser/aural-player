//
//  PlayQueueContainer.swift
//  Aural-macOS
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import Cocoa

class PlayQueueContainer: NSView, ColorSchemeObserver {
    
    @IBOutlet weak var lblTracksSummary: NSTextField!
    @IBOutlet weak var lblDurationSummary: NSTextField!
    
    @IBOutlet weak var btnImportTracks: NSButton!
    
    @IBOutlet weak var btnRemoveTracks: NSButton!
    @IBOutlet weak var btnCropTracks: NSButton!
    @IBOutlet weak var btnRemoveAllTracks: NSButton!
    
    @IBOutlet weak var btnMoveTracksUp: NSButton!
    @IBOutlet weak var btnMoveTracksDown: NSButton!
    @IBOutlet weak var btnMoveTracksToTop: NSButton!
    @IBOutlet weak var btnMoveTracksToBottom: NSButton!
    
    @IBOutlet weak var btnClearSelection: NSButton!
    @IBOutlet weak var btnInvertSelection: NSButton!
    
    @IBOutlet weak var btnSearch: NSButton!
    @IBOutlet weak var btnSortPopup: NSPopUpButton!
    @IBOutlet weak var sortTintedIconMenuItem: TintedIconMenuItem!
    
    @IBOutlet weak var btnExport: NSButton!
    
    @IBOutlet weak var btnPageUp: NSButton!
    @IBOutlet weak var btnPageDown: NSButton!
    @IBOutlet weak var btnScrollToTop: NSButton!
    @IBOutlet weak var btnScrollToBottom: NSButton!
    
    var allButtons: [ColorSchemePropertyChangeReceiver] = []
    var viewsToShowOnMouseOver: [NSView] = []
    var viewsToHideOnMouseOver: [NSView] = []
    
    override func awakeFromNib() {
        
        setUpSubviewsForAutoHide()
        
        colorSchemesManager.registerSchemeObserver(self)
        colorSchemesManager.registerPropertyObserver(self, forProperty: \.buttonColor, changeReceivers: allButtons)
    }
    
    func setUpSubviewsForAutoHide() {
        
        viewsToShowOnMouseOver = [btnImportTracks,
                                  btnRemoveTracks, btnCropTracks, btnRemoveAllTracks,
                                  btnMoveTracksUp, btnMoveTracksDown, btnMoveTracksToTop, btnMoveTracksToBottom,
                                  btnClearSelection, btnInvertSelection,
                                  btnSearch, btnSortPopup,
                                  btnExport,
                                  btnPageUp, btnPageDown, btnScrollToTop, btnScrollToBottom]
        
        viewsToHideOnMouseOver = [lblTracksSummary, lblDurationSummary]
        
        allButtons = [btnImportTracks, btnRemoveTracks, btnCropTracks, btnRemoveAllTracks, btnMoveTracksUp, btnMoveTracksDown, btnMoveTracksToTop, btnMoveTracksToBottom, btnClearSelection, btnInvertSelection, btnSearch, sortTintedIconMenuItem, btnExport, btnPageUp, btnPageDown, btnScrollToTop, btnScrollToBottom]
    }
    
    override func viewDidEndLiveResize() {
        
        super.viewDidEndLiveResize()
        
        removeAllTrackingAreas()
        updateTrackingAreas()

        viewsToShowOnMouseOver.forEach {$0.hide()}
        viewsToHideOnMouseOver.forEach {$0.show()}
    }
    
    // Signals the view to start tracking mouse movements.
    func startTracking() {
        
        removeAllTrackingAreas()
        updateTrackingAreas()
    }
    
    // Signals the view to stop tracking mouse movements.
    func stopTracking() {
        removeAllTrackingAreas()
    }
    
    override func updateTrackingAreas() {
        
        // Create a tracking area that covers the bounds of the view. It should respond whenever the mouse enters or exits.
        addTrackingArea(NSTrackingArea(rect: self.bounds, options: [.activeAlways, .mouseEnteredAndExited],
                                       owner: self, userInfo: nil))
        
        super.updateTrackingAreas()
    }
    
    override func mouseEntered(with event: NSEvent) {
        
        viewsToShowOnMouseOver.forEach {$0.show()}
        viewsToHideOnMouseOver.forEach {$0.hide()}
    }
    
    override func mouseExited(with event: NSEvent) {
        
        viewsToShowOnMouseOver.forEach {$0.hide()}
        viewsToHideOnMouseOver.forEach {$0.show()}
    }
    
    func colorSchemeChanged() {
        
        allButtons.forEach {
            $0.colorChanged(systemColorScheme.buttonColor)
        }
    }
}
