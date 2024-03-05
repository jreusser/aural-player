//
//  BookmarksManagerViewController.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

class BookmarksManagerViewController: NSViewController {
    
    override var nibName: String? {"BookmarksManager"}
    
    @IBOutlet weak var containerBox: NSBox!
    
    @IBOutlet weak var lblCaption: NSTextField!
    @IBOutlet weak var tableView: NSTableView!
    @IBOutlet weak var lblSummary: NSTextField!
    
    lazy var messenger: Messenger = .init(for: self)
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        updateSummary()
        
        fontSchemesManager.registerObserver(self)
        
        colorSchemesManager.registerSchemeObserver(self)
        colorSchemesManager.registerPropertyObserver(self, forProperty: \.backgroundColor, changeReceivers: [containerBox, tableView])
        colorSchemesManager.registerPropertyObserver(self, forProperty: \.captionTextColor, changeReceiver: lblCaption)
        colorSchemesManager.registerPropertyObserver(self, forProperty: \.secondaryTextColor, changeReceiver: lblSummary)
        
        messenger.subscribe(to: .Bookmarks.added, handler: updateSummary)
        messenger.subscribe(to: .Bookmarks.removed, handler: updateSummary)
    }
    
    func updateSummary() {
        
        let numBookmarks = bookmarksDelegate.count
        lblSummary.stringValue = "\(numBookmarks)  \(numBookmarks == 1 ? "bookmark" : "bookmarks")"
    }
}

extension BookmarksManagerViewController: NSTableViewDataSource, NSTableViewDelegate {
    
    func numberOfRows(in tableView: NSTableView) -> Int {bookmarksDelegate.count}
    
    func tableView(_ tableView: NSTableView, rowViewForRow row: Int) -> NSTableRowView? {
        AuralTableRowView()
    }

//    override func renamePreset(named name: String, to newName: String) {
//        bookmarksDelegate.renameBookmark(named: name, to: newName)
//    }
//    
    // MARK: View delegate functions
    
    // Returns a view for a single column
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        guard let colID = tableColumn?.identifier else {return nil}
        
        let bookmark = bookmarksDelegate.getBookmarkAtIndex(row)
        
//        switch colID {
//            
//        case .cid_bookmarkNameColumn:
//            
//            return createTextCell(tableView, tableColumn!, row, bookmark.name, true)
//            
//        case .cid_bookmarkTrackColumn:
//            
//            return createTextCell(tableView, tableColumn!, row, bookmark.track.file.path, false)
//            
//        case .cid_bookmarkStartPositionColumn:
//            
//            let formattedPosition = ValueFormatter.formatSecondsToHMS(bookmark.startPosition)
//            return createTextCell(tableView, tableColumn!, row, formattedPosition, false)
//            
//        case .cid_bookmarkEndPositionColumn:
//            
//            var formattedPosition: String = ""
//            
//            if let endPos = bookmark.endPosition {
//                formattedPosition = ValueFormatter.formatSecondsToHMS(endPos)
//            } else {
//                formattedPosition = "-"
//            }
//            
//            return createTextCell(tableView, tableColumn!, row, formattedPosition, false)
//            
//        default:    return nil
//            
//        }
        return nil
    }
    
    // Renames the selected preset.
    func controlTextDidEndEditing(_ obj: Notification) {
        
        let rowIndex = tableView.selectedRow
        let rowView = tableView.rowView(atRow: rowIndex, makeIfNecessary: true)

        guard let cell = rowView?.view(atColumn: 0) as? NSTableCellView,
              let editedTextField = cell.textField else {return}
        
        let oldPresetName = bookmarksDelegate.getBookmarkAtIndex(rowIndex).name
        let newPresetName = editedTextField.stringValue
        
        // No change in preset name. Nothing to be done.
        if newPresetName == oldPresetName {return}
        
        editedTextField.textColor = .defaultSelectedLightTextColor
        
        // Empty string is invalid, revert to old value
//        if newPresetName.isEmptyAfterTrimming {
//            
//            editedTextField.stringValue = oldPresetName
//            
//            _ = DialogsAndAlerts.genericErrorAlert("Can't rename preset", "Preset name must have at least one non-whitespace character.", "Please type a valid name.").showModal()
//            
//        } else if presetExists(named: newPresetName) {
//            
//            // Another theme with that name exists, can't rename
//            editedTextField.stringValue = oldPresetName
//            
//            _ = DialogsAndAlerts.genericErrorAlert("Can't rename preset", "Another preset with that name already exists.", "Please type a unique name.").showModal()
//            
//        } else {
//            
//            // Update the preset name
//            renamePreset(named: oldPresetName, to: newPresetName)
//        }
    }
}

extension BookmarksManagerViewController: FontSchemeObserver {
    
    func fontSchemeChanged() {
        
        lblCaption.font = systemFontScheme.captionFont
        lblSummary.font = systemFontScheme.smallFont
    }
}

extension BookmarksManagerViewController: ColorSchemeObserver {
    
    func colorSchemeChanged() {
        
        lblCaption.textColor = systemColorScheme.captionTextColor
        lblSummary.textColor = systemColorScheme.secondaryTextColor
    }
}

extension NSUserInterfaceItemIdentifier {
    
    // Table view column identifiers
    
    static let cid_bookmarkNameColumn: NSUserInterfaceItemIdentifier = NSUserInterfaceItemIdentifier("cid_BookmarkName")
    static let cid_bookmarkTrackColumn: NSUserInterfaceItemIdentifier = NSUserInterfaceItemIdentifier("cid_BookmarkTrack")
    static let cid_bookmarkStartPositionColumn: NSUserInterfaceItemIdentifier = NSUserInterfaceItemIdentifier("cid_BookmarkStartPosition")
    static let cid_bookmarkEndPositionColumn: NSUserInterfaceItemIdentifier = NSUserInterfaceItemIdentifier("cid_BookmarkEndPosition")
}
