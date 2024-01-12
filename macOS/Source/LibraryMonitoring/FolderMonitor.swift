//
//  FolderMonitor.swift
//  Aural
//
//  Copyright © 2023 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import Foundation

///
/// Source: https://medium.com/over-engineering/monitoring-a-folder-for-changes-in-ios-dc3f8614f902
///
class FolderMonitor {
    
    // MARK: Properties
    
    /// URL for the directory being monitored.
    let url: URL
    
    // MARK: Initializers
    
    init(url: URL) {
        self.url = url
    }
    
    // MARK: Monitoring
    
    /// Listen for changes to the directory (if we are not already).
    func startMonitoring() {

    }
    
    /// Stop listening for changes to the directory, if the source has been created.
    func stopMonitoring() {
        
    }
}
