//
//  LibraryPersistentState.swift
//  Aural
//
//  Copyright © 2023 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import Foundation

struct LibraryPersistentState: Codable {
    
    let homeFolder: URL?
    
    // TODO: Sort order, custom groupings, etc
}
