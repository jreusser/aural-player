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
    
    lazy var messenger = Messenger(for: self)
    
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
        
        colorSchemesManager.registerSchemeObserver(self)
        
//        colorSchemesManager.registerObserver(browserView, forProperty: \.backgroundColor)
//        colorSchemesManager.registerObserver(lblSummary, forProperty: \.secondaryTextColor)
        
//        //fontSchemesManager.registerObserver(lblSummary, forProperty: \.normalFont)
        
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
    
    func saveColumnsState() {
        
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
        
    // TODO: If some of these items already exist, playback won't begin.
    // Need to modify playlist to always play the first item.
    func doAddBrowserItemsToPlayQueue(urls: [URL], beginPlayback: Bool = false) {
        
        if beginPlayback {
            messenger.publish(LibraryFileSystemItemsPlayedNotification(filesAndFolders: urls))
        }
        
        playQueueDelegate.loadTracks(from: urls, autoplay: beginPlayback)
    }
}

extension TuneBrowserTabViewController: ColorSchemeObserver {
    
    func colorSchemeChanged() {
        
        browserView.setBackgroundColor(systemColorScheme.backgroundColor)
        browserView.reloadDataMaintainingSelection()
        lblSummary.textColor = systemColorScheme.secondaryTextColor
    }
}
