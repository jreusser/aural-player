//
//  LibraryAlbumsViewController.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import Cocoa

class LibraryAlbumsViewController: TrackListOutlineViewController {
    
    override var nibName: String? {"LibraryAlbums"}
    
    @IBOutlet weak var rootContainer: NSBox!
    @IBOutlet weak var lblCaption: NSTextField!
    
    @IBOutlet weak var lblAlbumsSummary: NSTextField!
    @IBOutlet weak var lblDurationSummary: NSTextField!
    
    private lazy var albumsGrouping: AlbumsGrouping = library.albumsGrouping
    override var grouping: Grouping! {albumsGrouping}
    
    override var trackList: GroupedSortedTrackListProtocol! {
        libraryDelegate
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        messenger.subscribeAsync(to: .library_tracksAdded, handler: tracksAdded(_:))
        messenger.subscribeAsync(to: .library_tracksRemoved, handler: reloadTable)
        
        messenger.subscribe(to: .library_reloadTable, handler: reloadTable)
        messenger.subscribe(to: .library_updateSummary, handler: updateSummary)
        
        colorSchemesManager.registerObserver(rootContainer, forProperty: \.backgroundColor)
        
        fontSchemesManager.registerObserver(lblCaption, forProperty: \.captionFont)
        colorSchemesManager.registerObserver(lblCaption, forProperty: \.captionTextColor)
        
        fontSchemesManager.registerObservers([lblAlbumsSummary, lblDurationSummary], forProperty: \.playQueueSecondaryFont)
        colorSchemesManager.registerObservers([lblAlbumsSummary, lblDurationSummary], forProperty: \.secondaryTextColor)
        
        updateSummary()
    }
    
    override func outlineView(_ outlineView: NSOutlineView, heightOfRowByItem item: Any) -> CGFloat {
        
        if item is AlbumGroup {
            return 90
        }
        
        if item is AlbumDiscGroup {
            return 60
        }
        
        return 30
    }
    
    func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
        
        if item == nil {
            return albumsGrouping.numberOfGroups
        }
        
        if let group = item as? Group {
            return group.hasSubGroups ? group.subGroups.count : group.numberOfTracks
        }
        
        return 0
    }
    
    func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
        
        if item == nil {
            return albumsGrouping.group(at: index)
        }
        
        if let group = item as? Group {
            return (group.hasSubGroups ? group.subGroups.values[index] : group[index]) as Any
        }
        
        return ""
    }
    
    func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
        item is Group
    }
    
    func outlineViewItemDidExpand(_ notification: Notification) {
        
        guard let album = notification.userInfo?.values.first as? AlbumGroup,
              album.hasSubGroups else {return}
        
        for group in album.subGroups.values {
            outlineView.expandItem(group)
        }
    }
    
    func outlineView(_ outlineView: NSOutlineView, shouldShowOutlineCellForItem item: Any) -> Bool {
        !(item is AlbumDiscGroup)
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
            
            if let album = item as? AlbumGroup,
               let cell = outlineView.makeView(withIdentifier: .cid_AlbumName, owner: nil) as? AlbumCellView {
                
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
    
    // Refreshes the playlist view in response to a new track being added to the playlist
    func tracksAdded(_ notification: LibraryTracksAddedNotification) {
        
        let selectedItems = outlineView.selectedItems
        
        //        guard let results = notification.groupingResults[albumsGrouping] else {return}
        //
        //        var groupsToReload: Set<Group> = Set()
        //
        //        for result in results {
        //
        //            if result.groupCreated {
        //
        //                // Insert the new group
        //                outlineView.insertItems(at: IndexSet(integer: result.track.groupIndex), inParent: nil, withAnimation: .effectFade)
        //
        //            } else {
        //
        //                // Insert the new track under its parent group, and reload the parent group
        //                let group = result.track.group
        //                groupsToReload.insert(group)
        //
        //                outlineView.insertItems(at: IndexSet(integer: result.track.trackIndex), inParent: group, withAnimation: .effectGap)
        //            }
        //        }
        //
        //        for group in groupsToReload {
        //            outlineView.reloadItem(group, reloadChildren: true)
        //        }
        
        outlineView.reloadData()
        outlineView.selectItems(selectedItems)
        
        updateSummary()
    }
    
    override func updateSummary() {
        
        let numGroups = albumsGrouping.numberOfGroups
        let numTracks = library.size
        
        lblAlbumsSummary.stringValue = "\(numGroups) \(numGroups == 1 ? "album" : "albums"), \(numTracks) \(numTracks == 1 ? "track" : "tracks")"
        lblDurationSummary.stringValue = ValueFormatter.formatSecondsToHMS(library.duration)
    }
    
    override func notifyReloadTable() {
        messenger.publish(.library_reloadTable)
    }
}

class AlbumCellView: AuralTableCellView {
    
    func update(forGroup group: AlbumGroup) {
        
        var string = group.name.attributed(font: systemFontScheme.playerPrimaryFont, color: systemColorScheme.primaryTextColor, lineSpacing: 5)
        
        if let artists = group.artistsString {
            string = string + "\nby \(artists)".attributed(font: systemFontScheme.playerSecondaryFont, color: systemColorScheme.secondaryTextColor, lineSpacing: 3)
        }
        
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
        
        imageView?.image = group.art
    }
}

class AlbumTrackCellView: AuralTableCellView {
    
    @IBOutlet weak var lblTrackNumber: NSTextField!
    @IBOutlet weak var lblTrackName: NSTextField!
    
    lazy var trackNumberConstraintsManager = LayoutConstraintsManager(for: lblTrackNumber!)
    lazy var trackNameConstraintsManager = LayoutConstraintsManager(for: lblTrackName!)
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        
        lblTrackNumber.font = systemFontScheme.playQueuePrimaryFont
        lblTrackNumber.textColor = systemColorScheme.tertiaryTextColor
        trackNumberConstraintsManager.removeAll(withAttributes: [.centerY])
        trackNumberConstraintsManager.centerVerticallyInSuperview(offset: systemFontScheme.playQueueYOffset)
        
        lblTrackName.font = systemFontScheme.playQueuePrimaryFont
        lblTrackName.textColor = systemColorScheme.primaryTextColor
        trackNameConstraintsManager.removeAll(withAttributes: [.centerY])
        trackNameConstraintsManager.centerVerticallyInSuperview(offset: systemFontScheme.playQueueYOffset)
    }
    
    func update(forTrack track: Track) {
        
        if let trackNumber = track.trackNumber {
            lblTrackNumber.stringValue = "\(trackNumber)"
        }
        
        lblTrackName.stringValue = track.titleOrDefaultDisplayName
    }
    
    override var backgroundStyle: NSView.BackgroundStyle {
        
        didSet {
            
            if rowIsSelected {
                
                lblTrackNumber.textColor = systemColorScheme.tertiarySelectedTextColor
                lblTrackName.textColor = systemColorScheme.primarySelectedTextColor
                
            } else {
                
                lblTrackNumber.textColor = systemColorScheme.tertiaryTextColor
                lblTrackName.textColor = systemColorScheme.primaryTextColor
            }
        }
    }
}

