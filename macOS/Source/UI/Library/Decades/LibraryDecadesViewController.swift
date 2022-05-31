//
//  LibraryDecadesViewController.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import Cocoa

class LibraryDecadesViewController: TrackListOutlineViewController {
    
    override var nibName: String? {"LibraryDecades"}
    
    @IBOutlet weak var rootContainer: NSBox!
    @IBOutlet weak var lblCaption: NSTextField!
    
    @IBOutlet weak var lblDecadesSummary: NSTextField!
    @IBOutlet weak var lblDurationSummary: NSTextField!
    
    private lazy var decadesGrouping: DecadesGrouping = library.decadesGrouping
    override var grouping: Grouping! {decadesGrouping}
    
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
        
        fontSchemesManager.registerObservers([lblDecadesSummary, lblDurationSummary], forProperty: \.playQueueSecondaryFont)
        colorSchemesManager.registerObservers([lblDecadesSummary, lblDurationSummary], forProperty: \.secondaryTextColor)
        
        updateSummary()
    }
    
    override func outlineView(_ outlineView: NSOutlineView, heightOfRowByItem item: Any) -> CGFloat {
        item is Group ? 60 : 30
    }
    
    func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
        
        if item == nil {
            return decadesGrouping.numberOfGroups
        }
        
        if let group = item as? Group {
            return group.hasSubGroups ? group.subGroups.count : group.numberOfTracks
        }
        
        return 0
    }
    
    func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
        
        if item == nil {
            return decadesGrouping.group(at: index)
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
        
        guard let decade = notification.userInfo?.values.first as? DecadeGroup,
              decade.hasSubGroups else {return}
        
        for group in decade.subGroups.values {
            outlineView.expandItem(group)
        }
    }
    
    func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {
        
        guard let columnId = tableColumn?.identifier else {return nil}
        
        switch columnId {
            
        case .cid_Name:
            
            if let track = item as? Track,
               let cell = outlineView.makeView(withIdentifier: .cid_TrackName, owner: nil) as? DecadeTrackCellView {
                
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
            
            if let decade = item as? DecadeGroup,
               let cell = outlineView.makeView(withIdentifier: .cid_DecadeName, owner: nil) as? DecadeCellView {
                
                cell.update(forGroup: decade)
                cell.rowSelectionStateFunction = {[weak outlineView, weak decade] in outlineView?.isItemSelected(decade as Any) ?? false}
                
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
            
            if let decade = item as? DecadeGroup,
               let cell = outlineView.makeView(withIdentifier: .cid_DecadeDuration, owner: nil) as? GroupSummaryCellView {
                
                cell.update(forDecadeGroup: decade)
                cell.rowSelectionStateFunction = {[weak outlineView, weak decade] in outlineView?.isItemSelected(decade as Any) ?? false}
                
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
        
        //        guard let results = notification.groupingResults[decadesGrouping] else {return}
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
        
        let numGroups = decadesGrouping.numberOfGroups
        let numTracks = library.size
        
        lblDecadesSummary.stringValue = "\(numGroups) \(numGroups == 1 ? "decade" : "decades"), \(numTracks) \(numTracks == 1 ? "track" : "tracks")"
        lblDurationSummary.stringValue = ValueFormatter.formatSecondsToHMS(library.duration)
    }
    
    override func notifyReloadTable() {
        messenger.publish(.library_reloadTable)
    }
}

class DecadeCellView: AuralTableCellView {
    
    func update(forGroup group: DecadeGroup) {
        
        let string = group.name.attributed(font: systemFontScheme.playerPrimaryFont, color: systemColorScheme.primaryTextColor, lineSpacing: 5)
        textField?.attributedStringValue = string
        
        imageView?.image = .imgDecadeGroup
    }
}

class DecadeTrackCellView: AuralTableCellView {
    
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
    static let cid_DecadeName: NSUserInterfaceItemIdentifier = NSUserInterfaceItemIdentifier("cid_DecadeName")
    static let cid_DecadeDuration: NSUserInterfaceItemIdentifier = NSUserInterfaceItemIdentifier("cid_DecadeDuration")
}
