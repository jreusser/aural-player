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
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        
        viewsToShowOnMouseOver.append(contentsOf: [btnExpandAll, btnCollapseAll])
    }
}
