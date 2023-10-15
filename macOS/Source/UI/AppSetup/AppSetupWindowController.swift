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
    
    @IBOutlet weak var btnPresentationMode: NSButton!
    @IBOutlet weak var btnWindowLayout: NSButton!
    @IBOutlet weak var btnColorScheme: NSButton!
    @IBOutlet weak var btnFontScheme: NSButton!
    @IBOutlet weak var btnLibraryHome: NSButton!
    private lazy var tabButtons: [NSButton] = [btnPresentationMode, btnWindowLayout, btnColorScheme, btnFontScheme, btnLibraryHome]
    
    @IBOutlet weak var btnNext: NSButton!
    @IBOutlet weak var btnPrevious: NSButton!
    
    private var indexOfLastTabViewItem: Int {
        tabView.numberOfTabViewItems - 1
    }
    
    private let presentationModeSetupViewController: PresentationModeSetupViewController = .init()
    private let windowLayoutSetupViewController: WindowLayoutSetupViewController = .init()
    private let colorSchemeSetupViewController: ColorSchemeSetupViewController = .init()
    
//    private var subViews: [PreferencesViewProtocol] = []
    private lazy var messenger: Messenger = Messenger(for: self)
    
    override func windowDidLoad() {
        
        super.windowDidLoad()
        
        window?.isMovableByWindowBackground = true
        window?.center()
        
        for (index, controller) in [presentationModeSetupViewController, windowLayoutSetupViewController, colorSchemeSetupViewController].enumerated() {
            tabView.tabViewItem(at: index).view?.addSubview(controller.view)
        }
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
        
        if tabView.selectedIndex > 0 {
            
            for index in 0..<tabView.selectedIndex {
                tabButtons[index].contentTintColor = .systemBlue
            }
        }
    }
    
    @IBAction func previousStepAction(_ sender: Any) {
        
        guard tabView.selectedIndex > 0 else {return}
        
        tabView.selectPreviousTabViewItem(self)
        
        if tabView.selectedIndex == 0 {
            btnPrevious.disable()
        }
        
        btnNext.title = "Next"
        
        if tabView.selectedIndex < indexOfLastTabViewItem {
            
            for index in tabView.selectedIndex..<indexOfLastTabViewItem {
                tabButtons[index].contentTintColor = .selectedTextColor
            }
        }
    }
    
    @IBAction func skipSetupAction(_ sender: Any) {
        
        close()
        messenger.publish(.appSetup_completed)
    }
}
