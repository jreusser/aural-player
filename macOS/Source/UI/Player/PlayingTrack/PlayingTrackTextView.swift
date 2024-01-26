//
//  PlayingTrackTextView.swift
//  Aural
//
//  Copyright © 2023 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

/*
    A rich text field that displays nicely formatted info about the currently playing track in the player window.
    Dynamically updates itself based on view settings to show either a single line or multiple
    lines of information.
 */
class PlayingTrackTextView: NSView, FontSchemeObserver {
    
    // The text view that displays all the track info
    @IBOutlet weak var textView: NSTextView!
    
    // The clip view that contains the text view (used to center-align the text view vertically)
    @IBOutlet weak var clipView: NSClipView!
    
    private lazy var uiState: PlayerUIState = playerUIState
    
    var trackInfo: PlayingTrackInfo? {
        
        didSet {
            update()
        }
    }
    
    var backgroundColor: NSColor {
        
        get {
            clipView.backgroundColor
        }
        
        set(newColor) {
            
            clipView.backgroundColor = newColor
            clipView.enclosingScrollView?.backgroundColor = newColor
            textView.backgroundColor = newColor
        }
    }
    
    var titleFont: NSFont {
        systemFontScheme.playerPrimaryFont
    }
    
    var titleColor: NSColor {
        systemColorScheme.primaryTextColor
    }
    
    var artistAlbumFont: NSFont {
        systemFontScheme.playerSecondaryFont
    }
    
    var artistAlbumColor: NSColor {
        systemColorScheme.secondaryTextColor
    }
    
    var chapterTitleFont: NSFont {
        systemFontScheme.playerTertiaryFont
    }
    
    var chapterTitleColor: NSColor {
        systemColorScheme.tertiaryTextColor
    }
    
    var shouldShowArtist: Bool {
        uiState.showArtist
    }
    
    var shouldShowAlbum: Bool {
        uiState.showAlbum
    }
    
    var shouldShowChapterTitle: Bool {
        uiState.showCurrentChapter
    }
    
    var lineSpacingBetweenArtistAlbumAndChapterTitle: CGFloat {7}
    
    var horizontalAlignment: NSTextAlignment? {
        nil
    }
    
    // The displayed track title
    private var title: String? {
        trackInfo?.title
    }
    
    // The displayed track artist (displayed only if user setting allows it)
    private var artist: String? {
        shouldShowArtist ? trackInfo?.artist : nil
    }
    
    // The displayed track album (displayed only if user setting allows it)
    private var album: String? {
        shouldShowAlbum ? trackInfo?.album : nil
    }
    
    private var chapterTitle: String? {
        shouldShowChapterTitle ? trackInfo?.playingChapterTitle : nil
    }
    
    // Represents the maximum width allowed for one line of text displayed in the text view
    private var lineWidth: CGFloat = 300
    
    override func awakeFromNib() {

        // Set the line width to assist with truncation of title/artist/album/chapter strings,
        // with some padding to allow for slight discrepancies when truncating
        lineWidth = (textView?.width ?? 300) - 10
    }
    
    func resized() {
        
        // Set the line width to assist with truncation of title/artist/album/chapter strings,
        // with some padding to allow for slight discrepancies when truncating
        lineWidth = (textView?.width ?? 300) - 10
        
        update()
    }
    
    // Updates the view when the user settings that control display of metadata fields have changed
    func displayedTextChanged() {
        update()
    }
    
    // Constructs the formatted "rich" text to be displayed in the text view
    func update(file: String = #file, line: Int = #line, function: String = #function) {
        
        // First, clear the view to remove any old text
        textView.string = ""
        
        // Check if there is any track info
        guard let title = self.title else {return}
            
        var truncatedArtistAlbumStr: String? = nil
        var fullLengthArtistAlbumStr: String? = nil
        
        // Construct a formatted and truncated artist/album string
        
        if let theArtist = artist, let theAlbum = album {
            
            fullLengthArtistAlbumStr = String(format: "%@ -- %@", theArtist, theAlbum)
            truncatedArtistAlbumStr = String.truncateCompositeString(artistAlbumFont, lineWidth, fullLengthArtistAlbumStr!, theArtist, theAlbum, " -- ")
            
        } else if let theArtist = artist {
            
            truncatedArtistAlbumStr = theArtist.truncate(font: artistAlbumFont, maxWidth: lineWidth)
            fullLengthArtistAlbumStr = theArtist
            
        } else if let theAlbum = album {
            
            truncatedArtistAlbumStr = theAlbum.truncate(font: artistAlbumFont, maxWidth: lineWidth)
            fullLengthArtistAlbumStr = theAlbum
        }
        
        let hasArtistAlbum: Bool = truncatedArtistAlbumStr != nil
        
        let chapterStr = chapterTitle
        let hasChapter: Bool = chapterStr != nil
        
        // Title (truncate only if artist, album, or chapter are displayed)
        let truncatedTitle: String = hasArtistAlbum || hasChapter ? title.truncate(font: titleFont, maxWidth: lineWidth) : title
        
        textView.textStorage?.append(attributedString(truncatedTitle, titleFont, titleColor, hasArtistAlbum ? (hasChapter ? 5 : 8) : (hasChapter ? 5 : nil)))
        
        // Artist / Album
        if let _truncatedArtistAlbumStr = truncatedArtistAlbumStr {
//            textView.textStorage?.append(attributedString(_truncatedArtistAlbumStr, artistAlbumFont, artistAlbumColor, hasChapter ? lineSpacingBetweenArtistAlbumAndChapterTitle : nil))
            textView.textStorage?.append(attributedString(_truncatedArtistAlbumStr, artistAlbumFont, artistAlbumColor, hasChapter ? 5 : nil))
        }
        
        // Chapter
        if let _chapterStr = chapterStr {
            
            let truncatedChapter: String = _chapterStr.truncate(font: chapterTitleFont, maxWidth: lineWidth)
            textView.textStorage?.append(attributedString(truncatedChapter, chapterTitleFont, chapterTitleColor))
        }
        
        // Construct a tool tip with full length text (helpful when displayed fields are truncated because of length)
        textView.toolTip = String(format: "%@%@%@", title, fullLengthArtistAlbumStr != nil ? "\n\n" + fullLengthArtistAlbumStr! : "", chapterStr != nil ? "\n\n" + chapterStr! : "")
        
        // Center-align the text
        centerAlign()
    }
    
