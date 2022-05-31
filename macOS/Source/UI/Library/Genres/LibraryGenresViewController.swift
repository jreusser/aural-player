//
//  LibraryGenresViewController.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import Cocoa

class LibraryGenresViewController: TrackListOutlineViewController {
    
    override var nibName: String? {"LibraryGenres"}
    
    @IBOutlet weak var rootContainer: NSBox!
    @IBOutlet weak var lblCaption: NSTextField!
    
    @IBOutlet weak var lblGenresSummary: NSTextField!
    @IBOutlet weak var lblDurationSummary: NSTextField!
    
    private lazy var genresGrouping: GenresGrouping = library.genresGrouping
    override var grouping: Grouping! {genresGrouping}
    
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
        
        fontSchemesManager.registerObservers([lblGenresSummary, lblDurationSummary], forProperty: \.playQueueSecondaryFont)
        colorSchemesManager.registerObservers([lblGenresSummary, lblDurationSummary], forProperty: \.secondaryTextColor)
        
        updateSummary()
    }
    
    override func outlineView(_ outlineView: NSOutlineView, heightOfRowByItem item: Any) -> CGFloat {
        
        if item is GenreGroup || item is ArtistGroup {
            return 50
        }

        return 30
    }
    
    func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
        
        if item == nil {
            return genresGrouping.numberOfGroups
        }
        
        if let group = item as? Group {
            return group.hasSubGroups ? group.subGroups.count : group.numberOfTracks
        }
        
        return 0
    }
    
    func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
        
        if item == nil {
            return genresGrouping.group(at: index)
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
        
        guard let genre = notification.userInfo?.values.first as? GenreGroup,
              genre.hasSubGroups else {return}
        
        for group in genre.subGroups.values {
            outlineView.expandItem(group)
        }
    }
    
    func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {
        
        guard let columnId = tableColumn?.identifier else {return nil}
        
        switch columnId {
            
        case .cid_Name:
            
            if let track = item as? Track,
               let cell = outlineView.makeView(withIdentifier: .cid_TrackName, owner: nil) as? GenreTrackCellView {
                
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
            
            if let genre = item as? GenreGroup,
               let cell = outlineView.makeView(withIdentifier: .cid_GenreName, owner: nil) as? GenreCellView {
                
                cell.update(forGroup: genre)
                cell.rowSelectionStateFunction = {[weak outlineView, weak genre] in outlineView?.isItemSelected(genre as Any) ?? false}
                
                return cell
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
                
                cell.update(forArtistGroup: artist, showAlbumsCount: false)
                cell.rowSelectionStateFunction = {[weak outlineView, weak artist] in outlineView?.isItemSelected(artist as Any) ?? false}
                
                return cell
            }
            
            if let genre = item as? GenreGroup,
               let cell = outlineView.makeView(withIdentifier: .cid_GenreDuration, owner: nil) as? GroupSummaryCellView {
                
                cell.update(forGroup: genre)
                cell.rowSelectionStateFunction = {[weak outlineView, weak genre] in outlineView?.isItemSelected(genre as Any) ?? false}
                
                return cell
            }
            
        default:
            
            return nil
        }
        
        print("\nNo cell for item: \(item)")
        
        return nil
    }
    
    // Refreshes the playlist view in response to a new track being added to the playlist
    func tracksAdded(_ notification: LibraryTracksAddedNotification) {
        
        let selectedItems = outlineView.selectedItems
        
        //        guard let results = notification.groupingResults[genresGrouping] else {return}
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
        
        let numGroups = genresGrouping.numberOfGroups
        let numTracks = library.size
        
        lblGenresSummary.stringValue = "\(numGroups) \(numGroups == 1 ? "genre" : "genres"), \(numTracks) \(numTracks == 1 ? "track" : "tracks")"
        lblDurationSummary.stringValue = ValueFormatter.formatSecondsToHMS(library.duration)
    }
    
    override func notifyReloadTable() {
        messenger.publish(.library_reloadTable)
    }
}

class GenreCellView: AuralTableCellView {
    
    func update(forGroup group: GenreGroup) {
        
        let string = group.name.attributed(font: systemFontScheme.playerPrimaryFont, color: systemColorScheme.primaryTextColor, lineSpacing: 5)
        textField?.attributedStringValue = string
        
        imageView?.image = .imgGenreGroup
    }
}

class GenreTrackCellView: AuralTableCellView {
    
    @IBOutlet weak var lblTrackNumber: NSTextField!
    @IBOutlet weak var lblTrackName: NSTextField!
    
    lazy var trackNumberConstraintsManager = LayoutConstraintsManager(for: lblTrackNumber!)
    lazy var trackNameConstraintsManager = LayoutConstraintsManager(for: lblTrackName!)
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        
//        lblTrackNumber.font = systemFontScheme.playQueuePrimaryFont
//        lblTrackNumber.textColor = systemColorScheme.tertiaryTextColor
//        trackNumberConstraintsManager.removeAll(withAttributes: [.centerY])
//        trackNumberConstraintsManager.centerVerticallyInSuperview(offset: systemFontScheme.playQueueYOffset)
        
        lblTrackName.font = systemFontScheme.playQueuePrimaryFont
        lblTrackName.textColor = systemColorScheme.primaryTextColor
        trackNameConstraintsManager.removeAll(withAttributes: [.centerY])
        trackNameConstraintsManager.centerVerticallyInSuperview(offset: systemFontScheme.playQueueYOffset)
    }
    
    func update(forTrack track: Track) {
        
//        if let trackNumber = track.trackNumber {
//            lblTrackNumber.stringValue = "\(trackNumber)"
//        }
        
//        lblTrackName.stringValue = track.displayName
        
        let titleAndArtist = track.titleAndArtist
        
        if let artist = titleAndArtist.artist {
            
//            return builder.withAttributedText(strings: [(text: artist + "  ", font: systemFontScheme.playlist.trackTextFont, color: systemColorScheme.secondaryTextColor),
//                                                        (text: titleAndArtist.title, font: systemFontScheme.playlist.trackTextFont, color: systemColorScheme.primaryTextColor)],
//                                              selectedTextColors: [systemColorScheme.secondarySelectedTextColor, systemColorScheme.primarySelectedTextColor],
//                                              bottomYOffset: systemFontScheme.playQueueYOffset)
            
            let attStr: NSMutableAttributedString = (artist + "  ").attributed(font: systemFontScheme.playQueuePrimaryFont, color: systemColorScheme.secondaryTextColor)
            let attStr2: NSMutableAttributedString = titleAndArtist.title.attributed(font: systemFontScheme.playQueuePrimaryFont, color: systemColorScheme.primaryTextColor)
            
            lblTrackName.attributedStringValue = attStr + attStr2
            
        } else {
            
            lblTrackName.attributedStringValue = titleAndArtist.title.attributed(font: systemFontScheme.playQueuePrimaryFont, color: systemColorScheme.primaryTextColor)
        }
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

extension NSUserInterfaceItemIdentifier {
    
    // Outline view column identifiers
    static let cid_GenreName: NSUserInterfaceItemIdentifier = NSUserInterfaceItemIdentifier("cid_GenreName")
    static let cid_GenreDuration: NSUserInterfaceItemIdentifier = NSUserInterfaceItemIdentifier("cid_GenreDuration")
}
