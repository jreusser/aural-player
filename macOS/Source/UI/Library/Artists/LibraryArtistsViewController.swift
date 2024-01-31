//
//  LibraryArtistsViewController.swift
//  Aural
//
//  Copyright © 2023 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import Cocoa

class LibraryArtistsViewController: TrackListOutlineViewController {
    
    override var nibName: String? {"LibraryArtists"}
    
    @IBOutlet weak var rootContainer: NSBox!
    @IBOutlet weak var lblCaption: NSTextField!
    
    @IBOutlet weak var lblArtistsSummary: NSTextField!
    @IBOutlet weak var lblDurationSummary: NSTextField!
    
    private lazy var artistsGrouping: ArtistsGrouping = library.artistsGrouping
    override var grouping: Grouping! {artistsGrouping}
    
    override var trackList: GroupedSortedTrackListProtocol! {
        libraryDelegate
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        messenger.subscribeAsync(to: .library_tracksAdded, handler: tracksAdded(_:))
        messenger.subscribeAsync(to: .library_tracksRemoved, handler: reloadTable)
        
        messenger.subscribeAsync(to: .library_doneAddingTracks, handler: doneAddingTracks)
        
        messenger.subscribe(to: .library_reloadTable, handler: reloadTable)
        messenger.subscribe(to: .library_updateSummary, handler: updateSummary)
        
        colorSchemesManager.registerSchemeObserver(self)
        colorSchemesManager.registerPropertyObserver(self, forProperty: \.backgroundColor, handler: backgroundColorChanged(_:))
        colorSchemesManager.registerPropertyObserver(self, forProperty: \.captionTextColor, changeReceiver: lblCaption)
        
        colorSchemesManager.registerPropertyObserver(self, forProperties: [\.primaryTextColor, \.secondaryTextColor, \.tertiaryTextColor], handler: tableTextColorChanged(_:))
        colorSchemesManager.registerPropertyObserver(self, forProperty: \.secondaryTextColor, changeReceivers: [lblArtistsSummary, lblDurationSummary])
        colorSchemesManager.registerPropertyObserver(self, forProperties: [\.primarySelectedTextColor, \.secondarySelectedTextColor, \.tertiarySelectedTextColor], handler: tableSelectedTextColorChanged(_:))
        colorSchemesManager.registerPropertyObserver(self, forProperty: \.textSelectionColor, handler: textSelectionColorChanged(_:))
        
//        fontSchemesManager.registerObserver(lblCaption, forProperty: \.captionFont)
//        fontSchemesManager.registerObservers([lblArtistsSummary, lblDurationSummary], forProperty: \.playQueueSecondaryFont)
        
        updateSummary()
    }
    
    func doneAddingTracks() {
        
        outlineView.reloadData()
        updateSummary()
    }
    
    override func outlineView(_ outlineView: NSOutlineView, heightOfRowByItem item: Any) -> CGFloat {
        item is Group ? 60 : 30
    }
    
    func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {
        
        guard let columnId = tableColumn?.identifier else {return nil}
        
        switch columnId {
            
        case .cid_Name:
            
            if let track = item as? Track,
               let cell = outlineView.makeView(withIdentifier: .cid_TrackName, owner: nil) as? AlbumTrackCellView {
                
                cell.update(forTrack: track)
                cell.rowSelectionStateFunction = {[weak outlineView, weak track] in outlineView?.isItemSelected(track as Any) ?? false}
                
                return cell
            }
            
            if let artist = item as? ArtistGroup,
               let cell = outlineView.makeView(withIdentifier: .cid_ArtistName, owner: nil) as? ArtistCellView {
                
                cell.update(forGroup: artist)
                cell.rowSelectionStateFunction = {[weak outlineView, weak artist] in outlineView?.isItemSelected(artist as Any) ?? false}
                
                return cell
            }
            
            if let album = item as? AlbumGroup,
               let cell = outlineView.makeView(withIdentifier: .cid_AlbumName, owner: nil) as? ArtistAlbumCellView {
                
                cell.update(forGroup: album)
                cell.rowSelectionStateFunction = {[weak outlineView, weak album] in outlineView?.isItemSelected(album as Any) ?? false}
                
                return cell
            }
            
            if let disc = item as? AlbumDiscGroup {
                
                return TableCellBuilder().withText(text: disc.name,
                                                   inFont: systemFontScheme.playerPrimaryFont,
                                                   andColor: systemColorScheme.secondaryTextColor,
                                                   selectedTextColor: systemColorScheme.secondarySelectedTextColor,
                                                   centerYOffset: systemFontScheme.playQueueYOffset)
                    .buildCell(forOutlineView: outlineView,
                               forColumnWithId: .cid_DiscName, havingItem: disc)
            }
            
        case .cid_Duration:
            
            if let track = item as? Track {
                
                return TableCellBuilder().withText(text: ValueFormatter.formatSecondsToHMS(track.duration),
                                                   inFont: systemFontScheme.playQueuePrimaryFont,
                                                   andColor: systemColorScheme.tertiaryTextColor,
                                                   selectedTextColor: systemColorScheme.tertiarySelectedTextColor,
                                                   centerYOffset: systemFontScheme.playQueueYOffset)
                    .buildCell(forOutlineView: outlineView,
                               forColumnWithId: .cid_TrackDuration, havingItem: track)
            }
            
            if let artist = item as? ArtistGroup,
               let cell = outlineView.makeView(withIdentifier: .cid_ArtistDuration, owner: nil) as? GroupSummaryCellView {
                
                cell.update(forArtistGroup: artist)
                cell.rowSelectionStateFunction = {[weak outlineView, weak artist] in outlineView?.isItemSelected(artist as Any) ?? false}
                
                return cell
            }
            
            if let album = item as? AlbumGroup,
               let cell = outlineView.makeView(withIdentifier: .cid_AlbumDuration, owner: nil) as? GroupSummaryCellView {
                
                cell.update(forAlbumGroup: album)
                cell.rowSelectionStateFunction = {[weak outlineView, weak album] in outlineView?.isItemSelected(album as Any) ?? false}
                
                return cell
            }
            
            if let disc = item as? AlbumDiscGroup,
               let cell = outlineView.makeView(withIdentifier: .cid_DiscDuration, owner: nil) as? GroupSummaryCellView {
                
                cell.update(forGroup: disc)
                cell.rowSelectionStateFunction = {[weak outlineView, weak disc] in outlineView?.isItemSelected(disc as Any) ?? false}
                
                return cell
            }
            
        default:
            
            return nil
        }
        
        return nil
    }
    
