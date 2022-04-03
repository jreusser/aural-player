//
//  FlatPlaylistTableViews.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

/*
    A customized NSTableView that overrides contextual menu behavior
 */
class AuralTableView: NSTableView {
    
    // Enable drag/drop.
    override func awakeFromNib() {
        
        super.awakeFromNib()
        enableDragDrop()
    }
    
    override func menu(for event: NSEvent) -> NSMenu? {
        menuHandler(for: event)
    }
    
    private var uiState: PlaylistUIState {objectGraph.playlistUIState}
    
    // TODO: Rethink the right-click menu for playlists (should have different menus for single item / multi-item / empty selections)
    /*
        An event handler for customized contextual menu behavior.
        This function needs to be overriden in order to:
     
        1 - Only display the contextual menu when at least one row is available, and the click occurred within a playlist row view (i.e. not in empty table view space)
        2 - Capture the row for which the contextual menu was requested, and select it
        3 - Disable the row highlight displayed when presenting the contextual menu
     */
    func menuHandler(for event: NSEvent) -> NSMenu? {
        
        // If tableView has no rows, don't show the menu
        if self.numberOfRows == 0 {return nil}
        
        // Calculate the clicked row
        let row = self.row(at: self.convert(event.locationInWindow, from: nil))
        
        // If the click occurred outside of any of the playlist rows (i.e. empty space), don't show the menu
        if row == -1 {return nil}
        
        // Select the clicked row, implicitly clearing the previous selection
        selectRow(row)
        
        // TODO: Shouldn't this be moved to AuralPlaylistTableView and AuralPlaylistOutlineView ?
        // Note that this view was clicked (this is required by the contextual menu)
        uiState.registerTableViewClick(self)
        
        return self.menu
    }
}

/*
    Custom view for a NSTableView row that displays a single playlist track or group. Customizes the selection look and feel.
 */
class PlaylistRowView: NSTableRowView {
    
    // Draws a fancy rounded rectangle around the selected track in the playlist view
    override func drawSelection(in dirtyRect: NSRect) {
        
        if self.selectionHighlightStyle != .none {
            
//            NSBezierPath.fillRoundedRect(self.bounds.insetBy(dx: 1, dy: 0),
//                                         radius: 2,
//                                         withColor: Colors.Playlist.selectionBoxColor)
        }
    }
}

class BasicFlatPlaylistCellView: NSTableCellView {
    
    // Used to determine whether or not this cell is selected.
    var rowSelectionStateFunction: () -> Bool = {false}
    
    var rowIsSelected: Bool {rowSelectionStateFunction()}
    
    lazy var textFieldConstraintsManager = LayoutConstraintsManager(for: textField!)
    
    func updateText(_ font: NSFont, _ text: String) {
        
        textFont = font
        self.text = text
        textField?.show()
        
        imageView?.hide()
    }
    
    func updateImage(_ image: NSImage, color: NSColor) {
        
        self.image = image
        
        imageView?.contentTintColor = color
        imageView?.show()
        
        textField?.hide()
    }

    // Constraints
    func realignText(yOffset: CGFloat) {

        textFieldConstraintsManager.removeAll(withAttributes: [.bottom])
        textFieldConstraintsManager.setBottom(relatedToBottomOf: self, offset: yOffset)
    }
    
    override var backgroundStyle: NSView.BackgroundStyle {
        didSet {backgroundStyleChanged()}
    }

    // Check if this row is selected, change font and color accordingly
    func backgroundStyleChanged() {
        
//        textColor = rowIsSelected ? Colors.Playlist.trackNameSelectedTextColor : Colors.Playlist.trackNameTextColor
        textFont = Fonts.Playlist.trackTextFont
    }
}

/*
    Custom view for a single NSTableView cell. Customizes the look and feel of cells (in selected rows) - font and text color.
 */
@IBDesignable
class TrackNameCellView: BasicFlatPlaylistCellView {}

/*
    Custom view for a single NSTableView cell. Customizes the look and feel of cells (in selected rows) - font and text color.
 */
@IBDesignable
class DurationCellView: BasicFlatPlaylistCellView {
    
    override func backgroundStyleChanged() {
        
//        let isSelectedRow = rowIsSelected
//
//        // Check if this row is selected, change font and color accordingly
//        textField?.textColor = isSelectedRow ? Colors.Playlist.indexDurationSelectedTextColor : Colors.Playlist.indexDurationTextColor
        textField?.font = Fonts.Playlist.trackTextFont
    }
}

/*
    Custom view for a single NSTableView cell. Customizes the look and feel of cells (in selected rows) - font and text color.
 */
class IndexCellView: BasicFlatPlaylistCellView {
    
    override func backgroundStyleChanged() {
        
        // Check if this row is selected, change font and color accordingly
//        textField?.textColor = rowIsSelected ? Colors.Playlist.indexDurationSelectedTextColor : Colors.Playlist.indexDurationTextColor
        textField?.font = Fonts.Playlist.trackTextFont
    }
}
