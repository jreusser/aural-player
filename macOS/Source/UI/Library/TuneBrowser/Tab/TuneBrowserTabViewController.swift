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
    
    lazy var fileSystem: FileSystem = FileSystem(observer: self)
    
    var isAvailable: Bool {
        fileSystem.root == nil
    }
    
    var rootURL: URL? {
        fileSystem.rootURL
    }
    
    func reset() {
        
        fileSystem.root = nil
        browserView.reloadData()
    }
    
    func setRoot(_ rootURL: URL) {
        
        if fileSystem.rootURL == rootURL {return}

        fileSystem.rootURL = rootURL
        
        if fileSystem.root?.childrenLoaded.value ?? false {
            
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
    }
    
    override func destroy() {
        
        super.destroy()
        
        fileSystem.destroy()
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
    
    func itemsAdded(to item: FileSystemItem, at indices: IndexSet) {
        
        // TODO: To solve the potential duplicates issue (reloadData() and insertItems
        // happening simultaneously, maybe for each index, check if view(forRow, column)
        // is nil. If nil, go ahead and insert, otherwise skip the update.
        
        browserView.insertItems(at: indices,
                                inParent: item.url == fileSystem.rootURL ? nil : item)
        
        updateSummary()
    }
    
    private func updateSummary() {
        
        var numFolders = 0
        var numTracks = 0
        var numPlaylists = 0
        
        if let root = fileSystem.root {
            
            for child in root.children.values {
                
                if child.isTrack {
                    numTracks.increment()
                    
                } else if child.isDirectory {
                    numFolders.increment()
                    
                } else if child.isPlaylist {
                    numPlaylists.increment()
                }
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
        
        if fsItem.isTrack {
            
            if let track = fsItem.toTrack() {
                messenger.publish(EnqueueAndPlayNowCommand(tracks: [track], clearPlayQueue: false))
            }
            
        } else if fsItem.isPlaylist {
            
            let tracks = fsItem.children.values.compactMap {$0.toTrack()}
            messenger.publish(EnqueueAndPlayNowCommand(tracks: tracks, clearPlayQueue: false))
            
        } else {
            
            // Folder
            openFolder(fsItem)
        }
    }
    
    private func showURL(_ url: URL, updatePathWidget: Bool = true) {
        
        if let currentURL = fileSystem.rootURL {
            messenger.publish(.tuneBrowser_notePreviousLocation, payload: currentURL)
        }
        
        let path = url.path
        
        if updatePathWidget {
            
            if !path.hasPrefix("/Volumes"), let volumeName = SystemUtils.primaryVolumeName {
                pathControlWidget.url = URL(fileURLWithPath: "/Volumes/\(volumeName)\(path)")
            } else {
                pathControlWidget.url = url
            }
        }
        
        let fsRoot = FileSystemItem.create(forURL: url)
        
        // TODO: WARNING - If the root's children are partially loaded, we
        // may have duplicates because we will reload and also receive
        // notifications.
        
        // If the children have already been loaded, just reload the browser.
        if fsRoot.childrenLoaded.value {
            
            fileSystem.root = fsRoot
            browserView.reloadData()
            updateSummary()
            
        } else {
            
            reset()
            
            // Children not loaded yet, just set the root. No need to reload
            // the browser coz we will receive notifications.
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.fileSystem.root = fsRoot
            }
        }
    }
    
    private func openFolder(_ item: FileSystemItem) {
        showURL(item.url, updatePathWidget: true)
    }
    
    @IBAction func playNowAction(_ sender: Any) {
        
        let files = browserView.selectedItems.compactMap {($0 as? FileSystemItem)?.url}
        let folders = files.filter {$0.isDirectory}
        let playlistFiles = files.filter {$0.isSupportedPlaylistFile}
        
        // TODO: Folder B should not be contained within folder A
        messenger.publish(LibraryPlaylistFilesPlayedNotification(playlistFiles: playlistFiles))
        messenger.publish(LibraryFoldersPlayedNotification(folders: folders))
        messenger.publish(LoadAndPlayNowCommand(files: files, clearPlayQueue: true))
    }
    
    @IBAction func enqueueBrowserItemsAction(_ sender: Any) {
        doAddBrowserItemsToPlayQueue(indexes: browserView.selectedRowIndexes)
    }
    
    // TODO: Clarify this use case (which items qualify for this) ?
    @IBAction func enqueueAndPlayBrowserItemsAction(_ sender: Any) {
        doAddBrowserItemsToPlayQueue(indexes: browserView.selectedRowIndexes, beginPlayback: true)
    }
    
    // TODO: If some of these items already exist, playback won't begin.
    // Need to modify playlist to always play the first item.
    private func doAddBrowserItemsToPlayQueue(indexes: IndexSet, beginPlayback: Bool = false) {
        
        let selItemURLs = indexes.compactMap {[weak browserView] in browserView?.item(atRow: $0) as? FileSystemItem}.map {$0.url}
        playQueueDelegate.loadTracks(from: selItemURLs, autoplay: beginPlayback)
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
