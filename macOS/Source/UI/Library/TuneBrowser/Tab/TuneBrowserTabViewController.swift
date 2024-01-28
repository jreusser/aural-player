//
//  TuneBrowserTabViewController.swift
//  Aural
//
//  Copyright © 2023 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

class TuneBrowserTabViewController: NSViewController, NSMenuDelegate, FileSystemUIObserver {
    
    override var nibName: String? {"TuneBrowserTab"}
    
    var pathControlWidget: NSPathControl!
    @IBOutlet weak var browserView: TuneBrowserOutlineView!
    @IBOutlet weak var lblSummary: NSTextField!
    
    let tree: FileSystemTree
    let rootFolder: FileSystemFolderItem
    
    var location: FileSystemFolderLocation {
        .init(folder: rootFolder, tree: tree)
    }
    
    var rootURL: URL {
        rootFolder.url
    }
    
    func scrollToTop(){
        browserView.scrollToTop()
    }
    
    private lazy var messenger = Messenger(for: self)
    
    let textFont: NSFont = standardFontSet.mainFont(size: 13)
    
    init(pathControlWidget: NSPathControl, tree: FileSystemTree, rootFolder: FileSystemFolderItem) {
        
        self.pathControlWidget = pathControlWidget
        self.tree = tree
        self.rootFolder = rootFolder
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        
        browserView.enableDragDrop()
        
//        colorSchemesManager.registerObserver(browserView, forProperty: \.backgroundColor)
//        fontSchemesManager.registerObserver(lblSummary, forProperty: \.playQueuePrimaryFont)
//        colorSchemesManager.registerObserver(lblSummary, forProperty: \.secondaryTextColor)
        
//        restoreDisplayedColumns()
    }
    
    private func restoreDisplayedColumns() {
        
        var displayedColumnIds: [String] = tuneBrowserUIState.displayedColumns.values.map {$0.id}

        // Show default columns if none have been selected (eg. first time app is launched).
        if displayedColumnIds.isEmpty {
            displayedColumnIds = [NSUserInterfaceItemIdentifier.cid_tuneBrowserName.rawValue]
        }

        for column in browserView.tableColumns {
//            column.headerCell = LibraryTableHeaderCell(stringValue: column.headerCell.stringValue)
            column.isHidden = !displayedColumnIds.contains(column.identifier.rawValue)
        }

        for (index, columnId) in displayedColumnIds.enumerated() {

            let oldIndex = browserView.column(withIdentifier: NSUserInterfaceItemIdentifier(columnId))
            browserView.moveColumn(oldIndex, toColumn: index)
        }

        for column in tuneBrowserUIState.displayedColumns.values {
            browserView.tableColumn(withIdentifier: NSUserInterfaceItemIdentifier(column.id))?.width = column.width
        }
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        browserView.reloadData()
        updateSummary()
        
//        messenger.subscribeAsync(to: .fileSystem_fileMetadataLoaded, handler: fileMetadataLoaded(_:))
        messenger.subscribeAsync(to: .tuneBrowser_folderChanged, handler: folderChanged(_:))
    }
    
    override func viewWillAppear() {
        
        super.viewWillAppear()
        restoreDisplayedColumns()
    }
    
    override func viewWillDisappear() {
        
        super.viewWillDisappear()
        saveColumnsState()
    }
    
    override func destroy() {
        
        super.destroy()
        messenger.unsubscribeFromAll()
    }
    
    func menuWillOpen(_ menu: NSMenu) {
        
        for item in menu.items {

            if let id = item.identifier {
                item.onIf(browserView.tableColumn(withIdentifier: id)?.isShown ?? false)
            }
        }
    }
    
    @IBAction func toggleColumnAction(_ sender: NSMenuItem) {
        
        // TODO: Validation - Don't allow 0 columns to be shown.
        
        guard let id = sender.identifier, let col = browserView.tableColumn(withIdentifier: id) else {return}
        
        col.isHidden.toggle()
        
//        if col.isHidden {
//            tuneBrowserUIState.displayedColumns.removeValue(forKey: id.rawValue)
//        } else {
//            tuneBrowserUIState.displayedColumns[id.rawValue] = .init(id: id.rawValue, width: col.width)
//        }
    }
    
    private func saveColumnsState() {
        
        tuneBrowserUIState.displayedColumns.removeAll()
        for column in browserView.tableColumns.filter({$0.isShown}) {
            tuneBrowserUIState.displayedColumns[column.identifier.rawValue] = .init(id: column.identifier.rawValue, width: column.width)
        }
    }
    
    // TODO: No longer required because entire file system will be built (with track metadata) before shown in UI.
    //    private func fileMetadataLoaded(_ file: FileSystemItem) {
    //
    //        DispatchQueue.main.async {
    //            self.browserView.reloadItem(file)
//        }
//    }
    
    private func folderChanged(_ notif: FileSystemItemUpdatedNotification) {
        
        DispatchQueue.main.async {
            self.browserView.reloadItem(notif.item)
        }
    }
    
    func itemsAdded(to item: FileSystemItem, at indices: IndexSet) {
        
        // TODO: To solve the potential duplicates issue (reloadData() and insertItems
        // happening simultaneously, maybe for each index, check if view(forRow, column)
        // is nil. If nil, go ahead and insert, otherwise skip the update.
        
        browserView.insertItems(at: indices,
                                inParent: item.url == rootURL ? nil : item)
        
        updateSummary()
    }
    
