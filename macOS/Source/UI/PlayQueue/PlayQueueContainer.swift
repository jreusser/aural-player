//
//  PlayQueueContainer.swift
//  Aural-macOS
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import Cocoa

class PlayQueueContainer: NSView {
    
    @IBOutlet weak var lblTracksSummary: NSTextField!
    @IBOutlet weak var lblDurationSummary: NSTextField!
    
    @IBOutlet weak var btnImportTracks: TintedImageButton!
    
    @IBOutlet weak var btnRemoveTracks: TintedImageButton!
    @IBOutlet weak var btnCropTracks: TintedImageButton!
    @IBOutlet weak var btnRemoveAllTracks: TintedImageButton!
    
    @IBOutlet weak var btnMoveTracksUp: TintedImageButton!
    @IBOutlet weak var btnMoveTracksDown: TintedImageButton!
    @IBOutlet weak var btnMoveTracksToTop: TintedImageButton!
    @IBOutlet weak var btnMoveTracksToBottom: TintedImageButton!
    
    @IBOutlet weak var btnClearSelection: TintedImageButton!
    @IBOutlet weak var btnInvertSelection: TintedImageButton!
    
    @IBOutlet weak var btnSearch: TintedImageButton!
    @IBOutlet weak var btnSort: NSPopUpButton!
    @IBOutlet weak var sortTintedIconMenuItem: TintedIconMenuItem!
    
    @IBOutlet weak var btnExport: TintedImageButton!
    
    @IBOutlet weak var btnPageUp: TintedImageButton!
    @IBOutlet weak var btnPageDown: TintedImageButton!
    @IBOutlet weak var btnScrollToTop: TintedImageButton!
    @IBOutlet weak var btnScrollToBottom: TintedImageButton!
    
    private var viewsToShowOnMouseOver: [NSView] = []
    private var viewsToHideOnMouseOver: [NSView] = []
    
    override func awakeFromNib() {
        
        viewsToShowOnMouseOver = [btnImportTracks,
                                  btnRemoveTracks, btnCropTracks, btnRemoveAllTracks,
                                  btnMoveTracksUp, btnMoveTracksDown, btnMoveTracksToTop, btnMoveTracksToBottom,
                                  btnClearSelection, btnInvertSelection,
                                  btnSearch, btnSort,
                                  btnExport,
                                  btnPageUp, btnPageDown, btnScrollToTop, btnScrollToBottom]
        
        viewsToHideOnMouseOver = [lblTracksSummary, lblDurationSummary]
        
        colorSchemesManager.registerObservers([btnImportTracks, btnRemoveTracks, btnCropTracks, btnRemoveAllTracks, btnMoveTracksUp, btnMoveTracksDown, btnMoveTracksToTop, btnMoveTracksToBottom, btnClearSelection, btnInvertSelection, btnSearch, sortTintedIconMenuItem, btnExport, btnPageUp, btnPageDown, btnScrollToTop, btnScrollToBottom], forProperty: \.buttonColor)
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
}
