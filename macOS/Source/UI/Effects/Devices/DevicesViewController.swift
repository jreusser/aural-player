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
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
//        let backgroundColor = systemColorScheme.backgroundColor
//        
//        tableScrollView.backgroundColor = backgroundColor
//        tableClipView.backgroundColor = backgroundColor
//        tableView.backgroundColor = backgroundColor
    }
}