    private func updateSummary() {
        
        var numFolders = 0
        var numTracks = 0
        var numPlaylists = 0
        
        for child in rootFolder.children.values {
            
            if child.isTrack {
                numTracks.increment()
                
            } else if child.isDirectory {
                numFolders.increment()
                
            } else if child.isPlaylist {
                numPlaylists.increment()
            }
        }
        
        let foldersString = numFolders > 0 ? "\(numFolders) \(numFolders == 1 ? "folder" : "folders")" : ""
        let tracksString = numTracks > 0 ? "\(numTracks) \(numTracks == 1 ? "track" : "tracks")" : ""
        let playlistsString = numPlaylists > 0 ? "\(numPlaylists) \(numPlaylists == 1 ? "playlist" : "playlists")" : ""
        
        let allStrings = [foldersString, tracksString, playlistsString].filter {!$0.isEmpty}
        let summaryString = allStrings.joined(separator: ", ")
        
        lblSummary.stringValue = summaryString.isEmpty ? "0 tracks" : summaryString
    }
        
    @IBAction func doubleClickAction(_ sender: Any) {
        
        guard let item = browserView.item(atRow: browserView.selectedRow),
              let fsItem = item as? FileSystemItem else {return}
        
        if fsItem.isTrack, let trackItem = fsItem as? FileSystemTrackItem {
            messenger.publish(EnqueueAndPlayNowCommand(tracks: [trackItem.track], clearPlayQueue: false))
            
        } else if fsItem.isPlaylist, let playlistItem = fsItem as? FileSystemPlaylistItem {
            messenger.publish(EnqueueAndPlayNowCommand(tracks: playlistItem.playlist.tracks, clearPlayQueue: false))
            
        } else if let folderItem = fsItem as? FileSystemFolderItem {
            
            saveColumnsState()
            
            // Folder
            messenger.publish(.tuneBrowser_openFolder,
                              payload: OpenTuneBrowserFolderCommandNotification(folderToOpen: folderItem,
                                                                                treeContainingFolder: self.tree,
                                                                                currentlyOpenFolder: self.rootFolder))
        }
    }
    
    @IBAction func playNowAction(_ sender: Any) {
        
        // TODO: Folder B should not be contained within folder A
        let files = browserView.selectedFileSystemItemURLs
        
        messenger.publish(LibraryFileSystemItemsPlayedNotification(filesAndFolders: files))
        messenger.publish(LoadAndPlayNowCommand(files: files, clearPlayQueue: true))
    }
    
    /// Play Later
    @IBAction func enqueueBrowserItemsAction(_ sender: Any) {
        doAddBrowserItemsToPlayQueue(urls: browserView.selectedFileSystemItemURLs)
    }
    
    // TODO: Clarify this use case (which items qualify for this) ?
    @IBAction func enqueueAndPlayBrowserItemsAction(_ sender: Any) {
        doAddBrowserItemsToPlayQueue(urls: browserView.selectedFileSystemItemURLs, beginPlayback: true)
    }
    
    // TODO: If some of these items already exist, playback won't begin.
    // Need to modify playlist to always play the first item.
    private func doAddBrowserItemsToPlayQueue(urls: [URL], beginPlayback: Bool = false) {
        
        if beginPlayback {
            messenger.publish(LibraryFileSystemItemsPlayedNotification(filesAndFolders: urls))
        }
        
        playQueueDelegate.loadTracks(from: urls, autoplay: beginPlayback)
    }
    
    @IBAction func addSidebarShortcutAction(_ sender: Any) {
        
        if let clickedItem: FileSystemFolderItem = browserView.rightClickedItem as? FileSystemFolderItem {

            tuneBrowserUIState.addUserFolder(clickedItem, inTree: self.tree)
            messenger.publish(.sidebar_addFileSystemShortcut, payload: clickedItem.url)
        }
    }
    
    @IBAction func removeSidebarShortcutAction(_ sender: Any) {
        
//        if let clickedItem: TuneBrowserSidebarItem = sidebarView.rightClickedItem as? TuneBrowserSidebarItem,
//           let removedItemIndex = tuneBrowserUIState.removeUserFolder(item: clickedItem) {
//
//            let musicFolderRow = sidebarView.row(forItem: TuneBrowserSidebarCategory.folders) + 1
//            let selectedRow = sidebarView.selectedRow
//            let selectedItemRemoved = selectedRow == (musicFolderRow + removedItemIndex + 1)
//
//            sidebarView.removeItems(at: IndexSet([removedItemIndex + 1]),
//                                    inParent: TuneBrowserSidebarCategory.folders, withAnimation: .effectFade)
//
//            if selectedItemRemoved {
//
//                let foldersRow = sidebarView.row(forItem: TuneBrowserSidebarCategory.folders)
//                let musicFolderRow = foldersRow + 1
//                sidebarView.selectRow(musicFolderRow)
//            }
//        }
    }
    
    @IBAction func showBrowserItemInFinderAction(_ sender: Any) {
        
        if let selItem = browserView.rightClickedItem as? FileSystemItem {
            selItem.url.showInFinder()
        }
    }
}
