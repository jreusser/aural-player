//
//  TrackInfoViewDelegate.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

typealias KeyValuePair = (key: String, value: String)

/*
    Data source and delegate for the Detailed Track Info popover view
 */
class TrackInfoViewDelegate: NSObject, NSTableViewDataSource, NSTableViewDelegate {
    
    // The table view that displays the track info
    @IBOutlet weak var table: NSTableView!
    
    // Container for the key-value pairs of info displayed
    var keyValuePairs: [KeyValuePair] = []
    
    let value_unknown: String = "<Unknown>"
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        
        if let track = TrackInfoViewContext.displayedTrack {
            
            // A track is playing, add its info to the info array, as key-value pairs
            keyValuePairs = infoForTrack(track)
            return keyValuePairs.count
        }
        
        return 0
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        guard let columnId = tableColumn?.identifier,
              let cell = tableView.makeView(withIdentifier: columnId, owner: nil) as? NSTableCellView else {return nil}
        
        let kvPair = keyValuePairs[row]
        
        switch columnId {
        
        case .cid_trackInfoKeyColumn:
            
            cell.text = "\(kvPair.key):"
            cell.textFont = systemFontScheme.normalFont
            cell.textColor = systemColorScheme.secondaryTextColor
            return cell
            
        case .cid_trackInfoValueColumn:
            
            cell.text = kvPair.value
            cell.textFont = systemFontScheme.normalFont
            cell.textColor = systemColorScheme.primaryTextColor
            return cell
            
        default:
            
            return nil
        }
    }
    
    // Adjust row height based on if the text wraps over to the next line
    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        30
    }
    
    ///
    /// Disables drawing of the row selection marker.
    ///
    func tableView(_ tableView: NSTableView, rowViewForRow row: Int) -> NSTableRowView? {
        TrackInfoRowView()
    }
    
    // Should be overriden by subclasses.
    func infoForTrack(_ track: Track) -> [KeyValuePair] {[]}
}

///
/// Custom view for a NSTableView row that displays a single row of track info (eg. metadata). Customizes the selection look and feel.
///
class TrackInfoRowView: NSTableRowView {
    
    /// Draws nothing (i.e. disables drawing of the row selection marker).
    override func drawSelection(in dirtyRect: NSRect) {}
}

extension NSUserInterfaceItemIdentifier {
    
    // Table view column identifiers
    static let cid_trackInfoKeyColumn: NSUserInterfaceItemIdentifier = NSUserInterfaceItemIdentifier("cid_TrackInfoKey")
    static let cid_trackInfoValueColumn: NSUserInterfaceItemIdentifier = NSUserInterfaceItemIdentifier("cid_TrackInfoValue")
}
