//
//  AppSetupWindowController.swift
//  Aural
//
//  Copyright © 2023 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import Cocoa

class AppSetupWindowController: NSWindowController {
    
    override var windowNibName: String? {"AppSetupWindow"}
    
    @IBOutlet weak var tabView: NSTabView!
    
    @IBOutlet weak var btnNext: NSButton!
    @IBOutlet weak var btnPrevious: NSButton!
    
    private var indexOfLastTabViewItem: Int {
        tabView.numberOfTabViewItems - 1
    }
    
    private let presentationModeSetupViewController: PresentationModeSetupViewController = .init()
    private let windowLayoutSetupViewController: WindowLayoutSetupViewController = .init()
    
//    private var subViews: [PreferencesViewProtocol] = []
    private lazy var messenger: Messenger = Messenger(for: self)
    
    override func windowDidLoad() {
        
        super.windowDidLoad()
        
        window?.isMovableByWindowBackground = true
        window?.center()
        
        tabView.tabViewItem(at: 0).view?.addSubview(presentationModeSetupViewController.view)
        tabView.tabViewItem(at: 1).view?.addSubview(windowLayoutSetupViewController.view)
    }
    
    @IBAction func nextStepAction(_ sender: Any) {
        
        if tabView.selectedIndex == indexOfLastTabViewItem {
            
            // Last step, done with setup
            close()
            messenger.publish(.appSetup_completed, payload: appSetup)
            
        } else {
            
            tabView.selectNextTabViewItem(self)
            
            if tabView.selectedIndex == indexOfLastTabViewItem {
                btnNext.title = "Done"
            }
            
            btnPrevious.enable()
        }
    }
    
    @IBAction func previousStepAction(_ sender: Any) {
        
        guard tabView.selectedIndex > 0 else {return}
        
        tabView.selectPreviousTabViewItem(self)
        
        if tabView.selectedIndex == 0 {
            btnPrevious.disable()
        }
        
        btnNext.title = "Next"
    }
    
    @IBAction func skipSetupAction(_ sender: Any) {
        
        close()
        messenger.publish(.appSetup_completed)
    }
}
