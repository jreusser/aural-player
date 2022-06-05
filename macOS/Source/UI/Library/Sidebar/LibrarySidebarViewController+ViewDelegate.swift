//
//  LibrarySidebarViewController+ViewDelegate.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import Cocoa

extension LibrarySidebarViewController: NSTableViewDelegate {
    
    func outlineView(_ outlineView: NSOutlineView, heightOfRowByItem item: Any) -> CGFloat {
        item is LibrarySidebarCategory ? 31: 27
    }
    
    func outlineView(_ outlineView: NSOutlineView, rowViewForItem item: Any) -> NSTableRowView? {
        LibrarySidebarRowView()
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
        
        if let category = item as? LibrarySidebarCategory {
            return category.equalsOneOf(.favorites, .bookmarks)
        }
        
        return true
    }
    
    func outlineViewSelectionDidChange(_ notification: Notification) {
        
        guard respondToSelectionChange, let outlineView = notification.object as? NSOutlineView else {return}
        
        let item = outlineView.item(atRow: outlineView.selectedRow)
        
        if let selectedItem = item as? LibrarySidebarItem {
            messenger.publish(.library_showBrowserTabForItem, payload: selectedItem)
            
        } else if let selectedCategory = item as? LibrarySidebarCategory {
            messenger.publish(.library_showBrowserTabForCategory, payload: selectedCategory)
        }
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
