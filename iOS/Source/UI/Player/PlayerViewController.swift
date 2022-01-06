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
    
    let player = objectGraph.playbackDelegate
    var audioGraph = objectGraph.audioGraphDelegate
    
    private lazy var messenger: Messenger = Messenger(for: self, asyncNotificationQueue: .main)

    override func viewDidLoad() {
        
        super.viewDidLoad()
        volumeSlider.value = audioGraph.volume
        
        imgArt.layer.cornerRadius = 4
        
        messenger.subscribe(to: .player_trackTransitioned, handler: trackTransitioned(_:))
        messenger.subscribeAsync(to: .player_trackInfoUpdated, handler: trackInfoUpdated(_:))
    }
    
    @IBAction func playPauseAction(_ sender: Any) {
        
        player.togglePlayPause()
        updatePlayPauseButton()
    }
    
    private func updatePlayPauseButton() {
        
        if player.state == .playing {
            btnPlay.setBackgroundImage(PlatformImage(systemName: "pause"), for: .normal)
        } else {
            btnPlay.setBackgroundImage(PlatformImage(systemName: "play"), for: .normal)
        }
    }
    
    @IBAction func previousTrackAction(_ sender: Any) {
        player.previousTrack()
    }
    
    @IBAction func nextTrackAction(_ sender: Any) {
        player.nextTrack()
    }
    
    @IBAction func volumeAction(_ sender: Any) {
        audioGraph.volume = volumeSlider.value
    }
    
    @IBAction func seekBackwardAction(_ sender: Any) {
    }
    
    @IBAction func seekForwardAction(_ sender: Any) {
    }
    
    @IBAction func seekAction(_ sender: Any) {
    }
    
    // MARK: Notification handling
    
    private func trackTransitioned(_ notif: TrackTransitionNotification) {
        
        updatePlayPauseButton()
        volumeSlider.value = audioGraph.volume
        
        guard let newTrack = notif.endTrack else {
            
            [lblTitle, lblArtistAlbum, lblTitleOnly].forEach {$0?.isHidden = true}
            imgArt.image = nil
            
            return
        }
        
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
        
        if notif.updatedTrack == player.playingTrack {
            imgArt.image = notif.updatedTrack.art?.image
        }
    }
}
