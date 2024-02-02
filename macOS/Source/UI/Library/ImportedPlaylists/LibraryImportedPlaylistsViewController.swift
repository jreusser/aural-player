//
//  LibraryImportedPlaylistsViewController.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import Cocoa

class LibraryImportedPlaylistsViewController: NSViewController, NSOutlineViewDelegate, NSOutlineViewDataSource {
    
    override var nibName: String? {"LibraryImportedPlaylists"}
    
    @IBOutlet weak var outlineView: NSOutlineView!
    
    @IBOutlet weak var rootContainer: NSBox!
    @IBOutlet weak var lblCaption: NSTextField!
    
    @IBOutlet weak var lblPlaylistsSummary: NSTextField!
    @IBOutlet weak var lblDurationSummary: NSTextField!
    
    lazy var messenger: Messenger = Messenger(for: self)
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        messenger.subscribeAsync(to: .library_doneAddingTracks, handler: doneAddingTracks)
//        messenger.subscribe(to: .library_reloadTable, handler: reloadTable)
        messenger.subscribe(to: .library_updateSummary, handler: updateSummary)
        
//        colorSchemesManager.registerObserver(rootContainer, forProperty: \.backgroundColor)
//        
//        fontSchemesManager.registerObserver(lblCaption, forProperty: \.captionFont)
//        colorSchemesManager.registerObserver(lblCaption, forProperty: \.captionTextColor)
//        
//        fontSchemesManager.registerObservers([lblPlaylistsSummary, lblDurationSummary], forProperty: \.normalFont)
//        colorSchemesManager.registerObservers([lblPlaylistsSummary, lblDurationSummary], forProperty: \.secondaryTextColor)
//        
//        colorSchemesManager.registerObserver(outlineView, forProperty: \.backgroundColor)
        
        updateSummary()
    }
    
    func doneAddingTracks() {
        
        outlineView.reloadData()
        updateSummary()
    }
    
    override func destroy() {
        
        super.destroy()
        messenger.unsubscribeFromAll()
    }
    
    // TODO: Implement the controls bar !!! Double-click action, sorting, etc
    
    func outlineView(_ outlineView: NSOutlineView, shouldShowOutlineCellForItem item: Any) -> Bool {
        item is ImportedPlaylist
    }
    
    func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
        item is ImportedPlaylist
    }
    
    func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
        
        if item == nil {
            return library.numberOfPlaylists
        }
        
        if let playlist = item as? ImportedPlaylist {
            return playlist.size
        }
        
        return 0
    }
    
    func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
        
        if item == nil, let playlist = library.playlist(atIndex: index) {
            return playlist
        }
        
        if let playlist = item as? ImportedPlaylist, let track = playlist[index] {
            return track
        }
        
        return ""
    }
    
    func outlineView(_ outlineView: NSOutlineView, heightOfRowByItem item: Any) -> CGFloat {
        item is ImportedPlaylist ? 60 : 30
    }
    
    // Returns a view for a single row
    func outlineView(_ outlineView: NSOutlineView, rowViewForItem item: Any) -> NSTableRowView? {
        AuralTableRowView()
    }
    
    func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {
        
        guard let columnId = tableColumn?.identifier else {return nil}
        
        switch columnId {
            
        case .cid_Name:
            
            if let track = item as? Track,
               let cell = outlineView.makeView(withIdentifier: .cid_TrackName, owner: nil) as? ImportedPlaylistTrackCellView {
                
                cell.update(forTrack: track)
                cell.rowSelectionStateFunction = {[weak outlineView, weak track] in outlineView?.isItemSelected(track as Any) ?? false}
                
                return cell
            }
            
            if let playlist = item as? ImportedPlaylist,
               let cell = outlineView.makeView(withIdentifier: .cid_ImportedPlaylistName, owner: nil) as? ImportedPlaylistCellView {
                
                cell.update(forPlaylist: playlist)
                cell.rowSelectionStateFunction = {[weak outlineView, weak playlist] in outlineView?.isItemSelected(playlist as Any) ?? false}
                
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
            
            if let playlist = item as? ImportedPlaylist,
               let cell = outlineView.makeView(withIdentifier: .cid_ImportedPlaylistDuration, owner: nil) as? GroupSummaryCellView {
                
                cell.update(forPlaylistGroup: playlist)
                cell.rowSelectionStateFunction = {[weak outlineView, weak playlist] in outlineView?.isItemSelected(playlist as Any) ?? false}
                
                return cell
            }
            
        default:
            return nil
        }
        
        return nil
    }
    
    func updateSummary() {
        
        let numGroups = library.numberOfPlaylists
        let numTracks = library.numberOfTracksInPlaylists
        
        lblPlaylistsSummary.stringValue = "\(numGroups) \(numGroups == 1 ? "playlist file" : "playlist files"), \(numTracks) \(numTracks == 1 ? "track" : "tracks")"
        lblDurationSummary.stringValue = ValueFormatter.formatSecondsToHMS(library.durationOfTracksInPlaylists)
    }
}

class ImportedPlaylistCellView: AuralTableCellView {
    
    func update(forPlaylist playlist: ImportedPlaylist) {
        
        let string = playlist.name.attributed(font: systemFontScheme.prominentFont, color: systemColorScheme.primaryTextColor, lineSpacing: 5)
        textField?.attributedStringValue = string
        
        imageView?.image = .imgPlaylist
    }
}

class ImportedPlaylistTrackCellView: AuralTableCellView {
    
    @IBOutlet weak var lblTrackNumber: NSTextField!
    @IBOutlet weak var lblTrackName: NSTextField!
    
    lazy var trackNumberConstraintsManager = LayoutConstraintsManager(for: lblTrackNumber!)
    lazy var trackNameConstraintsManager = LayoutConstraintsManager(for: lblTrackName!)
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        
        lblTrackName.font = systemFontScheme.normalFont
        lblTrackName.textColor = systemColorScheme.primaryTextColor
        trackNameConstraintsManager.removeAll(withAttributes: [.centerY])
        trackNameConstraintsManager.centerVerticallyInSuperview(offset: systemFontScheme.tableYOffset)
    }
    
    func update(forTrack track: Track) {
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

extension NSUserInterfaceItemIdentifier {
    
    // Outline view column identifiers
    static let cid_ImportedPlaylistName: NSUserInterfaceItemIdentifier = NSUserInterfaceItemIdentifier("cid_ImportedPlaylistName")
    static let cid_ImportedPlaylistDuration: NSUserInterfaceItemIdentifier = NSUserInterfaceItemIdentifier("cid_ImportedPlaylistDuration")
}
