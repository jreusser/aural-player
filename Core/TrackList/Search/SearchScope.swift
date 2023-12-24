//
//  SearchScope.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import Foundation

struct SearchScope: OptionSet {
    
    let rawValue: Int
    
    static let playQueue = SearchScope(rawValue: 1 << 0)
    static let library = SearchScope(rawValue: 1 << 1)
    static let fileSystem = SearchScope(rawValue: 1 << 2)
    
    static let all: SearchScope = [playQueue, library, fileSystem]
}
