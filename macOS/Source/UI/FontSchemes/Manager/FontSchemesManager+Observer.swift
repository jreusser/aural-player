//
//  FontSchemesManager+Observer.swift
//  Aural-macOS
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import Foundation

protocol FontSchemeObserver {
    
    func fontChanged(to newFont: PlatformFont)
}

extension FontSchemesManager {
    
    
}
