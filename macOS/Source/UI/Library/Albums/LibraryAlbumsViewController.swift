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
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        colorSchemesManager.registerObserver(rootContainer, forProperty: \.backgroundColor)
        
        fontSchemesManager.registerObserver(lblCaption, forProperty: \.captionFont)
        colorSchemesManager.registerObserver(lblCaption, forProperty: \.captionTextColor)
        
        fontSchemesManager.registerObservers([lblAlbumsSummary, lblDurationSummary], forProperty: \.playQueueSecondaryFont)
        colorSchemesManager.registerObservers([lblAlbumsSummary, lblDurationSummary], forProperty: \.secondaryTextColor)
        
        updateSummary()
    }
    
    override func outlineView(_ outlineView: NSOutlineView, heightOfRowByItem item: Any) -> CGFloat {
        item is AlbumGroup ? 90 : 30
    }
    
    func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
        item == nil ? albumsGrouping.numberOfGroups : 0
    }
    
    func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
        item == nil ? albumsGrouping.groups[index] : ""
    }
    
    func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {
        
        guard let columnId = tableColumn?.identifier else {return nil}
        
        switch columnId {
            
        case .cid_AlbumName:
            
            guard let album = item as? AlbumGroup,
                  let cell = outlineView.makeView(withIdentifier: .cid_AlbumName, owner: nil) as? AlbumCellView else {return nil}
            
            cell.update(forGroup: album)
            cell.rowSelectionStateFunction = {[weak outlineView, weak album] in outlineView?.isItemSelected(album as Any) ?? false}
            
            return cell
            
            //        case .cid_TrackName:
            //
            //        case .cid_Duration:
            
        default:
            
            return nil
            //        }
        }
    }
    
    // Refreshes the playlist view in response to a new track being added to the playlist
    func tracksAdded(_ notification: LibraryTracksAddedNotification) {
        
        guard let results = notification.groupingResults[albumsGrouping] else {return}
        
        var groupsToReload: Set<Group> = Set()
        
        for result in results {
            
            if result.groupCreated {
                
                // Insert the new group
                outlineView.insertItems(at: IndexSet(integer: result.track.groupIndex), inParent: nil, withAnimation: .effectFade)
                
            } else {
                
                // Insert the new track under its parent group, and reload the parent group
                let group = result.track.group
                groupsToReload.insert(group)
                
                outlineView.insertItems(at: IndexSet(integer: result.track.trackIndex), inParent: group, withAnimation: .effectGap)
            }
        }
        
        for group in groupsToReload {
            outlineView.reloadItem(group)
        }
    }
    
    private func updateSummary() {
        
        let numGroups = albumsGrouping.numberOfGroups
        lblAlbumsSummary.stringValue = "\(numGroups) \(numGroups == 1 ? "group" : "groups")"
        lblDurationSummary.stringValue = ValueFormatter.formatSecondsToHMS(library.duration)
    }
}

class AlbumCellView: AuralTableCellView {
    
    func update(forGroup group: AlbumGroup) {
        
        textField?.attributedStringValue = group.name.attributed(font: systemFontScheme.playerPrimaryFont, color: systemColorScheme.primaryTextColor)
        imageView?.image = group.art
    }
}

class AlbumTrackCellView: AuralTableCellView {
    
    @IBOutlet weak var lblTrackNumber: NSTextField!
    @IBOutlet weak var lblTrackName: NSTextField!
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        
        lblTrackNumber.font = systemFontScheme.playQueuePrimaryFont
        lblTrackNumber.textColor = systemColorScheme.tertiaryTextColor
        
        lblTrackName.font = systemFontScheme.playQueuePrimaryFont
        lblTrackName.textColor = systemColorScheme.primaryTextColor
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

extension NSUserInterfaceItemIdentifier {
    
    // Outline view column identifiers
    static let cid_AlbumName: NSUserInterfaceItemIdentifier = NSUserInterfaceItemIdentifier("cid_AlbumName")
    static let cid_TrackName: NSUserInterfaceItemIdentifier = NSUserInterfaceItemIdentifier("cid_TrackName")
}
