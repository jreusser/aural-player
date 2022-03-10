//
//  DevicesViewController.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import Cocoa

class DevicesViewController: NSViewController, Destroyable {
    
    override var nibName: String? {"Devices"}
    
    // ------------------------------------------------------------------------
    
    // MARK: UI fields
    
    @IBOutlet weak var tableView: NSTableView!
    @IBOutlet weak var tableScrollView: NSScrollView!
    @IBOutlet weak var tableClipView: NSClipView!
    
    @IBOutlet weak var panSlider: NSSlider!
    @IBOutlet weak var lblPan: VALabel!
    
    private lazy var audioGraph: AudioGraphDelegateProtocol = objectGraph.audioGraphDelegate
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
//        let backgroundColor = systemColorScheme.backgroundColor
//
//        tableScrollView.backgroundColor = backgroundColor
//        tableClipView.backgroundColor = backgroundColor
//        tableView.backgroundColor = backgroundColor
        panSlider.floatValue = audioGraph.pan
        lblPan.stringValue = audioGraph.formattedPan
        
        objectGraph.colorSchemesManager.registerObserver(lblPan, forProperty: \.primaryTextColor)
    }
    
    @IBAction func panAction(_ sender: Any) {
        
        audioGraph.pan = panSlider.floatValue
        lblPan.stringValue = audioGraph.formattedPan
    }
}
