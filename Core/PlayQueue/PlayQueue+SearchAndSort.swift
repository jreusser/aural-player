//
//  PlayQueue+SearchAndSort.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import Foundation

extension PlayQueue {
    
//    func search(_ searchQuery: SearchQuery) -> SearchResults {
//
////        return SearchResults(tracks.compactMap {executeQuery($0, searchQuery)}.map {
////
////            SearchResult(location: SearchResultLocation(trackIndex: -1, track: $0.track),
////                         match: ($0.matchedField, $0.matchedFieldValue))
////        })
//        SearchResults([])
//    }

    private func executeQuery(_ track: Track, _ query: SearchQuery) -> [Track] {

        // Check both the filename and the display name
//        if query.fields.name {
//
////            let filename = track.fileSystemInfo.fileName
////            if query.compare(filename) {
////                return SearchQueryMatch(track: track, matchedField: "filename", matchedFieldValue: filename)
////            }
//
//            let displayName = track.defaultDisplayName
//            if query.compare(displayName) {
//                return SearchQueryMatch(track: track, matchedField: "name", matchedFieldValue: displayName)
//            }
//        }
//
//        // Compare title field if included in search
//        if query.fields.title, let theTitle = track.title, query.compare(theTitle) {
//            return SearchQueryMatch(track: track, matchedField: "title", matchedFieldValue: theTitle)
//        }

        // Didn't match
        return []
    }

//    func sort(_ sort: Sort) -> SortResults {
//
////        tracks.sort(by: SortComparator(sort, {track in track.defaultDisplayName}).compareTracks)
//        return SortResults(.tracks, sort)
//    }
//
//    func sort(by comparator: (Track, Track) -> Bool) {
////        tracks.sort(by: comparator)
//    }
}
