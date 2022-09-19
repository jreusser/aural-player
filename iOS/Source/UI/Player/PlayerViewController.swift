//
//  PlayerViewController.swift
//  Aural-iOS
//
//  Created by Kartik Venugopal on 07/01/22.
//

import UIKit

class PlayerViewController: UIViewController {
    
    @IBOutlet weak var btnPlay: UIButton!
    
    @IBOutlet weak var volumeSlider: UISlider!
    @IBOutlet weak var seekSlider: UISlider!
    
    @IBOutlet weak var imgArt: UIImageView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblArtistAlbum: UILabel!
    @IBOutlet weak var lblTitleOnly: UILabel!
    
    @IBOutlet weak var lblTimeElapsed: UILabel!
    @IBOutlet weak var lblTimeRemaining: UILabel!
    
    // Timer that periodically updates the seek position slider and label
    var seekTimer: RepeatingTaskExecutor?
    
    private lazy var messenger: Messenger = Messenger(for: self, asyncNotificationQueue: .main)

    override func viewDidLoad() {
        
        super.viewDidLoad()
        volumeSlider.value = audioGraphDelegate.volume
        
        imgArt.layer.cornerRadius = 4
        [lblTitle, lblArtistAlbum, lblTitleOnly, lblTimeElapsed, lblTimeRemaining].forEach {$0?.isHidden = true}
        
        let seekTimerInterval = 500
        seekTimer = RepeatingTaskExecutor(intervalMillis: seekTimerInterval,
                                          task: updateSeekPosition,
                                          queue: .main)
        
        messenger.subscribe(to: .player_trackTransitioned, handler: trackTransitioned(_:))
        messenger.subscribeAsync(to: .player_trackInfoUpdated, handler: trackInfoUpdated(_:))
    }
    
    @IBAction func playPauseAction(_ sender: Any) {
        
        playbackDelegate.togglePlayPause()
        updatePlayPauseButton()
    }
    
    private func updatePlayPauseButton() {
        
        if playbackDelegate.state == .playing {
            btnPlay.setBackgroundImage(PlatformImage(systemName: "pause"), for: .normal)
        } else {
            btnPlay.setBackgroundImage(PlatformImage(systemName: "play"), for: .normal)
        }
    }
    
    @IBAction func previousTrackAction(_ sender: Any) {
        playbackDelegate.previousTrack()
    }
    
    @IBAction func nextTrackAction(_ sender: Any) {
        playbackDelegate.nextTrack()
    }
    
    @IBAction func volumeAction(_ sender: Any) {
        audioGraphDelegate.volume = volumeSlider.value
    }
    
    @IBAction func seekBackwardAction(_ sender: Any) {
    }
    
    @IBAction func seekForwardAction(_ sender: Any) {
    }
    
    @IBAction func seekAction(_ sender: Any) {
        
        playbackDelegate.seekToPercentage(Double(seekSlider.value))
        updateSeekPosition()
    }
    
    func updateSeekPosition() {
        
        let seekPosn = playbackDelegate.seekPosition
        seekSlider.value = Float(seekPosn.percentageElapsed)
        
        let trackTimes = ValueFormatter.formatTrackTimes(seekPosn.timeElapsed, seekPosn.trackDuration, seekPosn.percentageElapsed)
        
        lblTimeElapsed.text = trackTimes.elapsed
        lblTimeRemaining.text = trackTimes.remaining
    }
    
    // MARK: Notification handling
    
    private func trackTransitioned(_ notif: TrackTransitionNotification) {
        
        updatePlayPauseButton()
        volumeSlider.value = audioGraphDelegate.volume
        
        guard let newTrack = notif.endTrack else {
            
            [lblTitle, lblArtistAlbum, lblTitleOnly, lblTimeElapsed, lblTimeRemaining].forEach {$0?.isHidden = true}
            imgArt.image = nil
            seekTimer?.pause()
            
            return
        }
        
        [lblTimeElapsed, lblTimeRemaining].forEach {$0.isHidden = false}
        seekTimer?.startOrResume()
        
        imgArt.image = newTrack.art?.image
            
        if let title = newTrack.title {
            
            if let artist = newTrack.artist, let album = newTrack.album {
                
                // Title, artist, and album
                lblTitle.text = title
                lblArtistAlbum.text = "\(artist) -- \(album)"
                
                [lblTitle, lblArtistAlbum].forEach {$0?.isHidden = false}
                lblTitleOnly.isHidden = true
                
            } else if let artist = newTrack.artist {
                
                // Title and artist
                lblTitle.text = title
                lblArtistAlbum.text = artist
                
                [lblTitle, lblArtistAlbum].forEach {$0?.isHidden = false}
                lblTitleOnly.isHidden = true
                
            } else if let album = newTrack.album {
                
                // Title and album
                lblTitle.text = title
                lblArtistAlbum.text = album
                
                [lblTitle, lblArtistAlbum].forEach {$0?.isHidden = false}
                lblTitleOnly.isHidden = true
                
            } else {
                
                // Title only
                lblTitleOnly.text = title
                
                [lblTitle, lblArtistAlbum].forEach {$0?.isHidden = true}
                lblTitleOnly.isHidden = false
            }
            
        } else {
            
            // Title only
            lblTitleOnly.text = newTrack.displayName
            
            [lblTitle, lblArtistAlbum].forEach {$0?.isHidden = true}
            lblTitleOnly.isHidden = false
        }
    }
    
    private func trackInfoUpdated(_ notif: TrackInfoUpdatedNotification) {
        
        if notif.updatedTrack == playbackDelegate.playingTrack {
            imgArt.image = notif.updatedTrack.art?.image
        }
    }
}
