//
//  AuxiliaryMetadata.swift
//  Aural
//
//  Copyright © 2023 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Foundation

///
/// A container for all non-essential metadata for a file / track.
///
/// This metadata will be loaded only when the user requests detailed track information.
///
struct AuxiliaryMetadata {
    
    var fileSystemInfo: FileSystemInfo?
    var audioInfo: AudioInfo?
}
