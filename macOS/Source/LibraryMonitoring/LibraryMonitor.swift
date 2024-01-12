//
//  LibraryMonitor.swift
//  Aural
//
//  Created by Kartik Venugopal on 12/01/2024.
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
//

import Foundation

class LibraryMonitor {
    
    var folderMonitors: [FolderMonitor] = []
    
    init(folderMonitors: [FolderMonitor]) {
        self.folderMonitors = folderMonitors
    }
}
