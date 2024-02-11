//
//  MenuBarPlayQueueViewController.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import AppKit

///
/// A container for *CompactPlayQueueViewController*.
///
class MenuBarPlayQueueViewController: NSViewController {
    
    override var nibName: NSNib.Name? {"MenuBarPlayQueue"}
    
    private let compactPlayQueueViewController: CompactPlayQueueViewController = .init()
    
    @IBOutlet weak var rootContainerBox: NSBox!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        view.addSubview(compactPlayQueueViewController.view)
        compactPlayQueueViewController.view.anchorToSuperview()
        
        colorSchemesManager.registerSchemeObserver(self)
    }
}

extension MenuBarPlayQueueViewController: ColorSchemeObserver {
    
    func colorSchemeChanged() {
        rootContainerBox.fillColor = systemColorScheme.backgroundColor
    }
}
