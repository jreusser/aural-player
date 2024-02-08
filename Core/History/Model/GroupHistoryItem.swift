//
//  GroupHistoryItem.swift
//  Aural-macOS
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import Foundation

class GroupHistoryItem: HistoryItem {
    
    let groupName: String
    let groupType: GroupType
    
    override var displayName: String {
        groupName
    }
    
    override var key: String {
        "\(groupType.rawValue)_\(groupName)"
    }
    
    init(groupName: String, groupType: GroupType, lastEventTime: Date, eventCount: Int = 1) {
        
        self.groupName = groupName
        self.groupType = groupType
        
        super.init(lastEventTime: lastEventTime, eventCount: eventCount)
    }
}
