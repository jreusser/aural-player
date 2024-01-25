//
//  TuneBrowserUIState.swift
//  Aural
//
//  Copyright © 2023 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//

import Foundation
import OrderedCollections

class TuneBrowserUIState {
    
    var displayedColumns: [TuneBrowserTableColumn] = []
    
    static let defaultSortColumn: String = "name"
    var sortColumn: String
    
    static let defaultSortIsAscending: Bool = true
    var sortIsAscending: Bool
    
    private(set) var sidebarUserFolders: [TuneBrowserSidebarItem] = []
    
    init(persistentState: TuneBrowserUIPersistentState?) {

        displayedColumns = persistentState?.displayedColumns?.compactMap {TuneBrowserTableColumn(persistentState: $0)} ?? []
        sortColumn = persistentState?.sortColumn ?? Self.defaultSortColumn
        sortIsAscending = persistentState?.sortIsAscending ?? Self.defaultSortIsAscending

        // TODO: Initialize user folders from FileSystem after Library is loaded (listen for notif ???)
//        for path in (persistentState?.sidebar?.userFolders ?? []).compactMap({$0.url}) {
//            addUserFolder(forURL: path)
//        }
    }

    var persistentState: TuneBrowserUIPersistentState {

        TuneBrowserUIPersistentState(displayedColumns: displayedColumns.map {TuneBrowserTableColumnPersistentState(id: $0.id, width: $0.width)},
                                     sortColumn: sortColumn,
                                     sortIsAscending: sortIsAscending,
                                     sidebar: TuneBrowserSidebarPersistentState(userFolders: sidebarUserFolders.map {TuneBrowserSidebarItemPersistentState(folderURL: $0.folder.url, treeURL: $0.tree.rootURL)}))
    }
    
    func addUserFolder(_ folder: FileSystemFolderItem, inTree tree: FileSystemTree) {
        
//        if sidebarUserFolders[url] == nil {
//            sidebarUserFolders[url] = TuneBrowserSidebarItem(url: url)
//        }
        sidebarUserFolders.append(TuneBrowserSidebarItem(folder: folder, tree: tree))
    }
    
    func removeUserFolder(item: TuneBrowserSidebarItem) -> Int? {
        
//        let index = sidebarUserFolders.index(forKey: item.url)
//        sidebarUserFolders.removeValue(forKey: item.url)
//        return index
        nil
    }
}

struct TuneBrowserTableColumn {
    
    let id: String
    let width: CGFloat
    
    init(id: String, width: CGFloat) {
        
        self.id = id
        self.width = width
    }
    
    init?(persistentState: TuneBrowserTableColumnPersistentState) {

        guard let id = persistentState.id, let width = persistentState.width else {return nil}

        self.id = id
        self.width = width
    }
}
