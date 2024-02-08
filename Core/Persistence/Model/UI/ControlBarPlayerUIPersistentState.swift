//
//  ControlBarPlayerUIPersistentState.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import Foundation

#if os(iOS)
import UIKit
#endif

///
/// Persistent state for the Control Bar app mode's UI.
///
/// - SeeAlso: `ControlBarPlayerUIState`
///
struct ControlBarPlayerUIPersistentState: Codable {
    
    let windowFrame: NSRectPersistentState?
    let cornerRadius: CGFloat?
    
    let trackInfoScrollingEnabled: Bool?
    let showTrackTime: Bool?
}
