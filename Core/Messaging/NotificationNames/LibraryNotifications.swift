//
//  LibraryNotifications.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import Foundation

extension Notification.Name {
    
    // MARK: Notifications published by the library.
    
    // Signifies that the library has begun adding a set of tracks.
    static let library_startedAddingTracks = Notification.Name("library_startedAddingTracks")
    
    // Signifies that the library has finished adding a set of tracks.
    static let library_doneAddingTracks = Notification.Name("library_doneAddingTracks")
    
    // Signifies that some chosen tracks could not be added to the library (i.e. an error condition).
    static let library_tracksNotAdded = Notification.Name("library_tracksNotAdded")
    
    // Signifies that new tracks have been added to the library.
    static let library_tracksAdded = Notification.Name("library_tracksAdded")
    
    static let library_tracksRemoved = Notification.Name("library_tracksRemoved")
    
    static let library_tracksDragDropped = Notification.Name("library_tracksDragDropped")
    
    static let library_sorted = Notification.Name("library_sorted")
    
    // Signifies that the summary for the library needs to be updated.
    static let library_updateSummary = Notification.Name("library_updateSummary")
    
    // Signifies that the summary for the library needs to be updated.
    static let library_reloadTable = Notification.Name("library_reloadTable")
    
    // Command to show a specific Library browser tab (specified in the payload).
    static let library_showBrowserTabForItem = Notification.Name("library_showBrowserTabForItem")
    
    // Command to show a specific Library browser tab (specified in the payload).
    static let library_showBrowserTabForCategory = Notification.Name("library_showBrowserTabForCategory")
    
    // Command to show a specific Library browser tab (specified in the payload).
    static let librarySidebar_addFileSystemShortcut = Notification.Name("librarySidebar_addFileSystemShortcut")
}
