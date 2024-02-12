import Cocoa

class NowPlayingViewController: NSViewController {
    
    override var nibName: String? {return "NowPlaying"}
    
    @IBOutlet weak var albumArtView: NSImageView!
    
    @IBOutlet weak var lblTitle: NSTextField!
    @IBOutlet weak var lblArtistAlbum: NSTextField!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
//        //fontSchemesManager.registerObserver(lblTitle, forProperty: \.prominentFont)
//        colorSchemesManager.registerObserver(lblTitle, forProperty: \.primaryTextColor)
//        
//        //fontSchemesManager.registerObserver(lblArtistAlbum, forProperty: \.normalFont)
//        colorSchemesManager.registerObserver(lblArtistAlbum, forProperty: \.secondaryTextColor)
        
        // MARK: Notifications --------------------------------------------------------------
        
//        Messenger.subscribeAsync(self, .Player.trackTransitioned, self.trackTransitioned(_:), queue: .main)
//        Messenger.subscribe(self, .Player.trackNotPlayed, self.trackNotPlayed(_:))
        
        // MARK: Commands --------------------------------------------------------------
        
//        Messenger.subscribe(self, .applyColorScheme, playbackView.applyColorScheme(_:))
//        Messenger.subscribe(self, .changeFunctionButtonColor, playbackView.changeFunctionButtonColor(_:))
//        Messenger.subscribe(self, .changeToggleButtonOffStateColor, playbackView.changeToggleButtonOffStateColor(_:))
//
//        Messenger.subscribe(self, .Player.changeTextSize, playbackView.changeTextSize(_:))
    }
    
    // The "errorState" arg indicates whether the player is in an error state (i.e. the new track cannot be played back). If so, update the UI accordingly.
    private func trackChanged(_ newTrack: Track?) {
        
        if let track = newTrack {
            
            albumArtView.image = track.art?.image ?? .imgPlayingArt
            
            lblTitle.stringValue = track.title ?? track.defaultDisplayName
            
            let artist = track.artist
            let album = track.album
            
            if let theArtist = artist, let theAlbum = album {
                lblArtistAlbum.stringValue = "\(theArtist) -- \(theAlbum)"
                
            } else if let theArtist = artist {
                lblArtistAlbum.stringValue = theArtist
                
            } else if let theAlbum = album {
                lblArtistAlbum.stringValue = theAlbum
                
            } else {
                lblArtistAlbum.stringValue = ""
            }
            
        } else {  // No track
            
            albumArtView.image = .imgPlayingArt
            [lblTitle, lblArtistAlbum].forEach {$0?.stringValue = ""}
        }
    }
    
    func trackNotPlayed(_ notification: TrackNotPlayedNotification) {
        self.trackChanged(nil)
    }
 
    // MARK: Message handling ---------------------------------------------------------------------
    
    func trackTransitioned(_ notification: TrackTransitionNotification) {
        trackChanged(notification.endTrack)
    }
}
