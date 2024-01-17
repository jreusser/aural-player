//
//  TuneBrowserViewController.swift
//  Aural
//
//  Copyright © 2023 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import Cocoa
import OrderedCollections

class TuneBrowserViewController: NSViewController {
    
    override var nibName: String? {"TuneBrowser"}
    
    @IBOutlet weak var rootContainer: NSBox!
    @IBOutlet weak var tabView: NSTabView!
    
    @IBOutlet weak var lblCaption: NSTextField!
    
    @IBOutlet weak var btnBack: TintedImageButton!
    @IBOutlet weak var btnForward: TintedImageButton!
    
    @IBOutlet weak var backHistoryMenu: NSMenu!
    @IBOutlet weak var forwardHistoryMenu: NSMenu!
    
    @IBOutlet weak var pathControlWidget: NSPathControl!
    
    private let history: TuneBrowserHistory = TuneBrowserHistory()
    
    private lazy var messenger = Messenger(for: self)
    
    let textFont: NSFont = standardFontSet.mainFont(size: 13)
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        
        colorSchemesManager.registerObservers([rootContainer, pathControlWidget], forProperty: \.backgroundColor)
        colorSchemesManager.registerObservers([btnBack, btnForward], forProperty: \.buttonColor)
        
        fontSchemesManager.registerObserver(lblCaption, forProperty: \.captionFont)
        colorSchemesManager.registerObserver(lblCaption, forProperty: \.captionTextColor)
        
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
        
        messenger.subscribe(to: .tuneBrowser_notePreviousLocation, handler: notePreviousLocation(_:))
        messenger.subscribe(to: .application_willExit, handler: onAppExit)
        
//        TuneBrowserSidebarCategory.allCases.forEach {sidebarView.expandItem($0)}
        
        respondToSidebarSelectionChange = false
        selectMusicFolder()
        respondToSidebarSelectionChange = true

        pathControlWidget.url = nil
//        showURL(FilesAndPaths.musicDir)
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
    
    override func destroy() {
        
        // Check if any existing tab is already showing the target URL.
        for tab in tabView.tabViewItems {
            
            if let tabVC = tab.viewController as? TuneBrowserTabViewController {
                tabVC.destroy()
            }
        }
        
        messenger.unsubscribeFromAll()
    }
    
    // If the folder currently shown by the browser corresponds to one of the folder shortcuts in the sidebar, select that
    // item in the sidebar.
    func updateSidebarSelection() {
        
//        respondToSidebarSelectionChange = false
//
//        if let folder = tuneBrowserUIState.userFolder(forURL: fileSystem.rootURL) {
////            sidebarView.selectRow(sidebarView.row(forItem: folder))
//
//        } else if fileSystem.rootURL.equalsOneOf(FilesAndPaths.musicDir, tuneBrowserMusicFolderURL) {
//            selectMusicFolder()
//
//        } else {
////            sidebarView.clearSelection()
//        }
//
//        respondToSidebarSelectionChange = true
    }
    
    @IBAction func pathControlAction(_ sender: Any) {
        
        guard let item = pathControlWidget.clickedPathItem, let url = item.url, url != pathControlWidget.url else {return}
        
        // Remove /Volumes from URL before setting fileSystem.rootURL
        var path = url.path
        
        if let volumeName = SystemUtils.primaryVolumeName, path.hasPrefix("/Volumes/\(volumeName)") {
            path = path.replacingOccurrences(of: "/Volumes/\(volumeName)", with: "")
        }
        
        showURL(URL(fileURLWithPath: path))
    }
    
    private var respondToSidebarSelectionChange: Bool = true
    
    func showURL(_ url: URL, updateHistory: Bool = true) {
        
        if updateHistory, let currentURL = pathControlWidget.url {
            history.notePreviousLocation(currentURL)
        }
        
        pathControlWidget.url = url

        // Check if any existing tab is already showing the target URL.
        for tab in tabView.tabViewItems {
            
            if let tabVC = tab.viewController as? TuneBrowserTabViewController,
               tabVC.rootURL == url {
                
                tabVC.scrollToTop()
                tabView.selectTabViewItem(tab)
                return
            }
        }
        
        let newController = TuneBrowserTabViewController()
        newController.forceLoadingOfView()
        newController.pathControlWidget = self.pathControlWidget
        
        newController.setRoot(url)
        
        tabView.addTabViewItem(NSTabViewItem(viewController: newController))
        newController.view.anchorToSuperview()
        
        tabView.showLastTab()
        
        updateNavButtons()
    }
    
    private func notePreviousLocation(_ location: URL) {
        
        history.notePreviousLocation(location)
        updateNavButtons()
    }
    
    private func updateNavButtons() {
        
        btnBack.enableIf(history.canGoBack)
        btnForward.enableIf(history.canGoForward)
        
        backHistoryMenu.removeAllItems()
        forwardHistoryMenu.removeAllItems()
        
        if history.canGoBack {
            
            for url in history.backStack.underlyingArray.reversed() {
                
                let item = TuneBrowserHistoryMenuItem(title: url.lastPathComponent, action: #selector(backHistoryMenuAction(_:)))
                item.url = url
                item.target = self
                
                backHistoryMenu.addItem(item)
            }
        }
        
        if history.canGoForward {
            
            for url in history.forwardStack.underlyingArray.reversed() {
                
                let item = TuneBrowserHistoryMenuItem(title: url.lastPathComponent, action: #selector(forwardHistoryMenuAction(_:)))
                item.url = url
                item.target = self
                
                forwardHistoryMenu.addItem(item)
            }
        }
    }
    
    @IBAction func backHistoryMenuAction(_ sender: TuneBrowserHistoryMenuItem) {
        
        history.back(to: sender.url)
        showURL(sender.url, updateHistory: false)
        updateNavButtons()
    }
    
    @IBAction func forwardHistoryMenuAction(_ sender: TuneBrowserHistoryMenuItem) {
        showURL(sender.url)
    }
    
    @IBAction func goBackAction(_ sender: Any) {
        
        guard let currentURL = pathControlWidget.url,
              let newURL = history.back(from: currentURL) else {return}
            
        showURL(newURL, updateHistory: false)
        updateNavButtons()
    }
    
    @IBAction func goForwardAction(_ sender: Any) {
        
        guard let currentURL = pathControlWidget.url,
              let newURL = history.forward(from: currentURL) else {return}
            
        showURL(newURL, updateHistory: false)
        updateNavButtons()
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

extension NSPathControl: ColorSchemePropertyObserver {
    
    func colorChanged(to newColor: PlatformColor, forProperty property: KeyPath<ColorScheme, PlatformColor>) {
        backgroundColor = newColor
    }
}

extension NSTabView {
    
    func showLastTab() {
        
        if tabViewItems.isNonEmpty {
            selectTabViewItem(at: numberOfTabViewItems - 1)
        }
    }
}

class TuneBrowserHistoryMenuItem: NSMenuItem {
    
    var url: URL!
}
