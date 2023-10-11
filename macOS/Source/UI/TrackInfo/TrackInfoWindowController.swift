//
//  TrackInfoViewController.swift
//  Aural
//
//  Copyright © 2023 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

class TrackInfoViewContext {
    
    // Temporary holder for the currently shown track
    static var displayedTrack: Track!
}

/*
    View controller for the "Detailed Track Info" popover
*/
class TrackInfoWindowController: NSWindowController {
    
    override var windowNibName: String? {"TrackInfoWindow"}
    
    @IBAction func closeAction(_ sender: Any) {
        close()
    }
}
    
class TrackInfoViewController: NSViewController, NSMenuDelegate {
    
    @IBOutlet weak var tabView: AuralTabView!
    
    @IBOutlet weak var lblMainCaption: NSTextField!
    @IBOutlet weak var lblTabCaption: NSTextField!
    
    @IBOutlet weak var exportArtMenuItem: NSMenuItem!
    @IBOutlet weak var exportHTMLWithArtMenuItem: NSMenuItem!
    
    private let metadataViewController: MetadataTrackInfoViewController = MetadataTrackInfoViewController()
    private let lyricsViewController: LyricsTrackInfoViewController = LyricsTrackInfoViewController()
    private let coverArtViewController: CoverArtTrackInfoViewController = CoverArtTrackInfoViewController()
    private let audioViewController: AudioTrackInfoViewController = AudioTrackInfoViewController()
    private let fileSystemViewController: FileSystemTrackInfoViewController = FileSystemTrackInfoViewController()
    
    private var tabViewControllers: [TrackInfoViewProtocol] = []
    
    private lazy var dateFormatter: DateFormatter = DateFormatter(format: "MMMM dd, yyyy 'at' hh:mm:ss a")
    
    private lazy var messenger = Messenger(for: self)
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        tabViewControllers = [metadataViewController, lyricsViewController, coverArtViewController,
                           audioViewController, fileSystemViewController]
        
        let tabViews = tabViewControllers.map {$0.view}
        
        tabView.addViewsForTabs(tabViews)
        
        tabViews.forEach {
            $0.anchorToSuperview()
        }
        
        tabView.selectTabViewItem(at: 0)
        
        // Only respond to these notifications when the popover is shown, the updated track matches the displayed track,
        // and the album art field of the track was updated.
        messenger.subscribeAsync(to: .player_trackInfoUpdated, handler: coverArtViewController.trackInfoUpdated(_:),
                                 filter: {[weak self] msg in (self?.view.window?.isVisible ?? false) &&
                                    msg.updatedTrack == TrackInfoViewContext.displayedTrack &&
                                    msg.updatedFields.contains(.art)})
    }
    
    override func viewWillAppear() {
        
        super.viewWillAppear()
        tabViewControllers.forEach {$0.refresh()}
        
        lblMainCaption.font = systemFontScheme.captionFont
        lblMainCaption.textColor = systemColorScheme.captionTextColor
        
        lblTabCaption.font = systemFontScheme.captionFont
        lblTabCaption.textColor = systemColorScheme.captionTextColor
    }
    
    override func destroy() {
        messenger.unsubscribeFromAll()
    }

    func menuWillOpen(_ menu: NSMenu) {
        
        let hasImage: Bool = TrackInfoViewContext.displayedTrack?.art?.image != nil
        
        exportArtMenuItem.showIf(hasImage)
        exportHTMLWithArtMenuItem.showIf(hasImage)
    }
    
    @IBAction func exportJPEGAction(_ sender: AnyObject) {
        doExportArt(.jpeg, "jpg")
    }
    
    @IBAction func exportPNGAction(_ sender: AnyObject) {
        doExportArt(.png, "png")
    }
    
    private func doExportArt(_ type: NSBitmapImageRep.FileType, _ fileExtension: String) {
        
        if let track = TrackInfoViewContext.displayedTrack {
            coverArtViewController.exportArt(forTrack: track, type: type, fileExtension: fileExtension)
        }
    }
    
    @IBAction func exportJSONAction(_ sender: AnyObject) {
        
        guard let track = TrackInfoViewContext.displayedTrack else {return}
        
        let dialog = DialogsAndAlerts.exportMetadataDialog(fileName: track.displayName + "-metadata", fileExtension: "json")
        guard dialog.runModal() == .OK, let outFile = dialog.url else {return}
        
        var appDict = [NSString: AnyObject]()
        appDict["version"] = NSApp.appVersion as AnyObject
        appDict["exportDate"] = dateFormatter.string(from: Date()) as AnyObject

        let dict: [NSString: AnyObject?] = ["appInfo": appDict as NSDictionary,
                                           "metadata": metadataViewController.jsonObject,
                                           "coverArt": coverArtViewController.jsonObject,
                                           "lyrics": lyricsViewController.jsonObject,
                                           "audio": audioViewController.jsonObject,
                                           "fileSystem": fileSystemViewController.jsonObject]
        
        do {
            try JSONSerialization.writeObject(dict as NSDictionary, toFile: outFile)
            
        } catch {
            
            if let error = error as? JSONWriteError {
                _ = DialogsAndAlerts.genericErrorAlert("JSON file not written", error.message, error.description).showModal()
            }
        }
    }
    
    @IBAction func exportHTMLWithArtAction(_ sender: AnyObject) {
        doExportHTML(withArt: true)
    }
    
    @IBAction func exportHTMLAction(_ sender: AnyObject) {
        doExportHTML(withArt: false)
    }
        
    private func doExportHTML(withArt includeArt: Bool) {
        
        guard let track = TrackInfoViewContext.displayedTrack else {return}
        
        let dialog = DialogsAndAlerts.exportMetadataDialog(fileName: track.displayName + "-metadata", fileExtension: "html")
        guard dialog.runModal() == .OK, let outFile = dialog.url else {return}
            
        do {
            let writer = HTMLWriter(outputFile: outFile)
            
            writer.addTitle(track.displayName)
            writer.addHeading(track.displayName, 2, false)
            
            let text = String(format: "Metadata exported by Aural Player v%@ on: %@", NSApp.appVersion, dateFormatter.string(from: Date()))
            let exportDate = HTMLText(text: text, underlined: true, bold: false, italic: false, width: nil)
            writer.addParagraph(exportDate)
            
            if includeArt {
                coverArtViewController.writeHTML(to: writer)
            }
            
            ([metadataViewController, lyricsViewController, audioViewController, fileSystemViewController] as? [TrackInfoViewProtocol])?.forEach {
                $0.writeHTML(to: writer)
            }
            
            try writer.writeToFile()
            
        } catch {
            
            if let error = error as? HTMLWriteError {
                _ = DialogsAndAlerts.genericErrorAlert("HTML file not written", error.message, error.description).showModal()
            }
        }
    }
    
    @IBAction func previousTabAction(_ sender: Any) {
        tabView.previousTab()
    }
    
    @IBAction func nextTabAction(_ sender: Any) {
        tabView.nextTab()
    }
}

protocol TrackInfoViewProtocol {
    
    func refresh()
    
    var view: NSView {get}
    
    var jsonObject: AnyObject? {get}
    
    func writeHTML(to writer: HTMLWriter)
}
