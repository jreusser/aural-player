//
//  TrackComparisons.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import Foundation

typealias TrackComparison = (Track, Track) -> ComparisonResult

let trackNameComparison: TrackComparison = {t1, t2 in
    t1.displayName.compare(t2.displayName)
}

let trackArtistComparison: TrackComparison = {t1, t2 in
    (t1.artist ?? "").compare(t2.artist ?? "")
}

let trackAlbumComparison: TrackComparison = {t1, t2 in
    (t1.album ?? "").compare(t2.album ?? "")
}

let trackNumberComparison: TrackComparison = {t1, t2 in
    (t1.trackNumber ?? -1).compare(t2.trackNumber ?? -1)
}

let trackDiscNumberComparison: TrackComparison = {t1, t2 in
    (t1.discNumber ?? -1).compare(t2.discNumber ?? -1)
}

let trackDiscAndTrackNumberComparison: TrackComparison = {t1, t2 in
    
    let compositeFunction = chainTrackComparisons(trackDiscNumberComparison, trackNumberComparison)
    return compositeFunction(t1, t2)
}

let trackDurationComparison: TrackComparison = {t1, t2 in
    (t1.duration).compare(t2.duration)
}

func chainTrackComparisons(_ c1: @escaping TrackComparison, _ c2: @escaping TrackComparison) -> TrackComparison {

    {t1, t2 in

        if c1(t1, t2) == .orderedSame {
            return c2(t1, t2)
        } else {
            return c1(t1, t2)
        }
    }
}
