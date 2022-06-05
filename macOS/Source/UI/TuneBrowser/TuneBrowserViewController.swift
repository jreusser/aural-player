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

class TuneBrowserViewController: NSViewController {
    
    override var nibName: String? {"TuneBrowser"}
    
    @IBOutlet weak var rootContainer: NSBox!
    @IBOutlet weak var tabView: NSTabView!
    
    @IBOutlet weak var lblCaption: NSTextField!
    @IBOutlet weak var lblSummary: NSTextField!
    
    var resetBrowserView: Bool = false
    
    var fileSystem: FileSystem! = nil
    
    @IBOutlet weak var pathControlWidget: NSPathControl! {
        
        didSet {
//            pathControlWidget.url = FilesAndPaths.musicDir.resolvingAlias()
        }
    }
    
    private lazy var messenger = Messenger(for: self)
    
    let textFont: NSFont = standardFontSet.mainFont(size: 13)
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        
        colorSchemesManager.registerObservers([rootContainer, pathControlWidget], forProperty: \.backgroundColor)
        
        fontSchemesManager.registerObserver(lblCaption, forProperty: \.captionFont)
        fontSchemesManager.registerObserver(lblSummary, forProperty: \.playQueuePrimaryFont)
        
        colorSchemesManager.registerObserver(lblCaption, forProperty: \.captionTextColor)
        colorSchemesManager.registerObserver(lblSummary, forProperty: \.secondaryTextColor)
        
        var displayedColumnIds: [String] = tuneBrowserUIState.displayedColumns.compactMap {$0.id}

        // Show default columns if none have been selected (eg. first time app is launched).
        if displayedColumnIds.isEmpty {
            displayedColumnIds = [NSUserInterfaceItemIdentifier.cid_tuneBrowserName.rawValue]
        }

//        for column in browserView.tableColumns {
////            column.headerCell = LibraryTableHeaderCell(stringValue: column.headerCell.stringValue)
//            column.isHidden = !displayedColumnIds.contains(column.identifier.rawValue)
//        }

//        for (index, columnId) in displayedColumnIds.enumerated() {
//
//            let oldIndex = browserView.column(withIdentifier: NSUserInterfaceItemIdentifier(columnId))
//            browserView.moveColumn(oldIndex, toColumn: index)
//        }
//
//        for column in tuneBrowserUIState.displayedColumns {
//            browserView.tableColumn(withIdentifier: NSUserInterfaceItemIdentifier(column.id))?.width = column.width
//        }
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        messenger.subscribe(to: .application_willExit, handler: onAppExit)
        
//        TuneBrowserSidebarCategory.allCases.forEach {sidebarView.expandItem($0)}
        
        respondToSidebarSelectionChange = false
        selectMusicFolder()
        respondToSidebarSelectionChange = true
        
//        let theSushiClub: URL = FilesAndPaths.musicDir.appendingPathComponent("Ambient").appendingPathComponent("The Sushi Club")
        pathControlWidget.url = FilesAndPaths.musicDir
//        pathControlWidget.url = theSushiClub
    }
    
    private func onAppExit() {
        
//        tuneBrowserUIState.displayedColumns = browserView.tableColumns.filter {$0.isShown}
//        .map {TuneBrowserTableColumn(id: $0.identifier.rawValue, width: $0.width)}
    }
    
    private func selectMusicFolder() {
        
//        let foldersRow = sidebarView.row(forItem: TuneBrowserSidebarCategory.folders)
//        let musicFolderRow = foldersRow + 1
//        sidebarView.selectRow(musicFolderRow)
    }
    
    func destroy() {
        messenger.unsubscribeFromAll()
    }
    
    func openFolder(item: FileSystemItem) {
        
//        let path = item.url.path
//
//        if !path.hasPrefix("/Volumes"), let volumeName = SystemUtils.primaryVolumeName {
//            pathControlWidget.url = URL(fileURLWithPath: "/Volumes/\(volumeName)\(path)")
//        } else {
//            pathControlWidget.url = item.url
//        }
//
//        if item.childrenLoaded.value {
//
//            fileSystem.root = item
//            browserView.reloadData()
//
//            self.browserView.scrollRowToVisible(0)
//            updateSummary()
//
//        } else {
//
//            removeAllRows()
//
//            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
//
//                self.fileSystem.root = item
//                self.browserView.scrollRowToVisible(0)
//                self.updateSummary()
//            }
//        }
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
    
    private func updateSummary() {
        
        var numFolders = 0
        var numTracks = 0
        var numPlaylists = 0
        
        for child in fileSystem.root.children.values {
            
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
    
    @IBAction func pathControlAction(_ sender: Any) {
        
        if let item = pathControlWidget.clickedPathItem, let url = item.url, url != pathControlWidget.url {
            
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
            
//            if fsRoot.childrenLoaded.value {
//
//                fileSystem.root = fsRoot
//                browserView.reloadData()
//
//            } else {
//
//                removeAllRows()
//
//                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
//                    self.fileSystem.root = fsRoot
//                }
//            }
//
//            browserView.scrollRowToVisible(0)
            
            updateSidebarSelection()
            updateSummary()
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
        
//        if fsRoot.childrenLoaded.value {
//
//            fileSystem.root = fsRoot
//            browserView.reloadData()
//
//        } else {
//
//            removeAllRows()
//
//            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
//                self.fileSystem.root = fsRoot
//            }
//        }
//
//        browserView.scrollRowToVisible(0)
        updateSummary()
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
}
