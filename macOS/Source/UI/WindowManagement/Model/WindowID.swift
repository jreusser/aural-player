//
//  WindowID.swift
//  Aural-macOS
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import Cocoa

enum WindowID: String, CaseIterable, Codable {
    
    case main, playQueue, effects, chaptersList, library, playlists, visualizer, fileBrowser, trackInfo
}
