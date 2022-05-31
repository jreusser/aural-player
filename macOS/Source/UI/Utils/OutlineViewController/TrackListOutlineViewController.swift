//
//  TrackListOutlineViewController.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import Cocoa

class TrackListOutlineViewController: NSViewController, NSOutlineViewDelegate {
    
    @IBOutlet weak var outlineView: NSOutlineView!
    
    /// Override this !
    var trackList: GroupedSortedTrackListProtocol! {nil}
    
    /// Override this !
    var grouping: Grouping! {nil}
    
    var selectedRows: IndexSet {outlineView.selectedRowIndexes}
    
    var invertedSelection: IndexSet {outlineView.invertedSelection}
    
    var selectedRowCount: Int {outlineView.numberOfSelectedRows}
    
    var selectedRowView: NSView? {
        return outlineView.rowView(atRow: outlineView.selectedRow, makeIfNecessary: false)
    }
    
    var rowCount: Int {outlineView.numberOfRows}
    
    var lastRow: Int {outlineView.numberOfRows - 1}
    
    var atLeastTwoRowsAndNotAllSelected: Bool {
        
        let rowCount = self.rowCount
        return rowCount > 1 && (1..<rowCount).contains(selectedRowCount)
    }
    
    lazy var messenger: Messenger = Messenger(for: self)
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        outlineView.enableDragDrop()
        colorSchemesManager.registerObserver(outlineView, forProperty: \.backgroundColor)
    }
    
    func colorChanged(to newColor: PlatformColor, forProperty property: KeyPath<ColorScheme, PlatformColor>) {
        
        if property == \.backgroundColor {
            outlineView.setBackgroundColor(newColor)
        }
    }
    
    // MARK: NSOutlineViewDelegate
    
    // Returns a view for a single row
    func outlineView(_ outlineView: NSOutlineView, rowViewForItem item: Any) -> NSTableRowView? {
        AuralTableRowView()
    }
    
    // Determines the height of a single row
    func outlineView(_ outlineView: NSOutlineView, heightOfRowByItem item: Any) -> CGFloat {
        item is Group ? 100 : 30
    }
    
    // Enables type selection, allowing the user to conveniently and efficiently find a playlist track by typing its display name, which results in the track, if found, being selected within the playlist
    func outlineView(_ outlineView: NSOutlineView, typeSelectStringFor tableColumn: NSTableColumn?, item: Any) -> String? {
        
        // Only the track name column is used for type selection
        guard tableColumn?.identifier == .cid_trackName, let displayName = (item as? Track)?.displayName ?? (item as? Group)?.name else {return nil}
        
        if !(displayName.starts(with: "<") || displayName.starts(with: ">")) {
            return displayName
        }
        
        return nil
    }
    
    @IBAction func removeSelectedItemsAction(_ sender: AnyObject) {
        removeSelectedItems()
    }
    
    func removeSelectedItems() {
        
        let selectedItems = outlineView.selectedItems
        var groups: Set<Group> = Set()
        var groupedTracks: [GroupedTrack] = []
        
        for item in selectedItems {
            
            if let group = item as? Group {
                groups.insert(group)
                
            } else if let track = item as? Track {
                
                guard let parentGroup = outlineView.parent(forItem: track) as? Group else {continue}
                
                // If the parent group is already going to be deleted, no need to remove the track.
                if !groups.contains(parentGroup) {
                    groupedTracks.append(GroupedTrack(track: track, group: parentGroup, trackIndex: -1, groupIndex: -1))    // Indices not important.
                }
            }
        }
        
        _ = trackList.remove(tracks: groupedTracks, andGroups: Array(groups), from: grouping)
    }
    
    func notifyReloadTable() {}
    
    @IBAction func removeAllTracksAction(_ sender: NSButton) {
        removeAllTracks()
    }
    
    func removeAllTracks() {
        
        trackList.removeAllTracks()
        notifyReloadTable()
    }
    
    @inlinable
    @inline(__always)
    func reloadTable() {
        
        outlineView.reloadData()
        updateSummary()
    }
    
    /// Override this !
    func updateSummary() {}
    
    @IBAction func playNowAction(_ sender: AnyObject) {
        
        guard let item = outlineView.selectedItem else {return}
        
        if let track = item as? Track {
            messenger.publish(EnqueueAndPlayNowCommand(tracks: [track], clearPlayQueue: false))
            
        } else if let group = item as? Group {
            messenger.publish(EnqueueAndPlayNowCommand(tracks: group.tracks, clearPlayQueue: false))
        }
    }
    
    @IBAction func expandAllGroupsAction(_ sender: AnyObject) {
        
        grouping.rootGroup.subGroups.values.forEach {
            expandGroup($0)
        }
    }
    
    func expandGroup(_ group: Group) {
        
        outlineView.expandItem(group)
        
        if group.hasSubGroups {
            
            for subGroup in group.subGroups.values {
                
                // Recursive call
                expandGroup(subGroup)
            }
        }
    }
    
    @IBAction func collapseAllGroupsAction(_ sender: AnyObject) {
        
        grouping.rootGroup.subGroups.values.forEach {
            collapseGroup($0)
        }
    }
    
    func collapseGroup(_ group: Group) {
        
        outlineView.collapseItem(group)
        
        if group.hasSubGroups {
            
            for subGroup in group.subGroups.values {
                
                // Recursive call
                collapseGroup(subGroup)
            }
        }
    }
}
