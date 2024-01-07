//
//  GroupHistoryItem.swift
//  Aural-macOS
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
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
    
    init(groupName: String, groupType: GroupType, lastEventTime: Date, eventCount: Int) {
        
        self.groupName = groupName
        self.groupType = groupType
        
        super.init(lastEventTime: lastEventTime, eventCount: eventCount)
    }
    
    override func equals(other: HistoryItem) -> Bool {
        
        guard let otherGroup = other as? GroupHistoryItem else {return false}
        return self.groupType == otherGroup.groupType && self.groupName == otherGroup.groupName
    }
}
