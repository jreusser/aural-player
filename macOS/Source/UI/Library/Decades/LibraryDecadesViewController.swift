//
//  LibraryDecadesViewController.swift
//  Aural
//
//  Copyright © 2023 Kartik Venugopal. All rights reserved.
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
        
        messenger.subscribeAsync(to: .library_doneAddingTracks, handler: doneAddingTracks)
        
        messenger.subscribe(to: .library_reloadTable, handler: reloadTable)
        messenger.subscribe(to: .library_updateSummary, handler: updateSummary)
        
        colorSchemesManager.registerPropertyObserver(self, forProperty: \.backgroundColor, changeReceiver: rootContainer)
        colorSchemesManager.registerPropertyObserver(self, forProperty: \.captionTextColor, changeReceiver: lblCaption)
        colorSchemesManager.registerPropertyObserver(self, forProperty: \.secondaryTextColor, changeReceivers: [lblDecadesSummary, lblDurationSummary])
        
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
                                                   inFont: systemFontScheme.normalFont,
                                                   andColor: systemColorScheme.tertiaryTextColor,
                                                   selectedTextColor: systemColorScheme.tertiarySelectedTextColor,
                                                   centerYOffset: systemFontScheme.tableYOffset)
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
        
        return nil
    }
    
    override func updateSummary() {
        
        let numGroups = decadesGrouping.numberOfGroups
        let numTracks = library.size
        
        lblDecadesSummary.stringValue = "\(numGroups) \(numGroups == 1 ? "decade" : "decades"), \(numTracks) \(numTracks == 1 ? "track" : "tracks")"
        lblDurationSummary.stringValue = ValueFormatter.formatSecondsToHMS(library.duration)
    }
    
    override func fontSchemeChanged() {
        
        super.fontSchemeChanged()
        
        lblCaption.font = systemFontScheme.captionFont
        [lblDecadesSummary, lblDurationSummary].forEach {
            $0.font = systemFontScheme.smallFont
        }
    }
    
    override func colorSchemeChanged() {
        
        super.colorSchemeChanged()
        
        rootContainer.fillColor = systemColorScheme.backgroundColor
        lblCaption.textColor = systemColorScheme.captionTextColor
        
        lblDecadesSummary.textColor = systemColorScheme.secondaryTextColor
        lblDurationSummary.textColor = systemColorScheme.secondaryTextColor
    }
}
