//
//  PlayQueueSimpleViewController.swift
//  Aural
//
//  Copyright © 2023 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import Cocoa

class PlayQueueSimpleViewController: PlayQueueViewController {
    
    override var nibName: String? {"PlayQueueSimpleView"}
    
    override var rowHeight: CGFloat {30}
    
    // MARK: Table view delegate / data source --------------------------------------------------------------------------------------------------------
    
    override func view(forColumn column: NSUserInterfaceItemIdentifier, row: Int, track: Track) -> TableCellBuilder {
        
        let builder = TableCellBuilder()
        
        switch column {
            
        case .cid_index:
            
            if track == playQueueDelegate.currentTrack {
                return builder.withImage(image: .imgPlayFilled, inColor: systemColorScheme.activeControlColor)
                
            } else {
                return builder.withText(text: "\(row + 1)",
                                        inFont: systemFontScheme.playlist.trackTextFont, andColor: systemColorScheme.tertiaryTextColor,
                                        selectedTextColor: systemColorScheme.tertiarySelectedTextColor)
            }
            
        case .cid_trackName:
            
            let titleAndArtist = track.titleAndArtist
            
            if let artist = titleAndArtist.artist {
                
                return builder.withAttributedText(strings: [(text: artist + "  ", font: systemFontScheme.playlist.trackTextFont, color: systemColorScheme.secondaryTextColor),
                                                            (text: titleAndArtist.title, font: systemFontScheme.playlist.trackTextFont, color: systemColorScheme.primaryTextColor)],
                                                  selectedTextColors: [systemColorScheme.secondarySelectedTextColor, systemColorScheme.primarySelectedTextColor],
                                                  bottomYOffset: systemFontScheme.playQueueYOffset)
                
            } else {
                
                return builder.withAttributedText(strings: [(text: titleAndArtist.title,
                                                             font: systemFontScheme.playlist.trackTextFont,
                                                             color: systemColorScheme.primaryTextColor)], selectedTextColors: [systemColorScheme.primarySelectedTextColor],
                                                  bottomYOffset: systemFontScheme.playQueueYOffset)
            }
            
        case .cid_duration:
            
            return builder.withText(text: ValueFormatter.formatSecondsToHMS(track.duration),
                                    inFont: systemFontScheme.playlist.trackTextFont, andColor: systemColorScheme.tertiaryTextColor,
                                    selectedTextColor: systemColorScheme.tertiarySelectedTextColor)
            
        default:
            
            return .noCell
        }
    }
}
