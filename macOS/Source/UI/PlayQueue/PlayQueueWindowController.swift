//
//  PlayQueueWindowController.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import Cocoa

class PlayQueueWindowController: NSWindowController, ColorSchemeObserver {
    
    override var windowNibName: String? {"PlayQueueWindow"}
    
    @IBOutlet weak var btnClose: TintedImageButton!
    @IBOutlet weak var lblCaption: NSTextField!
    
    @IBOutlet weak var rootContainer: NSBox!
    @IBOutlet weak var tabButtonsContainer: NSBox!
    
    // The tab group that switches between the 4 playlist views
    @IBOutlet weak var tabGroup: AuralTabView!
    
    private var compactViewController: CompactPlayQueueViewController = .init()
    
    private let colorSchemesManager: ColorSchemesManager = objectGraph.colorSchemesManager
    private let fontSchemesManager: FontSchemesManager = objectGraph.fontSchemesManager
    
    override func windowDidLoad() {
        
        super.windowDidLoad()
        
        let compactView = compactViewController.view
        tabGroup.addViewsForTabs([compactView])
        compactView.anchorToSuperview()
        
        colorSchemesManager.registerObserver(self, forProperties: [\.backgroundColor, \.captionTextColor])
        colorSchemesManager.registerObserver(btnClose, forProperty: \.buttonColor)
        
        lblCaption.font = fontSchemesManager.systemScheme.effects.unitCaptionFont
    }
    
    func colorChanged(to newColor: PlatformColor, forProperty property: KeyPath<ColorScheme, PlatformColor>) {
        
        switch property {
            
        case \.backgroundColor:
            
            rootContainer.fillColor = newColor
            tabButtonsContainer.fillColor = newColor
            
        case \.captionTextColor:
            
            lblCaption.textColor = newColor
         
        default:
            
            return
        }
    }
    
    override func destroy() {
        // TODO: 
    }
}
