//
//  TrackListSort.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import Foundation

struct TrackListSort {
    
    let fields: [SortField]
    let order: SortOrder
    let comparator: TrackComparator
    
    init(fields: [SortField], order: SortOrder) {
        
        self.fields = fields
        self.order = order
        
        let comparisons = fields.map {$0.comparison}
        var compositeFunction: TrackComparison = comparisons[0]
        
        if comparisons.count > 1 {
            
            for index in 1..<comparisons.count {
                compositeFunction = chainTrackComparisons(compositeFunction, comparisons[index])
            }
        }
        
        self.comparator = {t1, t2 in
            compositeFunction(t1, t2) == (order == .ascending ? .orderedAscending : .orderedDescending)
        }
    }
}

///
/// Specifies the order in which to perform a sort.
///
enum SortOrder {
    
    case ascending
    case descending
}
