//
//  CompactPlayQueueViewController.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import Cocoa

class CompactPlayQueueViewController: PlayQueueViewController {
    
    override var nibName: NSNib.Name? {"CompactPlayQueue"}
    
    @IBOutlet weak var lblTracksSummary: NSTextField!
    @IBOutlet weak var lblDurationSummary: NSTextField!
    
    override var playQueueView: PlayQueueView {
        .expanded
    }
    
    override var rowHeight: CGFloat {45}
    
    // MARK: Table view delegate / data source --------------------------------------------------------------------------------------------------------
    
    override func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        guard let track = track(forRow: row), let columnId = tableColumn?.identifier else {return nil}
        
        switch columnId {
            
        case .cid_index:
            
            let builder = TableCellBuilder()
            
            if track == playQueueDelegate.currentTrack {
                
                return builder.withImage(image: .imgPlayFilled, inColor: systemColorScheme.activeControlColor).buildCell(forTableView: tableView,
                                                                                                                         forColumnWithId: columnId, inRow: row)
                
            } else {
                
                return builder.withText(text: "\(row + 1)",
                                        inFont: systemFontScheme.smallFont, andColor: systemColorScheme.tertiaryTextColor,
                                        selectedTextColor: systemColorScheme.tertiarySelectedTextColor).buildCell(forTableView: tableView,
                                                                                                                  forColumnWithId: columnId, inRow: row)
            }
            
        case .cid_trackName:
            
            return createTrackNameCell(tableView: tableView, track: track, row: row)
            
        case .cid_duration:
            
            return createDurationCell(tableView: tableView, track: track, row: row)
            
        default:
            
            return nil
        }
    }
    
    private func createTrackNameCell(tableView: NSTableView, track: Track, row: Int) -> PlayQueueListTrackNameCell? {
        
        guard let cell = tableView.makeView(withIdentifier: .cid_trackName, owner: nil) as? PlayQueueListTrackNameCell else {return nil}
        cell.updateForTrack(track)
        cell.rowSelectionStateFunction = {[weak tableView] in
            tableView?.selectedRowIndexes.contains(row) ?? false
        }
        
        [cell.lblTitle, cell.lblArtistAlbum, cell.lblDefaultDisplayName].forEach {
            $0.font = systemFontScheme.smallFont
        }
        
        return cell
    }
    
    private func createDurationCell(tableView: NSTableView, track: Track, row: Int) -> AuralTableCellView? {
        
        return TableCellBuilder().withText(text: ValueFormatter.formatSecondsToHMS(track.duration),
                                           inFont: systemFontScheme.smallFont, andColor: systemColorScheme.tertiaryTextColor,
                                           selectedTextColor: systemColorScheme.tertiarySelectedTextColor)
            .buildCell(forTableView: tableView, forColumnWithId: .cid_duration, inRow: row)
    }
    
    override func updateSummary() {
        
        let tracksCardinalString = playQueueDelegate.size == 1 ? "track" : "tracks"
        
        if let playingTrackIndex = playQueueDelegate.currentTrackIndex {
            
            let playIconAttStr = "▶".attributed(font: futuristicFontSet.mainFont(size: 12), color: systemColorScheme.secondaryTextColor)
            let tracksSummaryAttStr = "  \(playingTrackIndex + 1) / \(playQueueDelegate.size) \(tracksCardinalString)".attributed(font: systemFontScheme.smallFont,
                                                                                                                                  color: systemColorScheme.secondaryTextColor)
            
            lblTracksSummary.attributedStringValue = playIconAttStr + tracksSummaryAttStr
            
        } else {
            
            lblTracksSummary.stringValue = "\(playQueueDelegate.size) \(tracksCardinalString)"
            lblTracksSummary.font = systemFontScheme.smallFont
            lblTracksSummary.textColor = systemColorScheme.secondaryTextColor
        }
        
        lblDurationSummary.stringValue = ValueFormatter.formatSecondsToHMS(playQueueDelegate.duration)
        lblDurationSummary.font = systemFontScheme.smallFont
        lblDurationSummary.textColor = systemColorScheme.secondaryTextColor
    }
    
    override func fontSchemeChanged() {
        
        super.fontSchemeChanged()
        updateSummary()
    }
    
    override func colorSchemeChanged() {
        
        super.colorSchemeChanged()
        updateSummary()
    }
}
