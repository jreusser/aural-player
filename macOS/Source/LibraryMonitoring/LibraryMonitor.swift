//
//  LibraryMonitor.swift
//  Aural
//
//  Created by Kartik Venugopal on 12/01/2024.
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
//

import Foundation

class LibraryMonitor {
    
    var folderMonitors: [FolderMonitor]
    
    init() {
        
        let folders = appPersistentState.library?.sourceFolders ?? []
        self.folderMonitors = folders.map {FolderMonitor(url: $0)}
    }
    
    func startMonitoring() {
        folderMonitors.forEach {$0.startMonitoring()}
    }
    
    func stopMonitoring() {
        folderMonitors.forEach {$0.stopMonitoring()}
    }
}
