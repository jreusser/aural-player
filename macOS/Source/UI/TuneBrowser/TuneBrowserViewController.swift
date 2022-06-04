//
//  TuneBrowserViewController.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

class TuneBrowserViewController: NSViewController, NSMenuDelegate, Destroyable {
    
    override var nibName: String? {"TuneBrowser"}
    
    @IBOutlet weak var rootContainer: NSBox!
    @IBOutlet weak var lblCaption: NSTextField!
    
    @IBOutlet weak var browserView: TuneBrowserOutlineView!
    var resetBrowserView: Bool = false
    
    @IBOutlet weak var pathControlWidget: NSPathControl! {
        
        didSet {
            pathControlWidget.url = fileSystem.rootURL
        }
    }
    
    private lazy var messenger = Messenger(for: self)
    
    let textFont: NSFont = standardFontSet.mainFont(size: 13)
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        
        browserView.enableDragDrop()
        
        colorSchemesManager.registerObservers([rootContainer, browserView, pathControlWidget], forProperty: \.backgroundColor)
        
        fontSchemesManager.registerObserver(lblCaption, forProperty: \.captionFont)
        colorSchemesManager.registerObserver(lblCaption, forProperty: \.captionTextColor)
        
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
        messenger.subscribeAsync(to: .fileSystem_childrenAddedToItem, handler: childrenAdded(_:))
        
        messenger.subscribe(to: .application_willExit, handler: onAppExit)
        
//        TuneBrowserSidebarCategory.allCases.forEach {sidebarView.expandItem($0)}
        
