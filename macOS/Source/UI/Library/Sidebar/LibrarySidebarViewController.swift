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
    
    lazy var messenger: Messenger = Messenger(for: self)
    
    var respondToSelectionChange: Bool = true
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        categories.forEach {sidebarView.expandItem($0)}
        sidebarView.selectRow(7)
        
        messenger.subscribe(to: .librarySidebar_addFileSystemShortcut, handler: addFileSystemShortcut)
        
        colorSchemesManager.registerObserver(sidebarView, forProperty: \.backgroundColor)
    }
    
    @IBAction func doubleClickAction(_ sender: NSOutlineView) {
        
        guard let sidebarItem = sidebarView.selectedItem as? LibrarySidebarItem else {return}
        
        switch sidebarItem.browserTab {
            
        case .fileSystem:
            
            if let folder = sidebarItem.tuneBrowserURL {
                messenger.publish(LoadAndPlayNowCommand(files: [folder], clearPlayQueue: false))
            }
            
        case .playlists:
            
            if let playlist = playlistsManager.userDefinedObject(named: sidebarItem.displayName) {
                messenger.publish(EnqueueAndPlayNowCommand(tracks: playlist.tracks, clearPlayQueue: false))
            }
            
        default:
            
            return
        }
    }
    
    @IBAction func createEmptyPlaylistAction(_ sender: Any) {
        
        _ = playlistsManager.createNewPlaylist(named: uniquePlaylistName)
        sidebarView.reloadData()
        sidebarView.expandItem(LibrarySidebarCategory.playlists)
        
        let playlistCategoryIndex = sidebarView.row(forItem: LibrarySidebarCategory.playlists)
        let numPlaylists = playlistsManager.numberOfUserDefinedObjects
        let indexOfNewPlaylist = playlistCategoryIndex + numPlaylists
        
        sidebarView.selectRow(indexOfNewPlaylist)
        editTextField(inRow: indexOfNewPlaylist)
    }
    
    private func editTextField(inRow row: Int) {
        
        let rowView = sidebarView.rowView(atRow: row, makeIfNecessary: true)
        
        if let editedTextField = (rowView?.view(atColumn: 0) as? NSTableCellView)?.textField {
            view.window?.makeFirstResponder(editedTextField)
        }
    }
    
    private var uniquePlaylistName: String {
        
        var newPlaylistName: String = "New Playlist"
        var ctr: Int = 1
        
        while playlistsManager.userDefinedObjectExists(named: newPlaylistName) {
            
            ctr.increment()
            newPlaylistName = "New Playlist \(ctr)"
        }
        
        return newPlaylistName
    }
    
    private func addFileSystemShortcut() {
        
        sidebarView.insertItems(at: IndexSet(integer: tuneBrowserUIState.sidebarUserFolders.count),
                                inParent: LibrarySidebarCategory.tuneBrowser, withAnimation: .slideDown)
    }
}