    // Center-aligns the text within the text view and the text view within the clip view.
    private func centerAlign() {
        
        // Horizontal alignment
//        textView.setAlignment(.center, range: .init(location: 0, length: textView.string.count))
        
        // Vertical alignment
        textView.layoutManager?.ensureLayout(for: textView.textContainer!)

        if let txtHeight = textView.layoutManager?.usedRect(for: textView.textContainer!).height {

            // If this isn't done, the text view frame occupies the whole ScrollView, and the text
            // is not vertically aligned on older systems (Sierra / HighSierra)
            textView.resize(textView.width, txtHeight + 10)
            
            // Move the text view down from the top, by adjusting the top insets of the clip view.
            let heightDifference = self.height - txtHeight
            clipView.contentInsets.top = heightDifference / 2
        }
    }
    
    /*
        Helper factory function to construct an NSAttributedString (i.e. "rich text"), given all its attributes.
     
        @param lineSpacing (optional)
                Amout of spacing between this line of text and the next line. Nil value indicates no spacing.
                Non-nil value will result in a line break being added to the text (to separate lines).
     */
    private func attributedString(_ text: String, _ font: NSFont, _ color: NSColor, _ lineSpacing: CGFloat? = nil) -> NSAttributedString {
        
        // TODO: Figure out how to do this flexibly and optimally
        
//        let shadow: NSShadow = NSShadow()
//        shadow.shadowColor = shadowColor
//        shadow.shadowOffset = NSSize(width: -0.5, height: -0.5)
//        shadow.shadowBlurRadius = 3
//        var attributes = [ NSAttributedString.Key.font: font, NSAttributedString.Key.foregroundColor: color, NSAttributedString.Key.shadow: shadow ]
        
        var attributes: [NSAttributedString.Key: Any] = [.font: font, .foregroundColor: color]
        let style = NSMutableParagraphStyle()
        var str: String = text
        
        if let textAlignment = self.horizontalAlignment {
            style.alignment = textAlignment
        }
        
        if let spacing = lineSpacing {
            
            // If lineSpacing is specified, add a paragraph style attribute and set its lineSpacing field.
            style.lineSpacing = spacing
            
            // Add a newline character to the text to create a line break
            str += "\n"
        }
        
        attributes[.paragraphStyle] = style
        
        return NSAttributedString(string: str, attributes: attributes)
    }
    
    // ------------------------------------------------------------------------------------------------------
    
    // MARK: Appearance observer functions
    
    func fontChanged(to newFont: PlatformFont, forProperty property: KeyPath<FontScheme, PlatformFont>) {
        update()
    }
    
    func fontSchemeChanged() {
        update()
    }
    
    func colorChanged(to newColor: PlatformColor, forProperty property: ColorSchemeProperty) {
        
        if property == \.backgroundColor {
            backgroundColor = newColor
            
        } else {
            update()
        }
    }
}

@IBDesignable
class CompactPlayingTrackTextView: PlayingTrackTextView {
    
    @IBOutlet weak var backingBox: NSBox!
    
    override var backgroundColor: NSColor {
        
        get {
            backingBox.fillColor.clonedWithTransparency(1)
        }
        
        set(newColor) {
            
            let semiTransparentColor = newColor.clonedWithTransparency(0.9)
            backingBox.fillColor = semiTransparentColor
            
//            clipView.enclosingScrollView?.backgroundColor = semiTransparentColor
//            clipView.backgroundColor = semiTransparentColor
//            textView.backgroundColor = semiTransparentColor
        }
    }
    
    override var horizontalAlignment: NSTextAlignment? {
        .center
    }
}

class MenuBarPlayingTrackTextView: PlayingTrackTextView {
    
    private lazy var uiState: MenuBarPlayerUIState = menuBarPlayerUIState
    
    override var titleFont: NSFont {
        standardFontSet.mainFont(size: 13)
    }
    
    override var artistAlbumFont: NSFont {
        standardFontSet.mainFont(size: 11)
    }
    
    override var chapterTitleFont: NSFont {
        standardFontSet.mainFont(size: 10)
    }
    
    override var titleColor: NSColor {
        .white
    }

    override var artistAlbumColor: NSColor {
        .white70Percent
    }

    override var chapterTitleColor: NSColor {
        .white70Percent
    }
    
    override var shouldShowArtist: Bool {
        uiState.showArtist
    }
    
    override var shouldShowAlbum: Bool {
        uiState.showAlbum
    }
    
    override var shouldShowChapterTitle: Bool {
        uiState.showCurrentChapter
    }
    
    override var lineSpacingBetweenArtistAlbumAndChapterTitle: CGFloat {4}
}

extension PlayingTrackTextView: ColorSchemePropertyChangeReceiver {
    
    func backgroundColorChanged(_ newColor: PlatformColor) {
        self.backgroundColor = systemColorScheme.backgroundColor
    }
    
    func colorChanged(_ newColor: PlatformColor) {
        update()
    }
}