        respondToSidebarSelectionChange = false
        selectMusicFolder()
        respondToSidebarSelectionChange = true
        
//        let theSushiClub: URL = FilesAndPaths.musicDir.appendingPathComponent("Ambient").appendingPathComponent("The Sushi Club")
        fileSystem.root = FileSystemItem.create(forURL: FilesAndPaths.musicDir)
        pathControlWidget.url = tuneBrowserMusicFolderURL
//        pathControlWidget.url = theSushiClub
    }
    
    private func onAppExit() {
        
        tuneBrowserUIState.displayedColumns = browserView.tableColumns.filter {$0.isShown}
        .map {TuneBrowserTableColumn(id: $0.identifier.rawValue, width: $0.width)}
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
    
    private func selectMusicFolder() {
        
//        let foldersRow = sidebarView.row(forItem: TuneBrowserSidebarCategory.folders)
//        let musicFolderRow = foldersRow + 1
//        sidebarView.selectRow(musicFolderRow)
    }
    
    func destroy() {
        messenger.unsubscribeFromAll()
    }
    
    private func fileMetadataLoaded(_ file: FileSystemItem) {
        
        DispatchQueue.main.async {
            self.browserView.reloadItem(file)
        }
    }
    
    private func childrenAdded(_ notif: TuneBrowserItemsAddedNotification) {
        
        let parent = notif.parentItem
        
//        if parent.url == fileSystem.rootURL {
//            browserView.reloadData()
//        } else {
//            browserView.reloadItem(parent, reloadChildren: true)
//        }
        
        browserView.insertItems(at: notif.childIndices,
                                inParent: parent.url == fileSystem.rootURL ? nil : parent,
                                withAnimation: .slideDown)
    }
        
    @IBAction func doubleClickAction(_ sender: Any) {
        
        if let item = browserView.item(atRow: browserView.selectedRow), let fsItem = item as? FileSystemItem {
            
            if fsItem.isTrack {
                
                if let track = fsItem.toTrack() {
                    messenger.publish(EnqueueAndPlayNowCommand(tracks: [track], clearPlayQueue: false))
                }
                
            } else {
                
                // TODO: Playlist !!!
                openFolder(item: fsItem)
            }
        }
    }
    
    func openFolder(item: FileSystemItem) {
        
        let path = item.url.path
        
        if !path.hasPrefix("/Volumes"), let volumeName = SystemUtils.primaryVolumeName {
            pathControlWidget.url = URL(fileURLWithPath: "/Volumes/\(volumeName)\(path)")
        } else {
            pathControlWidget.url = item.url
        }
        
        if item.childrenLoaded.value {
            
            fileSystem.root = item
            browserView.reloadData()
            
        } else {
            
            removeAllRows()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                fileSystem.root = item
            }
        }
        
        self.browserView.scrollRowToVisible(0)
        
//        updateSidebarSelection()
    }
    
    // If the folder currently shown by the browser corresponds to one of the folder shortcuts in the sidebar, select that
    // item in the sidebar.
    func updateSidebarSelection() {
        
        respondToSidebarSelectionChange = false
        
        if let folder = tuneBrowserUIState.userFolder(forURL: fileSystem.rootURL) {
//            sidebarView.selectRow(sidebarView.row(forItem: folder))

        } else if fileSystem.rootURL.equalsOneOf(FilesAndPaths.musicDir, tuneBrowserMusicFolderURL) {
            selectMusicFolder()
            
        } else {
//            sidebarView.clearSelection()
        }
        
        respondToSidebarSelectionChange = true
    }
    
    @IBAction func pathControlAction(_ sender: Any) {
        
        if let item = pathControlWidget.clickedPathItem, let url = item.url, url != pathControlWidget.url {
            
            removeAllRows()
            
            var path = url.path
            
            if !path.hasPrefix("/Volumes"), let volumeName = SystemUtils.primaryVolumeName {
                pathControlWidget.url = URL(fileURLWithPath: "/Volumes/\(volumeName)\(path)")
            } else {
                pathControlWidget.url = url
            }
            
            // Remove /Volumes from URL before setting fileSystem.rootURL
            
            if let volumeName = SystemUtils.primaryVolumeName, path.hasPrefix("/Volumes/\(volumeName)") {
                path = path.replacingOccurrences(of: "/Volumes/\(volumeName)", with: "")
            }
            
            let rootURL: URL = path.hasSuffix("/") ? url : URL(fileURLWithPath: path + "/")
            let fsRoot = FileSystemItem.create(forURL: rootURL)
            
            if fsRoot.childrenLoaded.value {
                
                fileSystem.root = fsRoot
                browserView.reloadData()
                
            } else {
                
                removeAllRows()
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    fileSystem.root = fsRoot
                }
            }

            browserView.scrollRowToVisible(0)
            
            updateSidebarSelection()
        }
    }
    
    private var respondToSidebarSelectionChange: Bool = true
    
    func showURL(_ url: URL) {
        
        let path = url.path
        
        if !path.hasPrefix("/Volumes"), let volumeName = SystemUtils.primaryVolumeName {
            pathControlWidget.url = URL(fileURLWithPath: "/Volumes/\(volumeName)\(path)")
        } else {
            pathControlWidget.url = url
        }
        
        let fsRoot = FileSystemItem.create(forURL: url)
        
        if fsRoot.childrenLoaded.value {
            
            fileSystem.root = fsRoot
            browserView.reloadData()
            
        } else {
            
            removeAllRows()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                fileSystem.root = fsRoot
            }
        }
        
        browserView.scrollRowToVisible(0)
    }
    
    @IBAction func playNowAction(_ sender: Any) {
        
        let files = browserView.selectedItems.compactMap {($0 as? FileSystemItem)?.url}
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
            
            messenger.publish(.librarySidebar_addFileSystemShortcut, payload: clickedItem.url)

//            sidebarView.insertItems(at: IndexSet(integer: tuneBrowserUIState.sidebarUserFolders.count),
//                                    inParent: TuneBrowserSidebarCategory.folders, withAnimation: .slideDown)
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
    
    @IBAction func showSidebarShortcutInFinderAction(_ sender: Any) {
        
//        if let selItem = sidebarView.rightClickedItem as? TuneBrowserSidebarItem {
//            selItem.url.showInFinder()
//        }
    }
}

extension NSPathControl: ColorSchemePropertyObserver {
    
    func colorChanged(to newColor: PlatformColor, forProperty property: KeyPath<ColorScheme, PlatformColor>) {
        backgroundColor = newColor
    }
}
