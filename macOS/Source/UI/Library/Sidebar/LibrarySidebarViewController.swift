//
//  LibrarySidebarViewController.swift
//  Aural
//
//  Copyright © 2023 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import Cocoa

class LibrarySidebarViewController: NSViewController {
    
    override var nibName: String? {"LibrarySidebar"}
    
    @IBOutlet weak var sidebarView: NSOutlineView!
    
    let categories: [LibrarySidebarCategory] = LibrarySidebarCategory.allCases
    
    lazy var messenger: Messenger = Messenger(for: self)
    
    var respondToSelectionChange: Bool = true
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        categories.forEach {sidebarView.expandItem($0)}
        sidebarView.selectRow(1)
        
        messenger.subscribe(to: .sidebar_addFileSystemShortcut, handler: addFileSystemShortcut)
        
        colorSchemesManager.registerObserver(sidebarView, forProperty: \.backgroundColor)
    }
    
    @IBAction func doubleClickAction(_ sender: NSOutlineView) {
        
        guard let sidebarItem = sidebarView.selectedItem as? LibrarySidebarItem else {return}
        
        switch sidebarItem.browserTab {
            
        case .fileSystem:
            
            if let folder = sidebarItem.tuneBrowserURL {
                messenger.publish(LoadAndPlayNowCommand(files: [folder], clearPlayQueue: false))
            }
            
        default:
            
            return
        }
    }
    
    @IBAction func createEmptyPlaylistAction(_ sender: Any) {
        
//        _ = playlistsManager.createNewPlaylist(named: uniquePlaylistName)
//        sidebarView.reloadData()
//        sidebarView.expandItem(LibrarySidebarCategory.playlists)
//        
//        let playlistCategoryIndex = sidebarView.row(forItem: LibrarySidebarCategory.playlists)
//        let numPlaylists = playlistsManager.numberOfUserDefinedObjects
//        let indexOfNewPlaylist = playlistCategoryIndex + numPlaylists
//        
//        sidebarView.selectRow(indexOfNewPlaylist)
//        editTextField(inRow: indexOfNewPlaylist)
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

extension LibrarySidebarViewController: NSTextFieldDelegate {
    
    func controlTextDidEndEditing(_ obj: Notification) {
        
//        let playlistCategoryRow = sidebarView.row(forItem: LibrarySidebarCategory.playlists)
//        let rowOfPlaylist = sidebarView.selectedRow
//        let indexOfPlaylist = rowOfPlaylist - playlistCategoryRow - 1
//        
//        guard let editedTextField = obj.object as? NSTextField else {return}
//        
//        let playlist = playlistsManager.userDefinedObjects[indexOfPlaylist]
//        let oldPlaylistName = playlist.name
//        let newPlaylistName = editedTextField.stringValue
//        
//        // No change in playlist name. Nothing to be done.
//        if newPlaylistName == oldPlaylistName {return}
//        
//        editedTextField.textColor = .defaultSelectedLightTextColor
//        
//        // If new name is empty or a playlist with the new name exists, revert to old value.
//        if newPlaylistName.isEmptyAfterTrimming {
//            
//            editedTextField.stringValue = playlist.name
//            
//            _ = DialogsAndAlerts.genericErrorAlert("Can't rename playlist", "Playlist name must have at least one non-whitespace character.", "Please type a valid name.").showModal()
//            
//        } else if playlistsManager.userDefinedObjectExists(named: newPlaylistName) {
//            
//            editedTextField.stringValue = playlist.name
//            
//            _ = DialogsAndAlerts.genericErrorAlert("Can't rename playlist", "Another playlist with that name already exists.", "Please type a unique name.").showModal()
//            
//        } else {
//            
//            playlistsManager.renameObject(named: oldPlaylistName, to: newPlaylistName)
////            playlistViewController.playlist = playlist
//        }
    }
}
