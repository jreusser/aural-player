//
//  TuneBrowserViewController+Actions.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import AppKit

extension TuneBrowserViewController {
    
    @IBAction func pathControlAction(_ sender: Any) {
        
        guard let item = pathControlWidget.clickedPathItem, let indexOfItem = pathControlWidget.indexOf(item: item) else {return}
        
        // Special case - Same folder as the one displayed is clicked (i.e. the last path item)
        if indexOfItem == pathControlWidget.pathItems.count - 1 {
            return
        }
        
        // Special case - Root folder in tree of current tab clicked
        if indexOfItem == 0, let tabVC = currentTabVC {
            
            showFolder(tabVC.tree.root, inTree: tabVC.tree)
            return
        }
        
        let pathComponents: [String] = (1...indexOfItem).map {pathControlWidget.pathItems[$0].title}
        guard let tree = currentTabVC?.tree, let folder = tree.folderForPathComponents(pathComponents) else {return}
        
        showFolder(folder, inTree: tree)
    }
    
    @IBAction func backHistoryMenuAction(_ sender: TuneBrowserHistoryMenuItem) {
        
        history.back(to: sender.folder)
//        showFolder(sender.folder, inTree: )
//        showURL(sender.url, updateHistory: false)
//        updateNavButtons()
    }
    
    @IBAction func forwardHistoryMenuAction(_ sender: TuneBrowserHistoryMenuItem) {
//        showURL(sender.url)
    }
    
    @IBAction func goBackAction(_ sender: Any) {
        
//        guard let currentURL = pathControlWidget.url,
//              let newURL = history.back(from: currentURL) else {return}
//            
//        showURL(newURL, updateHistory: false)
//        updateNavButtons()
    }
    
    @IBAction func goForwardAction(_ sender: Any) {
        
//        guard let currentURL = pathControlWidget.url,
//              let newURL = history.forward(from: currentURL) else {return}
//            
//        showURL(newURL, updateHistory: false)
//        updateNavButtons()
    }
    
    @IBAction func removeSidebarShortcutAction(_ sender: Any) {
        
//        if let clickedItem: TuneBrowserSidebarItem = sidebarView.rightClickedItem as? TuneBrowserSidebarItem,
//           let removedItemIndex = tuneBrowserUIState.removeUserFolder(item: clickedItem) {
//
//            let musicFolderRow = sidebarView.row(forItem: TuneBrowserSidebarCategory.folders) + 1
//            let selectedRow = sidebarView.selectedRow
//            let selectedItemRemoved = selectedRow == (musicFolderRow + removedItemIndex + 1)
//
//            sidebarView.removeItems(at: IndexSet([removedItemIndex + 1]),
//                                    inParent: TuneBrowserSidebarCategory.folders, withAnimation: .effectFade)
//
//            if selectedItemRemoved {
//
//                let foldersRow = sidebarView.row(forItem: TuneBrowserSidebarCategory.folders)
//                let musicFolderRow = foldersRow + 1
//                sidebarView.selectRow(musicFolderRow)
//            }
//        }
    }
}

extension NSPathControl {
    
    func indexOf(item: NSPathControlItem) -> Int? {
        
        for (index, pathItem) in self.pathItems.enumerated() {
            
            if pathItem === item {
                return index
            }
        }
        
        return nil
    }
}
