//
//  LibraryArtistsSortView.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import Cocoa

typealias CheckBox = NSButton
typealias RadioButton = NSButton

/// Abstract class !!!
class LibrarySortView: NSView {
    
    @IBOutlet weak var sortGroups: CheckBox!
    
    @IBOutlet weak var sortGroups_byName: RadioButton!
    @IBOutlet weak var sortGroups_byDuration: RadioButton!
    
    @IBOutlet weak var sortGroups_ascending: RadioButton!
    @IBOutlet weak var sortGroups_descending: RadioButton!
    
    @IBOutlet weak var sortTracks: CheckBox!
    
    @IBOutlet weak var sortTracks_byName: RadioButton!
    @IBOutlet weak var sortTracks_byDuration: RadioButton!
    
    @IBOutlet weak var sortTracks_ascending: RadioButton!
    @IBOutlet weak var sortTracks_descending: RadioButton!
    
    /// Override this !!!
    var sort: GroupedTrackListSort {
        GroupedTrackListSort()
    }
    
    // MARK: Actions for radio button groups
    
    @IBAction func groupsSortToggleAction(_ sender: Any) {}
    
    @IBAction func groupsSortFieldAction(_ sender: Any) {}
    
    @IBAction func groupsSortOrderAction(_ sender: Any) {}
    
    @IBAction func tracksSortToggleAction(_ sender: Any) {}
    
    @IBAction func tracksSortFieldAction(_ sender: Any) {}
    
    @IBAction func tracksSortOrderAction(_ sender: Any) {}
}

class LibraryArtistsSortView: LibrarySortView {
    
    @IBOutlet weak var sortTracks_byDiscTrack: RadioButton!
    
    override var sort: GroupedTrackListSort {
        
        var groupSort: GroupSort?
        
        if sortGroups.isOn {
            groupSort = GroupSort(fields: groupSortFields, order: groupSortOrder)
        }
        
        var trackSort: TrackListSort?
        
        if sortTracks.isOn {
            trackSort = TrackListSort(fields: trackSortFields, order: trackSortOrder)
        }
        
        return GroupedTrackListSort(groupSort: groupSort, trackSort: trackSort)
    }
    
    var groupSortFields: [GroupSortField] {
        sortGroups_byName.isOn ? [.name] : [.duration]
    }
    
    var groupSortOrder: SortOrder {
        sortGroups_ascending.isOn ? .ascending : .descending
    }
    
    var trackSortFields: [TrackSortField] {
        
        if sortTracks_byDiscTrack.isOn {
            return [.discNumberAndTrackNumber]
            
        } else if sortTracks_byName.isOn {
            return [.name]
            
        } else { // By duration
            return [.duration]
        }
    }
    
    var trackSortOrder: SortOrder {
        sortTracks_ascending.isOn ? .ascending : .descending
    }
}
