//
//  MenuBarPVC.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import AppKit

class MenuBarPVC: CommonPlayerViewController {
    
    override var nibName: NSNib.Name? {"MenuBarPlayer"}
    
    override func updateTrackTextView(for track: Track?, playingChapterTitle: String? = nil) {
        updateMultilineTrackTextView(for: track, playingChapterTitle: playingChapterTitle)
    }
    
    override var multilineTrackTextTitleFont: NSFont {
        systemFontScheme.normalFont
    }
    
    override var multilineTrackTextArtistAlbumFont: NSFont {
        systemFontScheme.smallFont
    }
    
    override func updateTrackTextViewFonts() {
        updateMultilineTrackTextViewFonts()
    }
    
    override func updateTrackTextViewColors() {
        updateMultilineTrackTextViewColors()
    }
}
