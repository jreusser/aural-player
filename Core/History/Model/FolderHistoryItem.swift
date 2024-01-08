//
//  FolderHistoryItem.swift
//  Aural-macOS
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import Foundation

class FolderHistoryItem: HistoryItem {
    
    let folder: URL
    
    override var displayName: String {
        folder.lastPathComponents(count: 2)
    }
    
    override var key: String {
        folder.path
    }
    
    init(folder: URL, lastEventTime: Date, eventCount: Int = 1) {
        
        self.folder = folder
        super.init(lastEventTime: lastEventTime, eventCount: eventCount)
    }
    
    override func equals(other: HistoryItem) -> Bool {
        
        guard let otherFolder = other as? FolderHistoryItem else {return false}
        return self.folder == otherFolder.folder
    }
}
