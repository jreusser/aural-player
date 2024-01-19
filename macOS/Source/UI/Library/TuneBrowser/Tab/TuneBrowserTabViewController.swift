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
    
    lazy var tree: FileSystemTree = library.fileSystemTrees.values.first!
    lazy var rootFolder: FileSystemFolderItem = library.fileSystemTrees.values.first!.root
    
    var isAvailable: Bool {
//        fileSystem.root == nil
        false
    }
    
    var rootURL: URL {
        rootFolder.url
    }
    
    func reset() {
        
//        fileSystem.root = nil
        browserView.reloadData()
    }
    
    func setRoot(_ rootURL: URL) {
        
        if self.rootURL == rootURL {return}
        
        if let folder = library.fileSystemTrees.values.first!.item(forURL: rootURL) as? FileSystemFolderItem {
            
            self.rootFolder = folder
            browserView.reloadData()
            updateSummary()
        }
    }
    
    func scrollToTop(){
        browserView.scrollToTop()
    }
    
    private lazy var messenger = Messenger(for: self)
    
    let textFont: NSFont = standardFontSet.mainFont(size: 13)
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        
        browserView.enableDragDrop()
        
        colorSchemesManager.registerObserver(browserView, forProperty: \.backgroundColor)
        fontSchemesManager.registerObserver(lblSummary, forProperty: \.playQueuePrimaryFont)
        colorSchemesManager.registerObserver(lblSummary, forProperty: \.secondaryTextColor)
        
        var displayedColumnIds: [String] = tuneBrowserUIState.displayedColumns.compactMap {$0.id}

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

        for column in tuneBrowserUIState.displayedColumns {
            browserView.tableColumn(withIdentifier: NSUserInterfaceItemIdentifier(column.id))?.width = column.width
        }
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        messenger.subscribeAsync(to: .fileSystem_fileMetadataLoaded, handler: fileMetadataLoaded(_:))
        messenger.subscribeAsync(to: .tuneBrowser_folderChanged, handler: folderChanged(_:))
    }
    
    override func destroy() {
        
        super.destroy()
        
//        fileSystem.destroy()
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
        
        if let id = sender.identifier {
            browserView.tableColumn(withIdentifier: id)?.isHidden.toggle()
        }
    }
    
    private func fileMetadataLoaded(_ file: FileSystemItem) {
        
        DispatchQueue.main.async {
            self.browserView.reloadItem(file)
        }
    }
    
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
            
            // Folder
            openFolder(folderItem)
        }
    }
    
    private func openFolder(_ item: FileSystemFolderItem, updatePathWidget: Bool = true) {
        
        let currentURL = rootFolder.url
        messenger.publish(.tuneBrowser_notePreviousLocation, payload: currentURL)
        
        self.rootFolder = item
        let url = rootFolder.url
        let path = url.path
        
        print("\nRel Path: \(item.url.path(relativeTo: tree.rootURL))")
        
        if updatePathWidget {
            
//            if !path.hasPrefix("/Volumes"), let volumeName = SystemUtils.primaryVolumeName {
//                pathControlWidget.url = URL(fileURLWithPath: "/Volumes/\(volumeName)\(path)")
//            } else {
//                pathControlWidget.url = url
//            }
            pathControlWidget.pathItems[0].title = item.name
//            pathControlWidget.pathItems[0].image = .init(systemSymbolName: "music.note.house", accessibilityDescription: nil)!
//            pathControlWidget.pathItems[0].image?.size = .init(width: 14, height: 14)
        }
        
        browserView.reloadData()
        updateSummary()
    }
    
    @IBAction func playNowAction(_ sender: Any) {
        
        let files = browserView.selectedFileSystemItemURLs
        
        // TODO: Folder B should not be contained within folder A
        
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
        
        if let clickedItem: FileSystemItem = browserView.rightClickedItem as? FileSystemItem {

            tuneBrowserUIState.addUserFolder(forURL: clickedItem.url)
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
