//
//  TuneBrowserTabViewController+DataSource.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import Cocoa

extension TuneBrowserTabViewController: NSOutlineViewDataSource {
    
    func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
        
        guard !resetBrowserView else {return 0}
        
        if item == nil {
            
            return fileSystem.root.children.count
            
        } else if let fsItem = item as? FileSystemItem {
            
            return fsItem.children.count
        }
        
        return 0
    }
    
    func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
        
        guard !resetBrowserView else {return ""}
        
        if item == nil {
            
            return fileSystem.root.children.elements[index].value
            
        } else if let fsItem = item as? FileSystemItem {
            
            return fsItem.children.elements[index].value
        }
        
        return ""
    }
    
    // MARK: Drag and drop
    
    // Writes source information to the pasteboard
    func outlineView(_ outlineView: NSOutlineView, writeItems items: [Any], to pasteboard: NSPasteboard) -> Bool {
        
        let fsItems = items.compactMap {$0 as? FileSystemItem}
        TableDragDropContext.setData(fsItems, from: browserView, pasteboard: pasteboard)
        
        return true
    }
    
    /// Cannot drop into the Tune Browser.
    func outlineView(_ outlineView: NSOutlineView, validateDrop info: NSDraggingInfo, proposedItem item: Any?, proposedChildIndex index: Int) -> NSDragOperation {
        .invalidDragOperation
    }
    
    /// Cannot drop into the Tune Browser.
    func outlineView(_ outlineView: NSOutlineView, acceptDrop info: NSDraggingInfo, item: Any?, childIndex index: Int) -> Bool {
        
        TableDragDropContext.reset()
        return false
    }
}
