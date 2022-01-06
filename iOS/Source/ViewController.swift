//
//  ViewController.swift
//  Aural-iOS
//
//  Created by Kartik Venugopal on 06/01/22.
//

import UIKit

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var playlistView: UITableView!
    
    @IBOutlet weak var btnPlay: UIButton!
    @IBOutlet weak var btnSeekForward: UIButton!
    @IBOutlet weak var btnSeekBackward: UIButton!
    
    @IBOutlet weak var volumeSlider: UISlider!
    @IBOutlet weak var seekSlider: UISlider!
    
    let playlist = objectGraph.playlistDelegate
    let player = objectGraph.playbackDelegate
    var audioGraph = objectGraph.audioGraphDelegate

    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        let appTitleView = UIImageView(frame: CGRect(x: 0, y: 0, width: 100, height: 30))
        appTitleView.image = PlatformImage(named: "AppTitle")!
        
        navigationItem.titleView = appTitleView
        
        volumeSlider.value = audioGraph.volume
        
        let doubleTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTap(sender:)))
        doubleTapGestureRecognizer.numberOfTapsRequired = 2
        playlistView.addGestureRecognizer(doubleTapGestureRecognizer)
    }
    
    // ----------------------------------------------------------------------------------------------------
    
    // MARK: Table view
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        playlist.size
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "PlaylistCell", for: indexPath)
        
        guard let playlistCell = cell as? PlaylistCell else {
            return cell
        }
        
        let trackIndex = indexPath.row
        playlistCell.titleLabel.text = playlist.trackAtIndex(trackIndex)?.displayName ?? "<None>"
        playlistCell.titleLabel.textColor = .white
        
        return playlistCell
    }
    
    @objc func handleDoubleTap(sender: UITapGestureRecognizer) {
        
        let touchPoint = sender.location(in: playlistView)
        
        if let indexPath = playlistView.indexPathForRow(at: touchPoint),
           let track = playlist.trackAtIndex(indexPath.row) {
            
            player.play(track)
        }
    }
    
    // ----------------------------------------------------------------------------------------------------
    
    // MARK: Actions
    
    @IBAction func playPauseAction(_ sender: Any) {
        
        player.togglePlayPause()
        
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
}

class PlaylistCell: UITableViewCell {
    @IBOutlet var titleLabel: UILabel!

}
