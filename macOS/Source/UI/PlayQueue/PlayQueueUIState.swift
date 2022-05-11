//
//  PlayQueueUIState.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import Foundation

class PlayQueueUIState: PersistentModelObject {
    
    // The current play queue view type displayed within the tab group.
    var currentView: PlayQueueView
    
    init(persistentState: PlayQueueUIPersistentState?) {
        currentView = persistentState?.currentView ?? PlayQueueUIDefaults.currentView
    }
    
    var persistentState: PlayQueueUIPersistentState {
        PlayQueueUIPersistentState(currentView: currentView)
    }
}

enum PlayQueueView: Int, Codable {
    
    case tableView
    case listView
}

struct PlayQueueUIDefaults {
    
    static let currentView: PlayQueueView = .tableView
}