class GroupSummaryCellView: AuralTableCellView {
    
    @IBOutlet weak var lblTrackCount: NSTextField!
    @IBOutlet weak var lblDuration: NSTextField!
    
    lazy var summaryFont: NSFont = systemFontScheme.playQueuePrimaryFont
    
    func update(forGroup group: Group) {
        
        let trackCount = group.numberOfTracks
        
        lblTrackCount.stringValue = "\(trackCount) \(trackCount == 1 ? "track" : "tracks")"
        lblDuration.stringValue = ValueFormatter.formatSecondsToHMS(group.duration)
        
        lblTrackCount.font = summaryFont
        lblDuration.font = summaryFont
        
        lblTrackCount.textColor = systemColorScheme.secondaryTextColor
        lblDuration.textColor = systemColorScheme.secondaryTextColor
    }
    
    func update(forAlbumGroup group: AlbumGroup) {
        
        let trackCount = group.numberOfTracks
        let discCount = group.discCount
        
        if discCount > 1 {
            lblTrackCount.stringValue = "\(discCount) discs, \(trackCount) \(trackCount == 1 ? "track" : "tracks")"
            
        } else {
            lblTrackCount.stringValue = "\(trackCount) \(trackCount == 1 ? "track" : "tracks")"
        }
        
        lblDuration.stringValue = ValueFormatter.formatSecondsToHMS(group.duration)
        
        lblTrackCount.font = summaryFont
        lblDuration.font = summaryFont
        
        lblTrackCount.textColor = systemColorScheme.secondaryTextColor
        lblDuration.textColor = systemColorScheme.secondaryTextColor
    }
    
    func update(forGenreGroup group: GenreGroup) {
        
        let trackCount = group.numberOfTracks
        let artistsCount = group.numberOfSubGroups
        
        lblTrackCount.stringValue = "\(artistsCount) \(artistsCount == 1 ? "artist" : "artists"), \(trackCount) \(trackCount == 1 ? "track" : "tracks")"
        lblDuration.stringValue = ValueFormatter.formatSecondsToHMS(group.duration)
        
        lblTrackCount.font = summaryFont
        lblDuration.font = summaryFont
        
        lblTrackCount.textColor = systemColorScheme.secondaryTextColor
        lblDuration.textColor = systemColorScheme.secondaryTextColor
    }
    
    func update(forDecadeGroup group: DecadeGroup) {
        
        let trackCount = group.numberOfTracks
        let artistsCount = group.numberOfSubGroups
        
        lblTrackCount.stringValue = "\(artistsCount) \(artistsCount == 1 ? "artist" : "artists"), \(trackCount) \(trackCount == 1 ? "track" : "tracks")"
        lblDuration.stringValue = ValueFormatter.formatSecondsToHMS(group.duration)
        
        lblTrackCount.font = summaryFont
        lblDuration.font = summaryFont
        
        lblTrackCount.textColor = systemColorScheme.secondaryTextColor
        lblDuration.textColor = systemColorScheme.secondaryTextColor
    }
}

extension NSUserInterfaceItemIdentifier {
    
    // Outline view column identifiers
    static let cid_AlbumName: NSUserInterfaceItemIdentifier = NSUserInterfaceItemIdentifier("cid_AlbumName")
    static let cid_DiscName: NSUserInterfaceItemIdentifier = NSUserInterfaceItemIdentifier("cid_DiscName")
    static let cid_TrackName: NSUserInterfaceItemIdentifier = NSUserInterfaceItemIdentifier("cid_TrackName")
    
    static let cid_AlbumDuration: NSUserInterfaceItemIdentifier = NSUserInterfaceItemIdentifier("cid_AlbumDuration")
    static let cid_DiscDuration: NSUserInterfaceItemIdentifier = NSUserInterfaceItemIdentifier("cid_DiscDuration")
    static let cid_TrackDuration: NSUserInterfaceItemIdentifier = NSUserInterfaceItemIdentifier("cid_TrackDuration")
}
