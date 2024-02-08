//
//  NSTableViewExtensions.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

extension NSTableView {
    
    func enableDragDrop() {
        registerForDraggedTypes([.data, .fileURL])
    }
    
    func setBackgroundColor(_ color: PlatformColor) {
        
        backgroundColor = color
        enclosingScrollView?.backgroundColor = color
        
        if let clipView = enclosingScrollView?.documentView as? NSClipView {
            clipView.backgroundColor = color
        }
    }
    
    func isRowSelected(_ row: Int) -> Bool {
        selectedRowIndexes.contains(row)
    }
    
    func selectRow(_ row: Int) {
        selectRowIndexes(IndexSet(integer: row), byExtendingSelection: false)
    }
    
    func selectRows(_ rows: [Int]) {
        selectRowIndexes(IndexSet(rows), byExtendingSelection: false)
    }
    
    func selectRows(_ rows: IndexSet) {
        selectRowIndexes(rows, byExtendingSelection: false)
    }
    
    func redoRowSelection() {

        // Note down the selected rows, clear the selection, and re-select the originally selected rows
        // (to trigger a repaint of the selection boxes).
        
        let selRows = selectedRowIndexes
        
        if !selRows.isEmpty {
            
            selectRowIndexes(IndexSet([]), byExtendingSelection: false)
            selectRowIndexes(selRows, byExtendingSelection: false)
        }
    }
    
    func selectRows(_ rows: Range<Int>) {
        selectRowIndexes(IndexSet(rows), byExtendingSelection: false)
    }
    
    func selectRows(_ rows: ClosedRange<Int>) {
        selectRowIndexes(IndexSet(rows), byExtendingSelection: false)
    }
    
    func selectAllItems() {
        selectRowIndexes(allRowIndices, byExtendingSelection: false)
    }
    
    func clearSelection() {
        selectRowIndexes(IndexSet([]), byExtendingSelection: false)
    }
    
    func invertSelection() {
        selectRowIndexes(invertedSelection, byExtendingSelection: false)
    }
    
    var invertedSelection: IndexSet {
        IndexSet((0..<numberOfRows).filter {!selectedRowIndexes.contains($0)})
    }
    
    var allRowIndices: IndexSet {IndexSet(0..<numberOfRows)}
    
    var allColumnIndices: IndexSet {IndexSet(0..<numberOfColumns)}
    
    func reloadRows(_ rows: [Int]) {
        reloadData(forRowIndexes: IndexSet(rows), columnIndexes: allColumnIndices)
    }
    
    func reloadRows(_ rows: Range<Int>) {
        reloadData(forRowIndexes: IndexSet(rows), columnIndexes: allColumnIndices)
    }
    
    func reloadRows(_ rows: ClosedRange<Int>) {
        reloadData(forRowIndexes: IndexSet(rows), columnIndexes: allColumnIndices)
    }
    
    func reloadRows(_ rows: ClosedRange<Int>, columns: [Int]) {
        reloadData(forRowIndexes: IndexSet(rows), columnIndexes: IndexSet(columns))
    }
    
    func reloadRows(_ rows: IndexSet) {
        reloadData(forRowIndexes: rows, columnIndexes: allColumnIndices)
    }
    
    func reloadRows(_ rows: [Int], columns: [Int]) {
        reloadData(forRowIndexes: IndexSet(rows), columnIndexes: IndexSet(columns))
    }
    
    func reloadRows(_ rows: IndexSet, columns: [Int]) {
        reloadData(forRowIndexes: rows, columnIndexes: IndexSet(columns))
    }
    
    func reloadAllRows(columns: [Int]) {
        reloadData(forRowIndexes: allRowIndices, columnIndexes: IndexSet(columns))
    }
    
    func reloadDataMaintainingSelection() {
        
        let selectedRows = selectedRowIndexes
        reloadData()
        selectRowIndexes(selectedRows, byExtendingSelection: false)
    }
    
