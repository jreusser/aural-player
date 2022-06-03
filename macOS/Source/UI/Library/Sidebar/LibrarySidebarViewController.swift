//
//  LibrarySidebarViewController.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import Cocoa

class LibrarySidebarViewController: NSViewController, NSOutlineViewDelegate, NSOutlineViewDataSource {
    
    override var nibName: String? {"LibrarySidebar"}
    
    @IBOutlet weak var sidebarView: NSOutlineView!
    
    let categories: [LibrarySidebarCategory] = LibrarySidebarCategory.allCases
    
    private lazy var messenger: Messenger = Messenger(for: self)
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        categories.forEach {sidebarView.expandItem($0)}
        sidebarView.selectRow(7)
        
        messenger.subscribe(to: .librarySidebar_addFileSystemShortcut, handler: addFileSystemShortcut)
        
        colorSchemesManager.registerObserver(sidebarView, forProperty: \.backgroundColor)
    }
    
    func outlineView(_ outlineView: NSOutlineView, heightOfRowByItem item: Any) -> CGFloat {
        item is LibrarySidebarCategory ? 31: 27
    }
    
    func outlineView(_ outlineView: NSOutlineView, rowViewForItem item: Any) -> NSTableRowView? {
        LibrarySidebarRowView()
    }
    
    func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
        
        if item == nil {
            return categories.count
            
        } else if let sidebarCat = item as? LibrarySidebarCategory {
            return sidebarCat.numberOfItems
        }
        
        return 0
    }
    
    func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
        
        if item == nil {
            return categories[index]
            
        } else if let sidebarCat = item as? LibrarySidebarCategory {
            return sidebarCat.items[index]
        }
        
        return ""
    }
    
    func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
        item is LibrarySidebarCategory && (sidebarView.numberOfChildren(ofItem: item) > 0)
    }
    
    func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {
        
        if let category = item as? LibrarySidebarCategory {
            return createNameCell(outlineView, category.description, font: systemFontScheme.playQueuePrimaryFont, textColor: systemColorScheme.secondaryTextColor, image: category.image)
            
        } else if let sidebarItem = item as? LibrarySidebarItem {
            return createNameCell(outlineView, sidebarItem.displayName, font: systemFontScheme.playQueuePrimaryFont, textColor: systemColorScheme.primaryTextColor, image: sidebarItem.image)
        }
        
        return nil
    }
    
    private func createNameCell(_ outlineView: NSOutlineView, _ text: String, font: NSFont, textColor: NSColor, image: NSImage? = nil) -> NSTableCellView? {
        
        guard let cell = outlineView.makeView(withIdentifier: NSUserInterfaceItemIdentifier("name"), owner: nil)
            as? NSTableCellView else {return nil}
        
        cell.imageView?.image = nil

        cell.text = text
        cell.textFont = font
        cell.textColor = textColor
        
        cell.image = image
        cell.imageColor = textColor
        
        return cell
    }
    
    func outlineView(_ outlineView: NSOutlineView, shouldSelectItem item: Any) -> Bool {
        !(item is LibrarySidebarCategory) || (sidebarView.numberOfChildren(ofItem: item) == 0)
    }
    
    private var respondToSelectionChange: Bool = true

    func outlineViewSelectionDidChange(_ notification: Notification) {
        
        guard respondToSelectionChange, let outlineView = notification.object as? NSOutlineView else {return}
        
        let item = outlineView.item(atRow: outlineView.selectedRow)
        
        if let selectedItem = item as? LibrarySidebarItem {
            messenger.publish(.library_showBrowserTabForItem, payload: selectedItem)
            
        } else if let selectedCategory = item as? LibrarySidebarCategory {
            messenger.publish(.library_showBrowserTabForCategory, payload: selectedCategory)
        }
    }
    
    @IBAction func doubleClickAction(_ sender: NSOutlineView) {
        
        guard let sidebarItem = sidebarView.selectedItem as? LibrarySidebarItem else {return}
        
        if sidebarItem.browserTab == .playlists,
            let playlist = playlistsManager.userDefinedObject(named: sidebarItem.displayName) {
            
            messenger.publish(EnqueueAndPlayNowCommand(tracks: playlist.tracks, clearPlayQueue: false))
        }
    }
    
    private func addFileSystemShortcut() {
        
        respondToSelectionChange = false
        sidebarView.reloadDataMaintainingSelection()
        respondToSelectionChange = true
    }
}

class LibrarySidebarRowView: AuralTableRowView {

    override func didAddSubview(_ subview: NSView) {

        if let disclosureButton = subview as? NSButton {

            disclosureButton.translatesAutoresizingMaskIntoConstraints = false

            NSLayoutConstraint.activate([
                disclosureButton.topAnchor.constraint(equalTo: topAnchor, constant: 10),
                disclosureButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 7)
            ])
        }

        super.didAddSubview(subview)
    }
}
