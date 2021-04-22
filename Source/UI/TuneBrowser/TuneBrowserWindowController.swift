import Cocoa

class TuneBrowserWindowController: NSWindowController, NotificationSubscriber, Destroyable {
    
    override var windowNibName: String? {"TuneBrowser"}
    
    @IBOutlet weak var browserView: TuneBrowserOutlineView!
    @IBOutlet weak var browserViewDelegate: TuneBrowserViewDelegate!
    
    @IBOutlet weak var pathControlWidget: NSPathControl! {
        
        didSet {
            pathControlWidget.url = fileSystem.rootURL
        }
    }
    
    private lazy var fileSystem: FileSystem = ObjectGraph.fileSystem
    
    override func windowDidLoad() {
        
        super.windowDidLoad()
        Messenger.subscribeAsync(self, .fileSystem_fileMetadataLoaded, self.fileMetadataLoaded(_:), queue: .main)
        
        fileSystem.root = FileSystemItem.create(forURL: AppConstants.FilesAndPaths.musicDir)
        
        if let volumeName = FileSystemUtils.primaryVolumeName {
            pathControlWidget.url = URL(fileURLWithPath: "/Volumes/\(volumeName)\(NSHomeDirectory())/Music")
        } else {
            pathControlWidget.url = AppConstants.FilesAndPaths.musicDir
        }
    }
    
    func destroy() {
        Messenger.unsubscribeAll(for: self)
    }
    
    private func fileMetadataLoaded(_ notif: FileSystemFileMetadataLoadedNotification) {
        
        browserView.reloadItem(notif.file)
        
        //        let itemIndex: Int = browserView.row(forItem: notif.file)
//        browserView.reloadData(forRowIndexes: IndexSet([itemIndex]), columnIndexes: )
    }
        
    @IBAction func openFolderAction(_ sender: Any) {
        
        if let item = browserView.item(atRow: browserView.selectedRow), let fsItem = item as? FileSystemItem, fsItem.isDirectory {
            
            let path = fsItem.url.path
            
            if !path.hasPrefix("/Volumes"), let volumeName = FileSystemUtils.primaryVolumeName {
                pathControlWidget.url = URL(fileURLWithPath: "/Volumes/\(volumeName)\(path)")
            } else {
                pathControlWidget.url = fsItem.url
            }
            
            fileSystem.root = fsItem
            browserView.reloadData()
            browserView.scrollRowToVisible(0)
        }
    }
    
    @IBAction func pathControlAction(_ sender: Any) {
        
        if let item = pathControlWidget.clickedPathItem, let url = item.url, url != pathControlWidget.url {
            
            var path = url.path
            
            if !path.hasPrefix("/Volumes"), let volumeName = FileSystemUtils.primaryVolumeName {
                pathControlWidget.url = URL(fileURLWithPath: "/Volumes/\(volumeName)\(path)")
            } else {
                pathControlWidget.url = url
            }
            
            if path.hasSuffix("/") {
                fileSystem.rootURL = url
                
            } else {
                
                path += "/"
                fileSystem.rootURL = URL(fileURLWithPath: path)
            }
            
            browserView.reloadData()
            browserView.scrollRowToVisible(0)
        }
    }
        
    @IBAction func closeAction(_ sender: Any) {
        self.window?.close()
    }
}
