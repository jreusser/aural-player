//
//  LibraryTracksControlsContainer.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import Cocoa

class LibraryTracksControlsContainer: ControlsContainerView {
    
    @IBOutlet weak var lblTracksSummary: NSTextField!
    @IBOutlet weak var lblDurationSummary: NSTextField!
    
    @IBOutlet weak var btnImportTracks: TintedImageButton!
    
    @IBOutlet weak var btnRemoveTracks: TintedImageButton!
    @IBOutlet weak var btnCropTracks: TintedImageButton!
    @IBOutlet weak var btnRemoveAllTracks: TintedImageButton!
    
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
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        
        viewsToShowOnMouseOver = [btnImportTracks,
                                  btnRemoveTracks, btnCropTracks, btnRemoveAllTracks,
                                  btnClearSelection, btnInvertSelection,
                                  btnSearch, btnSort,
                                  btnExport,
                                  btnPageUp, btnPageDown, btnScrollToTop, btnScrollToBottom]
        
        viewsToHideOnMouseOver = [lblTracksSummary, lblDurationSummary]
        
        colorSchemesManager.registerObservers([btnImportTracks, btnRemoveTracks, btnCropTracks, btnRemoveAllTracks,
                                               btnClearSelection, btnInvertSelection,
                                               btnSearch, sortTintedIconMenuItem,
                                               btnExport,
                                               btnPageUp, btnPageDown, btnScrollToTop, btnScrollToBottom],
                                              forProperty: \.buttonColor)
    }
}

class LibraryGroupedListControlsContainer: LibraryTracksControlsContainer {
    
    @IBOutlet weak var btnExpandAll: TintedImageButton!
    @IBOutlet weak var btnCollapseAll: TintedImageButton!
    
    @IBOutlet weak var outlineView: NSOutlineView!
    @IBOutlet weak var hoverControls: HoverControlsBox!
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        
        viewsToShowOnMouseOver.append(contentsOf: [btnExpandAll, btnCollapseAll])
        
        colorSchemesManager.registerObservers([btnExpandAll, btnCollapseAll],
                                              forProperty: \.buttonColor)
    }
    
    override func mouseEntered(with event: NSEvent) {
        
        super.mouseEntered(with: event)
        
        
    }
    
    override func mouseMoved(with event: NSEvent) {
        
        super.mouseMoved(with: event)
        
        guard let row = outlineView?.row(at: outlineView!.convert(event.locationInWindow, from: nil)),
              let group = outlineView?.item(atRow: row) as? Group,
              let rowView = outlineView?.view(atColumn: 0, row: row, makeIfNecessary: false) else {
                  
                  hoverControls?.hide()
                  return
              }
        
        hoverControls.group = group
        
        let boxHeight = hoverControls.height / 2
        let rowHeight = rowView.height / 2
        
        hoverControls.setFrameOrigin(self.convert(NSMakePoint(rowView.frame.maxX - 70, rowView.frame.minY + rowHeight - boxHeight - 5), from: rowView))
        hoverControls.show()
    }
    
    override func mouseExited(with event: NSEvent) {
        super.mouseExited(with: event)
        hoverControls?.hide()
    }
}