    func pageUp() {
        
        guard self.numberOfRows > 3 else {return}
        
        // Determine if the last row currently displayed has been truncated so it is not fully visible
        let visibleRect = self.visibleRect
        let visibleRows = self.rows(in: visibleRect)
        let numVisibleRows = Int(visibleRect.height / heightOfARow)
        
        let firstRowShown = visibleRows.lowerBound
        let firstRowShownRect = self.rect(ofRow: firstRowShown)
        let firstRowShownFully = CGRectContainsRect(visibleRect, firstRowShownRect)
        
        // If the first row currently displayed has been truncated more than 10%, show it again in the next page

        let lastRowToShow = firstRowShownFully ? firstRowShown - 1 : firstRowShown
        let scrollRow = max(lastRowToShow - numVisibleRows + 1, 0)

        scrollRowToVisible(scrollRow)
    }
    
    var heightOfARow: CGFloat {self.rect(ofRow: 0).height}
    
    func pageDown() {
        
        guard self.numberOfRows > 3 else {return}
        
        // Determine if the last row currently displayed has been truncated so it is not fully visible
        let visibleRect = self.visibleRect
        let visibleRows = self.rows(in: visibleRect)
        let numVisibleRows = Int(visibleRect.height / heightOfARow)
        
        let lastRowShown = visibleRows.lowerBound + visibleRows.length - 1
        let lastRowShownRect = self.rect(ofRow: lastRowShown)
        let lastRowShownFully = CGRectContainsRect(visibleRect, lastRowShownRect)
        
        let firstRowToShow = lastRowShownFully ? lastRowShown + 1 : lastRowShown
        let scrollRow = min(firstRowToShow + numVisibleRows - 1, self.numberOfRows - 1)
        
        scrollRowToVisible(scrollRow)
    }
    
    // Scrolls the playlist view to the very top
    func scrollToTop() {
        
        if numberOfRows > 0 {
            scrollRowToVisible(0)
        }
    }
    
    // Scrolls the playlist view to the very bottom
    func scrollToBottom() {
        
        if numberOfRows > 0 {
            scrollRowToVisible(numberOfRows - 1)
        }
    }
    
    func customizeHeader<C>(heightIncrease: CGFloat, customCellType: C.Type) where C: NSTableHeaderCell {
        
        guard let header = headerView else {return}
        
        header.resize(header.width, header.height + heightIncrease)
        
        if let clipView = enclosingScrollView?.documentView as? NSClipView {
            clipView.resize(clipView.width, clipView.height + heightIncrease)
        }
        
        header.wantsLayer = true
        header.layer?.backgroundColor = .black
        
        tableColumns.forEach {
            
            let col = $0
            let header = C.init()
            
            header.stringValue = col.headerCell.stringValue
            header.isBordered = false
            
            col.headerCell = header
        }
    }
}

extension NSTableView: ColorSchemePropertyChangeReceiver {
    
    func colorSchemeChanged() {
        
        setBackgroundColor(systemColorScheme.backgroundColor)
        reloadDataMaintainingSelection()
    }
    
    func colorChanged(_ newColor: PlatformColor) {
        setBackgroundColor(newColor)
    }
    
//    func colorChanged(to newColor: PlatformColor, forProperty property: ColorSchemeProperty) {
//        
//        switch property {
//            
//        case \.backgroundColor:
//            setBackgroundColor(newColor)
//            
//        case \.primaryTextColor, \.secondaryTextColor, \.tertiaryTextColor, \.primarySelectedTextColor, \.secondarySelectedTextColor, \.tertiarySelectedTextColor:
//            reloadData()
//            
//        default:
//            return
//        }
//    }
}

extension NSTableView: FontSchemeObserver {
    
    func fontSchemeChanged() {
        reloadData()
    }
    
    func fontChanged(to newFont: PlatformFont, forProperty property: KeyPath<FontScheme, PlatformFont>) {
        reloadData()
    }
}

extension NSOutlineView {
    
    func isItemSelected(_ item: Any) -> Bool {
        selectedRowIndexes.contains(row(forItem: item))
    }
    
    var selectedItem: Any? {
        item(atRow: selectedRow)
    }
    
    var selectedItems: [Any] {
        selectedRowIndexes.compactMap {item(atRow: $0)}
    }
    
    var selectedFileSystemItemURLs: [URL] {
        selectedItems.compactMap {($0 as? FileSystemItem)?.url}
    }
    
    func selectItems(_ items: [Any]) {
        selectRows(items.map {row(forItem: $0)})
    }
}
