//
//  PlaylistProtocol.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Foundation

///
/// A functional contract for all read-only and mutating/write playlist operations.
///
protocol PlaylistProtocol: TrackListProtocol {
    
    var name: String {get set}
}
