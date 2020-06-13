/*
    View controller for the Now Playing info box which displays information about the currently playing track
 */
import Cocoa

class PlayingTrackViewController: NSViewController, ActionMessageSubscriber, MessageSubscriber {
    
    @IBOutlet weak var infoView: PlayingTrackView!
    
    // Delegate that conveys all seek and playback info requests to the player
    private let player: PlaybackInfoDelegateProtocol = ObjectGraph.playbackInfoDelegate
    
    override var nibName: String? {return "PlayingTrack"}
    
    override func viewDidLoad() {
        
        initSubscriptions()
        
        infoView.changeTextSize(PlayerViewState.textSize)
        infoView.applyColorScheme(ColorSchemes.systemScheme)
    }
    
    private func initSubscriptions() {
        
        // Subscribe to various notifications
        Messenger.subscribe(self, .chapterChanged, self.chapterChanged(_:))
        Messenger.subscribe(self, .trackNotPlayed, self.trackNotPlayed)
        
        SyncMessenger.subscribe(messageTypes: [.trackTransitionNotification, .playingTrackInfoUpdatedNotification], subscriber: self)
        
        SyncMessenger.subscribe(actionTypes: [.changePlayerView, .showOrHideAlbumArt, .showOrHideArtist, .showOrHideAlbum, .showOrHideCurrentChapter, .showOrHideMainControls, .showOrHidePlayingTrackInfo, .showOrHideSequenceInfo, .showOrHidePlayingTrackFunctions, .changePlayerTextSize, .applyColorScheme, .changeBackgroundColor, .changePlayerTrackInfoPrimaryTextColor, .changePlayerTrackInfoSecondaryTextColor, .changePlayerTrackInfoTertiaryTextColor], subscriber: self)
    }
    
    private func trackChanged(_ track: Track?) {
        
        if let theTrack = track {
            infoView.trackInfo = PlayingTrackInfo(theTrack, player.playingChapter?.chapter.title)
            
        } else {
            infoView.trackInfo = nil
        }
    }
    
    func trackNotPlayed() {
        self.trackChanged(nil as Track?)
    }
    
    // When track info for the playing track changes, display fields need to be updated
    private func playingTrackInfoUpdated() {
        infoView.update()
    }
    
    func chapterChanged(_ notification: ChapterChangedNotification) {
        
        if let playingTrack = player.playingTrack, PlayerViewState.showCurrentChapter {
            infoView.trackInfo = PlayingTrackInfo(playingTrack, notification.newChapter?.chapter.title)
        }
    }
    
    // MARK: Message handling

    func consumeMessage(_ message: ActionMessage) {
        
        if let pvActionMsg = message as? PlayerViewActionMessage {
            
            infoView.performAction(pvActionMsg)
            return
            
        } else if let colorComponentActionMsg = message as? ColorSchemeComponentActionMessage {
            
            infoView.applyColorSchemeComponent(colorComponentActionMsg)
            return
            
        } else if let colorSchemeActionMsg = message as? ColorSchemeActionMessage {
            
            infoView.applyColorScheme(colorSchemeActionMsg.scheme)
            return
            
        } else if let textSizeMessage = message as? TextSizeActionMessage {
            
            infoView.changeTextSize(textSizeMessage.textSize)
            return
        }
    }
    
    // Consume synchronous notification messages
    func consumeNotification(_ notification: NotificationMessage) {
        
        if let trackTransitionMsg = notification as? TrackTransitionNotification {
            
            trackChanged(trackTransitionMsg.endTrack)
            return
            
        } else if notification is PlayingTrackInfoUpdatedNotification {
         
            playingTrackInfoUpdated()
            return
        }
    }
}

// Encapsulates displayed information for the currently playing track.
struct PlayingTrackInfo {
    
    let track: Track
    let playingChapterTitle: String?
    
    init(_ track: Track, _ playingChapterTitle: String?) {
        
        self.track = track
        self.playingChapterTitle = playingChapterTitle
    }
    
    var art: NSImage? {
        return track.displayInfo.art?.image
    }
    
    var artist: String? {
        return track.displayInfo.artist
    }
    
    var album: String? {
        return track.groupingInfo.album
    }
    
    var displayName: String? {
        return track.displayInfo.title ?? track.conciseDisplayName
    }
}
