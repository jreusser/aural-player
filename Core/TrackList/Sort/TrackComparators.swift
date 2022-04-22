//
//  TrackComparators.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import Foundation

typealias TrackComparator = (Track, Track) -> Bool

let trackNameAscendingComparator: TrackComparator = {t1, t2 in
    trackNameComparison(t1, t2) == .orderedAscending
}

let trackNameDescendingComparator: TrackComparator = {t1, t2 in
    trackNameComparison(t1, t2) == .orderedDescending
}

let trackArtistAscendingComparator: TrackComparator = {t1, t2 in
    trackArtistComparison(t1, t2) == .orderedAscending
}

let trackArtistDescendingComparator: TrackComparator = {t1, t2 in
    trackArtistComparison(t1, t2) == .orderedDescending
}

let trackAlbumAscendingComparator: TrackComparator = {t1, t2 in
    trackAlbumComparison(t1, t2) == .orderedAscending
}

let trackAlbumDescendingComparator: TrackComparator = {t1, t2 in
    trackAlbumComparison(t1, t2) == .orderedDescending
}

let trackNumberAscendingComparator: TrackComparator = {t1, t2 in
    trackNumberComparison(t1, t2) == .orderedAscending
}

let trackNumberDescendingComparator: TrackComparator = {t1, t2 in
    trackNumberComparison(t1, t2) == .orderedDescending
}

let trackDiscNumberAscendingComparator: TrackComparator = {t1, t2 in
    trackDiscNumberComparison(t1, t2) == .orderedAscending
}

let trackDiscNumberDescendingComparator: TrackComparator = {t1, t2 in
    trackDiscNumberComparison(t1, t2) == .orderedDescending
}

let trackDiscAndTrackNumberAscendingComparator: TrackComparator = {t1, t2 in
    trackDiscAndTrackNumberComparison(t1, t2) == .orderedAscending
}

let trackDiscAndTrackNumberDescendingComparator: TrackComparator = {t1, t2 in
    trackDiscAndTrackNumberComparison(t1, t2) == .orderedDescending
}

let trackDurationAscendingComparator: TrackComparator = {t1, t2 in
    trackDurationComparison(t1, t2) == .orderedAscending
}

let trackDurationDescendingComparator: TrackComparator = {t1, t2 in
    trackDurationComparison(t1, t2) == .orderedDescending
}
