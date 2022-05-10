////
////  PlayQueueTrackTextView.swift
////  Aural
////
////  Copyright © 2021 Kartik Venugopal. All rights reserved.
////
////  This software is licensed under the MIT software license.
////  See the file "LICENSE" in the project root directory for license terms.
////  
//
//import Cocoa
//
///*
//    A rich text field that displays nicely formatted info about the currently playing track in the player window.
//    Dynamically updates itself based on view settings to show either a single line or multiple
//    lines of information.
// */
//class PlayQueueTrackTextView: NSTextView, FontSchemeObserver, ColorSchemeObserver {
//    
////    private lazy var uiState: PlayerUIState = playerUIState
//    
//    init() {
//            super.init(frame: NSRect.zero)
//        }
//
//        /*
//         It is not possible to set up a lone NSTextView in Interface Builder, however you can set it up
//         as a CustomView if you are happy to have all your presentation properties initialised
//         programatically. This initialises an NSTextView as it would be with the default init...
//         */
//        required init(coder: NSCoder) {
//            
//            super.init(coder: coder)!
//
//            let textStorage = NSTextStorage()
//            let layoutManager = NSLayoutManager()
//            textStorage.addLayoutManager(layoutManager)
//
//            // By default, NSTextContainers do not track the bounds of the NSTextview
//            let textContainer = NSTextContainer(containerSize: CGSize.zero)
//            textContainer.widthTracksTextView = true
//            textContainer.heightTracksTextView = true
//
//            layoutManager.addTextContainer(textContainer)
//            replaceTextContainer(textContainer)
//            
//            self.isEditable = false
//            self.isSelectable = false
//            self.drawsBackground = false
//        }
//
//    
//    var trackInfo: PlayingTrackInfo? {
//        
//        didSet {
//            update()
//        }
//    }
//    
//    var titleFont: NSFont {
//        systemFontScheme.playlist.trackTextFont
//    }
//    
//    var titleColor: NSColor {
//        isSelected ? systemColorScheme.primarySelectedTextColor : systemColorScheme.primarySelectedTextColor
//    }
//    
//    var artistAlbumFont: NSFont {
//        systemFontScheme.playlist.trackTextFont
//    }
//    
//    var artistAlbumColor: NSColor {
//        isSelected ? systemColorScheme.secondarySelectedTextColor : systemColorScheme.secondarySelectedTextColor
//    }
//    
//    var shouldShowArtist: Bool {
////        uiState.showArtist
//        true
//    }
//    
//    var shouldShowAlbum: Bool {
////        uiState.showAlbum
//        true
//    }
//    
//    var isSelected: Bool = false {
//        
//        didSet {
//            
//            backgroundColor = isSelected ? systemColorScheme.textSelectionColor : systemColorScheme.backgroundColor
//            update()
//        }
//    }
//    
//    // The displayed track title
//    private var title: String? {
//        trackInfo?.title
//    }
//    
//    // The displayed track artist (displayed only if user setting allows it)
//    private var artist: String? {
//        shouldShowArtist ? trackInfo?.artist : nil
//    }
//    
//    // The displayed track album (displayed only if user setting allows it)
//    private var album: String? {
//        shouldShowAlbum ? trackInfo?.album : nil
//    }
//    
//    // Represents the maximum width allowed for one line of text displayed in the text view,
//    // to assist with truncation of title/artist/album/chapter strings,
//    // with some padding to allow for slight discrepancies when truncating
//    private var lineWidth: CGFloat {
//        self.width - 10
//    }
//    
//    func resized() {
//        update()
//    }
//    
//    // Constructs the formatted "rich" text to be displayed in the text view
//    func update(file: String = #file, line: Int = #line, function: String = #function) {
//        
//        let lineWidth = self.lineWidth
//        
//        // First, clear the view to remove any old text
//        self.string = ""
//        
//        // Check if there is any track info
//        guard let title = self.title else {return}
//            
//        var truncatedArtistAlbumStr: String? = nil
//        var fullLengthArtistAlbumStr: String? = nil
//        
//        // Construct a formatted and truncated artist/album string
//        
//        if let theArtist = artist, let theAlbum = album {
//            
//            fullLengthArtistAlbumStr = String(format: "%@ -- %@", theArtist, theAlbum)
//            truncatedArtistAlbumStr = String.truncateCompositeString(artistAlbumFont, lineWidth, fullLengthArtistAlbumStr!, theArtist, theAlbum, " -- ")
//            
//        } else if let theArtist = artist {
//            
//            truncatedArtistAlbumStr = theArtist.truncate(font: artistAlbumFont, maxWidth: lineWidth)
//            fullLengthArtistAlbumStr = theArtist
//            
//        } else if let theAlbum = album {
//            
//            truncatedArtistAlbumStr = theAlbum.truncate(font: artistAlbumFont, maxWidth: lineWidth)
//            fullLengthArtistAlbumStr = theAlbum
//        }
//        
//        let hasArtistAlbum: Bool = truncatedArtistAlbumStr != nil
//        
//        // Title (truncate only if artist, album, or chapter are displayed)
//        let truncatedTitle: String = hasArtistAlbum ? title.truncate(font: titleFont, maxWidth: lineWidth) : title
//        
//        self.textStorage?.append(attributedString(truncatedTitle, titleFont, titleColor, hasArtistAlbum ? 8 : nil))
//        
//        // Artist / Album
//        if let _truncatedArtistAlbumStr = truncatedArtistAlbumStr {
////            self.textStorage?.append(attributedString(_truncatedArtistAlbumStr, artistAlbumFont, artistAlbumColor, hasChapter ? lineSpacingBetweenArtistAlbumAndChapterTitle : nil))
//            self.textStorage?.append(attributedString(_truncatedArtistAlbumStr, artistAlbumFont, artistAlbumColor, nil))
//        }
//        
//        // Construct a tool tip with full length text (helpful when displayed fields are truncated because of length)
//        self.toolTip = String(format: "%@%@", title, fullLengthArtistAlbumStr != nil ? "\n\n" + fullLengthArtistAlbumStr! : "")
//        
//        // Center-align the text
//        centerAlign()
//    }
//    
//    // Center-aligns the text within the text view and the text view within the clip view.
//    private func centerAlign() {
//        
//        // Vertical alignment
//        self.layoutManager?.ensureLayout(for: self.textContainer!)
//        
//        guard let txtHeight = self.layoutManager?.usedRect(for: self.textContainer!).height else {return}
//        
//        // If this isn't done, the text view frame occupies the whole ScrollView, and the text
//        // is not vertically aligned on older systems (Sierra / HighSierra)
//        self.resize(self.width, txtHeight + 10)
//        
////        // Move the text view down from the top, by adjusting the top insets of the clip view.
////        let heightDifference = self.height - txtHeight
////        clipView.contentInsets.top = heightDifference / 2
//    }
//    
//    /*
//        Helper factory function to construct an NSAttributedString (i.e. "rich text"), given all its attributes.
//     
//        @param lineSpacing (optional)
//                Amout of spacing between this line of text and the next line. Nil value indicates no spacing.
//                Non-nil value will result in a line break being added to the text (to separate lines).
//     */
//    private func attributedString(_ text: String, _ font: NSFont, _ color: NSColor, _ lineSpacing: CGFloat? = nil) -> NSAttributedString {
//        
//        var attributes: [NSAttributedString.Key: Any] = [.font: font, .foregroundColor: color]
//        
//        var str: String = text
//        
//        if let spacing = lineSpacing {
//            
//            // If lineSpacing is specified, add a paragraph style attribute and set its lineSpacing field.
//            attributes[.paragraphStyle] = NSMutableParagraphStyle(lineSpacing: spacing)
//            
//            // Add a newline character to the text to create a line break
//            str += "\n"
//        }
//        
//        return NSAttributedString(string: str, attributes: attributes)
//    }
//    
//    // ------------------------------------------------------------------------------------------------------
//    
//    // MARK: Appearance observer functions
//    
//    func fontChanged(to newFont: PlatformFont, forProperty property: KeyPath<FontScheme, PlatformFont>) {
//        update()
//    }
//    
//    func fontSchemeChanged() {
//        update()
//    }
//    
//    func colorChanged(to newColor: PlatformColor, forProperty property: KeyPath<ColorScheme, PlatformColor>) {
//        
//        if property == \.backgroundColor {
//            backgroundColor = newColor
//            
//        } else {
//            update()
//        }
//    }
//    
//    func colorSchemeChanged() {
//        
//        backgroundColor = systemColorScheme.backgroundColor
//        update()
//    }
//}
