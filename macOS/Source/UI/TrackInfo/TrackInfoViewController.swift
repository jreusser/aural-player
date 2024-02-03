//
//  TrackInfoViewController.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import AppKit

class TrackInfoViewController: NSViewController {
    
    @IBOutlet weak var tabView: AuralTabView!
    
    @IBOutlet weak var lblMainCaption: NSTextField!
    @IBOutlet weak var lblTrackTitle: NSTextField!
    @IBOutlet weak var lblTabCaption: NSTextField!
    
    @IBOutlet weak var exportMenuIcon: TintedIconMenuItem!
    
    @IBOutlet weak var tabButtonsBox: NSBox!
    @IBOutlet weak var btnMetadataTab: NSButton!
    @IBOutlet weak var btnLyricsTab: NSButton!
    @IBOutlet weak var btnCoverArtTab: NSButton!
    @IBOutlet weak var btnAudioTab: NSButton!
    @IBOutlet weak var btnFileSystemTab: NSButton!
    
    lazy var tabButtons: [NSButton] = [btnMetadataTab, btnLyricsTab, btnCoverArtTab, btnAudioTab, btnFileSystemTab]
    
    @IBOutlet weak var exportArtMenuItem: NSMenuItem!
    @IBOutlet weak var exportHTMLWithArtMenuItem: NSMenuItem!
    
    let metadataViewController: MetadataTrackInfoViewController = MetadataTrackInfoViewController()
    let lyricsViewController: LyricsTrackInfoViewController = LyricsTrackInfoViewController()
    let coverArtViewController: CoverArtTrackInfoViewController = CoverArtTrackInfoViewController()
    let audioViewController: AudioTrackInfoViewController = AudioTrackInfoViewController()
    let fileSystemViewController: FileSystemTrackInfoViewController = FileSystemTrackInfoViewController()
    
    var tabViewControllers: [TrackInfoViewProtocol] = []
    
    lazy var dateFormatter: DateFormatter = DateFormatter(format: "MMMM dd, yyyy 'at' hh:mm:ss a")
    
    private lazy var messenger = Messenger(for: self)
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        tabViewControllers = [metadataViewController, lyricsViewController, coverArtViewController,
                           audioViewController, fileSystemViewController]
        
        let tabViews = tabViewControllers.map {$0.view}
        
        tabView.addViewsForTabs(tabViews)
        tabView.delegate = self
        
        tabViews.forEach {
            $0.anchorToSuperview()
        }
        
        tabView.selectTabViewItem(at: 0)
        
        fontSchemesManager.registerObserver(self)
        
        colorSchemesManager.registerSchemeObserver(self)
        colorSchemesManager.registerPropertyObserver(self, forProperty: \.backgroundColor, handler: backgroundColorChanged(_:))
        colorSchemesManager.registerPropertyObserver(self, forProperty: \.captionTextColor, changeReceivers: [lblMainCaption, lblTabCaption])
        colorSchemesManager.registerPropertyObserver(self, forProperty: \.primaryTextColor, handler: primaryTextColorChanged(_:))
        colorSchemesManager.registerPropertyObserver(self, forProperty: \.secondaryTextColor, handler: secondaryTextColorChanged(_:))
        colorSchemesManager.registerPropertyObserver(self, forProperty: \.buttonColor, handler: buttonColorChanged(_:))
        colorSchemesManager.registerPropertyObserver(self, forProperty: \.buttonColor, changeReceiver: exportMenuIcon)
        colorSchemesManager.registerPropertyObserver(self, forProperty: \.inactiveControlColor, handler: inactiveControlColorChanged(_:))
        
        // Only respond to these notifications when the popover is shown, the updated track matches the displayed track,
        // and the album art field of the track was updated.
        messenger.subscribeAsync(to: .player_trackInfoUpdated, handler: coverArtViewController.trackInfoUpdated(_:),
                                 filter: {[weak self] msg in (self?.view.window?.isVisible ?? false) &&
                                    msg.updatedTrack == TrackInfoViewContext.displayedTrack &&
                                    msg.updatedFields.contains(.art)})
        
        messenger.subscribe(to: .trackInfo_refresh, handler: refresh)
    }
    
    override func viewWillAppear() {
        
        super.viewWillAppear()
        refresh()
    }
    
    private func refresh() {
        
        updateTrackTitle()
        
        tabViewControllers.forEach {$0.refresh()}
        tabView.selectTabViewItem(at: 0)
        
        fontSchemeChanged()
        colorSchemeChanged()
    }
    
    func updateTrackTitle() {
        
        if let displayedTrack = TrackInfoViewContext.displayedTrack {
            
            if let artist = displayedTrack.artist, let title = displayedTrack.title {
                
                lblTrackTitle.attributedStringValue = "\(artist)  ".attributed(font: systemFontScheme.prominentFont, color: systemColorScheme.secondaryTextColor) +
                title.attributed(font: systemFontScheme.prominentFont, color: systemColorScheme.primaryTextColor)
                
            } else {
                lblTrackTitle.stringValue = displayedTrack.displayName
            }
            
        } else {
            lblTrackTitle.stringValue = "<No Track displayed>"
        }
    }
    
    override func destroy() {
        messenger.unsubscribeFromAll()
    }

    @IBAction func previousTabAction(_ sender: Any) {
        tabView.previousTab()
    }
    
    @IBAction func nextTabAction(_ sender: Any) {
        tabView.nextTab()
    }
}

extension TrackInfoViewController: NSTabViewDelegate {
    
    func tabView(_ tabView: NSTabView, didSelect tabViewItem: NSTabViewItem?) {
        lblTabCaption.stringValue = self.tabView.items[tabView.selectedIndex].tabButton.toolTip ?? ""
    }
}

protocol TrackInfoViewProtocol where Self: NSViewController {
    
    func refresh()
    
    func fontSchemeChanged()
    
    func colorSchemeChanged()
    
    func backgroundColorChanged(_ newColor: PlatformColor)
    
    func primaryTextColorChanged(_ newColor: PlatformColor)
    
    func secondaryTextColorChanged(_ newColor: PlatformColor)
    
    var view: NSView {get}
    
    var jsonObject: AnyObject? {get}
    
    func writeHTML(to writer: HTMLWriter)
}

class TrackInfoViewContext {
    
    // Temporary holder for the currently shown track
    static var displayedTrack: Track!
}
