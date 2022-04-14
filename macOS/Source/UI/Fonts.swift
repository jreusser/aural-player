//
//  Fonts.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

/*
 Container for fonts used by the UI
 */
struct Fonts {
    
    struct Player {
        
        static var infoBoxTitleFont: NSFont {systemFontScheme.player.infoBoxTitleFont}
        static var infoBoxArtistAlbumFont: NSFont {systemFontScheme.player.infoBoxArtistAlbumFont}
        static var infoBoxChapterTitleFont: NSFont {systemFontScheme.player.infoBoxChapterTitleFont}
    }
    
    struct Playlist {
        
        static var trackTextFont: NSFont {systemFontScheme.playlist.trackTextFont}
        
        static var groupTextFont: NSFont {systemFontScheme.playlist.groupTextFont}
        
        static var tabButtonTextFont: NSFont {systemFontScheme.playlist.tabButtonTextFont}
        
        static var chaptersListHeaderFont: NSFont {systemFontScheme.playlist.chaptersListHeaderFont}
    }
    
    struct Effects {
        
        static var unitFunctionFont: NSFont {systemFontScheme.effects.unitFunctionFont}
    }
}
