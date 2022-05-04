////
////  GroupingPlaylistTableViews.swift
////  Aural
////
////  Copyright © 2021 Kartik Venugopal. All rights reserved.
////
////  This software is licensed under the MIT software license.
////  See the file "LICENSE" in the project root directory for license terms.
////
//import Cocoa
//
///*
//    A customized NSOutlineView that overrides contextual menu behavior
// */
//class AuralPlaylistOutlineView: NSOutlineView, Destroyable {
//    
//    static var disclosureButtons: [NSButton] = []
//    
//    // Enable drag/drop.
//    override func awakeFromNib() {
//        
//        super.awakeFromNib()
//        enableDragDrop()
//    }
//    
//    static func destroy() {
//        disclosureButtons.removeAll()
//    }
//    
//    static func changeDisclosureTriangleColor(_ color: NSColor) {
//        
//        for button in disclosureButtons {
//            button.contentTintColor = color
//        }
//    }
//    
//    override func menu(for event: NSEvent) -> NSMenu? {
//        return menuHandler(for: event)
//    }
//    
////    private var uiState: PlaylistUIState {objectGraph.playlistUIState}
//    
//    /*
//        An event handler for customized contextual menu behavior.
//        This function needs to be overriden in order to:
//     
//        1 - Only display the contextual menu when at least one row is available, and the click occurred within a playlist row view (i.e. not in empty table view space)
//        2 - Capture the row for which the contextual menu was requested, and select it
//        3 - Disable the row highlight displayed when presenting the contextual menu
//     */
//    func menuHandler(for event: NSEvent) -> NSMenu? {
//        
//        // If tableView has no rows, don't show the menu
//        if self.numberOfRows == 0 {return nil}
//        
//        // Calculate the clicked row
//        let row = self.row(at: self.convert(event.locationInWindow, from: nil))
//        
//        // If the click occurred outside of any of the playlist rows (i.e. empty space), don't show the menu
//        if row == -1 {return nil}
//        
//        // Select the clicked row, implicitly clearing the previous selection
//        selectRow(row)
//        
//        // TODO: Shouldn't this be moved to AuralPlaylistTableView and AuralPlaylistOutlineView ?
//        // Note that this view was clicked (this is required by the contextual menu)
////        uiState.registerTableViewClick(self)
//        
//        return self.menu
//    }
//    
//    // Customize the disclosure triangle image
//    override func makeView(withIdentifier identifier: NSUserInterfaceItemIdentifier, owner: Any?) -> NSView? {
//        
//        let view = super.makeView(withIdentifier: identifier, owner: owner)
//        
//        if identifier == NSOutlineView.disclosureButtonIdentifier, let disclosureButton = view as? NSButton {
//            
//            disclosureButton.image = .imgDisclosure_collapsed
//            disclosureButton.image?.isTemplate = true
//            
//            disclosureButton.alternateImage = .imgDisclosure_expanded
//            disclosureButton.alternateImage?.isTemplate = true
//            
//            Self.disclosureButtons.append(disclosureButton)
//        }
//        
//        return view
//    }
//}
//
//class GroupingPlaylistRowView: AuralTableRowView {
//    
//    override func didAddSubview(_ subview: NSView) {
//        
//        if let disclosureButton = subview as? NSButton {
//            
//            disclosureButton.translatesAutoresizingMaskIntoConstraints = false
//            
//            NSLayoutConstraint.activate([
//                disclosureButton.topAnchor.constraint(equalTo: topAnchor, constant: 12),
//                disclosureButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10)
//            ])
//        }
//        
//        super.didAddSubview(subview)
//    }
//}
//
//class GroupedItemCellView: NSTableCellView {
//    
//    // Used to determine whether or not this cell is selected.
//    var rowSelectionStateFunction: () -> Bool = {false}
//    
//    var rowIsSelected: Bool {rowSelectionStateFunction()}
//    
//    // Whether or not this cell is contained within a row that represents a group (as opposed to a track)
//    var isGroup: Bool = false
//    
//    // This is used to determine which NSOutlineView contains this cell
//    var playlistType: PlaylistType = .artists
//    
//    lazy var textFieldConstraintsManager = LayoutConstraintsManager(for: textField!)
//    
//    func updateText(_ font: NSFont, _ text: String) {
//        
//        self.textFont = font
//        self.text = text
//        textField?.show()
//    }
//    
//    // Constraints
//    func realignText(yOffset: CGFloat) {
//        
//        textFieldConstraintsManager.removeAll(withAttributes: [.bottom])
//        textFieldConstraintsManager.setBottom(relatedToBottomOf: self, offset: yOffset)
//    }
//}
//
//class GroupedItemNameCellView: GroupedItemCellView {
//    
//    lazy var imgViewConstraintsManager = LayoutConstraintsManager(for: imageView!)
//    
//    // When the background changes (as a result of selection/deselection) switch to the appropriate colors/fonts
//    override var backgroundStyle: NSView.BackgroundStyle {
//        
//        didSet {
//            
//            // Check if this row is selected
////            textColor = rowIsSelected ?
////                isGroup ? Colors.Playlist.groupNameSelectedTextColor : Colors.Playlist.trackNameSelectedTextColor :
////                isGroup ? Colors.Playlist.groupNameTextColor : Colors.Playlist.trackNameTextColor
//
//            textFont = isGroup ? Fonts.Playlist.groupTextFont : Fonts.Playlist.trackTextFont
//        }
//    }
//    
//    func reActivateConstraints(imgViewCenterY: CGFloat, imgViewLeading: CGFloat, textFieldLeading: CGFloat) {
//        
//        textFieldConstraintsManager.removeAll(withAttributes: [.leading])
//        imgViewConstraintsManager.removeAll(withAttributes: [.centerY, .leading])
//        
//        textFieldConstraintsManager.setLeading(relatedToTrailingOf: imageView!, offset: textFieldLeading)
//        
//        imgViewConstraintsManager.centerVerticallyInSuperview(offset: imgViewCenterY)
//        imgViewConstraintsManager.setLeading(relatedToLeadingOf: self, offset: imgViewLeading)
//    }
//}
//
///*
//    Custom view for a single NSTableView self. Customizes the look and feel of cells (in selected rows) - font and text color.
// */
//class GroupedItemDurationCellView: GroupedItemCellView {
//    
//    // When the background changes (as a result of selection/deselection) switch to the appropriate colors/fonts
//    override var backgroundStyle: NSView.BackgroundStyle {
//        
//        didSet {
//            
//            let isSelectedRow = rowIsSelected
//            
////            textColor = isSelectedRow ? Colors.Playlist.indexDurationSelectedTextColor : Colors.Playlist.indexDurationTextColor
//            textFont = isGroup ? Fonts.Playlist.groupTextFont : Fonts.Playlist.trackTextFont
//        }
//    }
//}
