//
//  SortField.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

///
/// An enumeration of fields that can be used as playlist sort criteria.
///
enum TrackSortField {
    
    case name
    case duration
    case artist
    case album
    case discNumberAndTrackNumber
    
    var comparison: TrackComparison {
        
        switch self {
            
        case .name:
            
            return trackNameComparison
            
        case .artist:
            
            return trackArtistComparison
            
        case .album:
            
            return trackAlbumComparison
            
        case .discNumberAndTrackNumber:
            
            return trackDiscAndTrackNumberComparison
            
        case .duration:
            
            return trackDurationComparison
        }
    }
    
    func comparator(withOrder order: SortOrder) -> TrackComparator {
        
        switch self {
            
        case .name:
            
            return order == .ascending ? trackNameAscendingComparator : trackNameDescendingComparator
            
        case .artist:
            
            return order == .ascending ? trackArtistAscendingComparator : trackArtistDescendingComparator
            
        case .album:
            
            return order == .ascending ? trackAlbumAscendingComparator : trackAlbumDescendingComparator
            
        case .discNumberAndTrackNumber:
            
            return order == .ascending ? trackDiscAndTrackNumberAscendingComparator : trackDiscAndTrackNumberDescendingComparator
            
        case .duration:
            
            return order == .ascending ? trackDurationAscendingComparator : trackDurationDescendingComparator
        }
    }
}

enum GroupSortField {
    
    case name
    case duration
    
    var comparison: GroupComparison {
        
        switch self {
            
        case .name:
            
            return groupNameComparison
            
        case .duration:
            
            return groupDurationComparison
        }
    }
    
    func comparator(withOrder order: SortOrder) -> GroupComparator {
        
        switch self {
            
        case .name:
            
            return order == .ascending ? groupNameAscendingComparator : groupNameDescendingComparator
            
        case .duration:
            
            return order == .ascending ? groupDurationAscendingComparator : groupDurationDescendingComparator
        }
    }
}
