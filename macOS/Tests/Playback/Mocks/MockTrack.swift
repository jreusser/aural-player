//
//  MockTrack.swift
//  Aural
//
//  Copyright © 2023 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Foundation

class MockTrack: Track {
    
    init(_ file: URL) {
        super.init(file)
    }
}

extension Track: CustomStringConvertible {
    
    var description: String {
        self.displayName
    }
}
