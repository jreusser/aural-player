//
//  PlaylistAlbumsViewController.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import Cocoa

class PlaylistAlbumsViewController: TrackListOutlineViewController {
    
    override var nibName: String? {"PlaylistAlbums"}
    
    // Returns a view for a single column
    func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {
        
        guard let columnId = tableColumn?.identifier else {return nil}
        
        if let group = item as? AlbumGroup {
            
            if columnId == .cid_Duration {
                return createDurationCell(forItem: group, duration: group.duration)
            }
            
            return createAlbumGroupCell(for: group)
        }
        
        if let track = item as? Track {
            
            if columnId == .cid_Duration {
                return createDurationCell(forItem: track, duration: track.duration)
            }
            
            return createAlbumTrackCell(for: track)
        }
        
        return nil
    }
    
    private func createAlbumGroupCell(for group: AlbumGroup) -> AlbumGroupCellView? {
        
        guard let cell = outlineView.makeView(withIdentifier: .cid_AlbumGroup, owner: nil) as? AlbumGroupCellView else {return nil}
        
        cell.update(forGroup: group)
        
        cell.rowSelectionStateFunction = {[weak outlineView] in
            outlineView?.isItemSelected(group) ?? false
        }
        
        return cell
    }
    
    private func createAlbumTrackCell(for track: Track) -> AlbumTrackCellView? {
        
        guard let cell = outlineView.makeView(withIdentifier: .cid_AlbumTrack, owner: nil) as? AlbumTrackCellView else {return nil}
        
        cell.update(forTrack: track)
        
        cell.rowSelectionStateFunction = {[weak outlineView] in
            outlineView?.isItemSelected(track) ?? false
        }
        
        return cell
    }
    
    private func createDurationCell(forItem item: Any, duration: Double) -> AuralTableCellView? {
        
        TableCellBuilder().withText(text: ValueFormatter.formatSecondsToHMS(duration),
                                           inFont: systemFontScheme.playQueuePrimaryFont,
                                           andColor: systemColorScheme.tertiaryTextColor,
                                           selectedTextColor: systemColorScheme.tertiarySelectedTextColor,
                                           yOffset: systemFontScheme.playQueueYOffset)
            .buildCell(forOutlineView: outlineView, forColumnWithId: .cid_Duration, havingItem: item)
    }
}

extension NSUserInterfaceItemIdentifier {
    
    // Outline view column identifiers
    static let cid_Name: NSUserInterfaceItemIdentifier = NSUserInterfaceItemIdentifier("cid_Name")
    static let cid_Duration: NSUserInterfaceItemIdentifier = NSUserInterfaceItemIdentifier("cid_Duration")
    
    // Identifiers for different cells
    static let cid_AlbumGroup: NSUserInterfaceItemIdentifier = NSUserInterfaceItemIdentifier("cid_AlbumGroup")
    static let cid_AlbumTrack: NSUserInterfaceItemIdentifier = NSUserInterfaceItemIdentifier("cid_AlbumTrack")
}

class AlbumGroupCellView: NSTableCellView {
    
    @IBOutlet weak var lblAlbumName: NSTextField!
    @IBOutlet weak var lblArtists: NSTextField!
    @IBOutlet weak var lblGenres: NSTextField!
    @IBOutlet weak var lblYears: NSTextField!
    @IBOutlet weak var lblTrackCount: NSTextField!
    
    // Used to determine whether or not this cell is selected.
    var rowSelectionStateFunction: () -> Bool = {false}
    
    var rowIsSelected: Bool {rowSelectionStateFunction()}
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        
        lblAlbumName.font = systemFontScheme.playlist.groupTextFont
        lblAlbumName.textColor = systemColorScheme.primaryTextColor
        
//        lblArtists
    }
    
    func update(forGroup group: AlbumGroup) {
        
        lblAlbumName.stringValue = group.name
    }
    
    override var backgroundStyle: NSView.BackgroundStyle {
        
        didSet {
            
            if rowIsSelected {
                lblAlbumName.textColor = systemColorScheme.primarySelectedTextColor
            } else {
                lblAlbumName.textColor = systemColorScheme.primaryTextColor
            }
        }
    }
}

class AlbumTrackCellView: NSTableCellView {
    
    @IBOutlet weak var lblTrackNumber: NSTextField!
    @IBOutlet weak var lblTrackName: NSTextField!
    
    var rowSelectionStateFunction: () -> Bool = {false}
    
    var rowIsSelected: Bool {rowSelectionStateFunction()}
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        
        lblTrackNumber.font = systemFontScheme.playQueuePrimaryFont
        lblTrackNumber.textColor = systemColorScheme.tertiaryTextColor
        
        lblTrackName.font = systemFontScheme.playQueuePrimaryFont
        lblTrackName.textColor = systemColorScheme.primaryTextColor
    }
    
    func update(forTrack track: Track) {
        
        lblTrackNumber.stringValue = "\(track.trackNumber ?? 0)"
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
