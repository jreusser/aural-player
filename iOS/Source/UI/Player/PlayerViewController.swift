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
    
    let player = objectGraph.playbackDelegate
    var audioGraph = objectGraph.audioGraphDelegate
    
    private lazy var messenger: Messenger = Messenger(for: self)

    override func viewDidLoad() {
        
        super.viewDidLoad()
        volumeSlider.value = audioGraph.volume
        
        messenger.subscribe(to: .player_trackTransitioned, handler: trackTransitioned)
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
    
    private func trackTransitioned() {
        
        updatePlayPauseButton()
        volumeSlider.value = audioGraph.volume
    }
}
