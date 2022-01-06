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
    
    let playlist = objectGraph.playlistDelegate
    let player = objectGraph.playbackDelegate

    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        let doubleTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTap(sender:)))
        
            doubleTapGestureRecognizer.numberOfTapsRequired = 2
        playlistView.addGestureRecognizer(doubleTapGestureRecognizer)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        playlist.size
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "PlaylistCell", for: indexPath) as? PlaylistCell else {
            fatalError("Could not create reusable PlaylistCell !")
        }
        
        let trackIndex = indexPath.row
        cell.titleLabel.text = playlist.trackAtIndex(trackIndex)?.displayName ?? "<None>"
        cell.titleLabel.textColor = .white
        
        return cell
    }
    
    @objc func handleDoubleTap(sender: UITapGestureRecognizer) {
        
        let touchPoint = sender.location(in: playlistView)
        
        if let indexPath = playlistView.indexPathForRow(at: touchPoint),
           let track = playlist.trackAtIndex(indexPath.row) {
            
            player.play(track)
        }
    }
}

class PlaylistCell: UITableViewCell {
    @IBOutlet var titleLabel: UILabel!

}