    override func updateSummary() {
        
        let numGroups = artistsGrouping.numberOfGroups
        let numTracks = library.size
        
        lblArtistsSummary.stringValue = "\(numGroups) \(numGroups == 1 ? "artist" : "artists"), \(numTracks) \(numTracks == 1 ? "track" : "tracks")"
        lblDurationSummary.stringValue = ValueFormatter.formatSecondsToHMS(library.duration)
    }
}

extension LibraryArtistsViewController: ColorSchemeObserver {
    
    func colorSchemeChanged() {
        
        backgroundColorChanged(systemColorScheme.backgroundColor)
        lblCaption.textColor = systemColorScheme.captionTextColor
        
        lblArtistsSummary.textColor = systemColorScheme.secondaryTextColor
        lblDurationSummary.textColor = systemColorScheme.secondaryTextColor
        
        outlineView.reloadDataMaintainingSelection()
    }
    
    private func backgroundColorChanged(_ newColor: PlatformColor) {
        
        rootContainer.fillColor = newColor
        outlineView.setBackgroundColor(newColor)
    }
    
    private func tableTextColorChanged(_ newColor: PlatformColor) {
        outlineView.reloadDataMaintainingSelection()
    }
    
    private func tableSelectedTextColorChanged(_ newColor: PlatformColor) {
        outlineView.reloadRows(selectedRows)
    }
    
    private func textSelectionColorChanged(_ newColor: PlatformColor) {
        outlineView.redoRowSelection()
    }
}

class ArtistCellView: AuralTableCellView {
    
    func update(forGroup group: ArtistGroup) {
        
        text = group.name
        image = .imgArtistGroup
        image?.isTemplate = true
        imageColor = systemColorScheme.buttonColor
        
        textFont = systemFontScheme.playerPrimaryFont
        textColor = systemColorScheme.primaryTextColor
    }
}

class ArtistAlbumCellView: AuralTableCellView {
    
    func update(forGroup group: AlbumGroup) {
        
        var string = group.name.attributed(font: systemFontScheme.playerPrimaryFont, color: systemColorScheme.primaryTextColor, lineSpacing: 5)
        
        var hasGenre: Bool = false
        
        if let genres = group.genresString {
            
            string = string + "\n\(genres)".attributed(font: systemFontScheme.playerSecondaryFont, color: systemColorScheme.tertiaryTextColor)
            hasGenre = true
        }
        
        if let year = group.yearString {
            
            let padding = hasGenre ? "  " : ""
            string = string + "\(padding)[\(year)]".attributed(font: systemFontScheme.playerSecondaryFont, color: systemColorScheme.tertiaryTextColor, lineSpacing: 3)
        }
        
        textField?.attributedStringValue = string
        image = group.art
    }
}

extension GroupSummaryCellView {
    
    func update(forArtistGroup group: ArtistGroup, showAlbumsCount: Bool = true) {
        
        let trackCount = group.numberOfTracks
        let albumCount = group.numberOfSubGroups
        
        if showAlbumsCount {
            lblTrackCount.stringValue = "\(albumCount) \(albumCount == 1 ? "album" : "albums"), \(trackCount) \(trackCount == 1 ? "track" : "tracks")"
        } else {
            lblTrackCount.stringValue = "\(trackCount) \(trackCount == 1 ? "track" : "tracks")"
        }
        
        lblDuration.stringValue = ValueFormatter.formatSecondsToHMS(group.duration)
        
        lblTrackCount.font = summaryFont
        lblDuration.font = summaryFont
        
        lblTrackCount.textColor = systemColorScheme.secondaryTextColor
        lblDuration.textColor = systemColorScheme.secondaryTextColor
    }
}

extension NSUserInterfaceItemIdentifier {
    
    // Outline view column identifiers
    static let cid_ArtistName: NSUserInterfaceItemIdentifier = NSUserInterfaceItemIdentifier("cid_ArtistName")
    static let cid_ArtistDuration: NSUserInterfaceItemIdentifier = NSUserInterfaceItemIdentifier("cid_ArtistDuration")
}
