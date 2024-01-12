//
//  TuneBrowserNotifications.swift
//  Aural
//
//  Copyright © 2023 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  
import Foundation

///
/// Notifications pertaining to the **Tune Browser**.
///
extension Notification.Name {
    
    static let fileSystem_fileMetadataLoaded = Notification.Name("fileSystem_fileMetadataLoaded")
    
    static let fileSystem_childrenAddedToItem = Notification.Name("fileSystem_childrenAddedToItem")
    
    static let tuneBrowser_sidebarSelectionChanged = Notification.Name("tuneBrowser_sidebarSelectionChanged")
    
    static let tuneBrowser_notePreviousLocation = Notification.Name("tuneBrowser_notePreviousLocation")
    
    static let tuneBrowser_fileAdded = Notification.Name("tuneBrowser_fileAdded")
    static let tuneBrowser_fileDeleted = Notification.Name("tuneBrowser_fileDeleted")
}
