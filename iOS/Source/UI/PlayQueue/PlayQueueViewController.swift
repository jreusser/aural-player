//
//  PlayQueueViewController.swift
//  Aural-iOS
//
//  Created by Kartik Venugopal on 07/01/22.
//

import UIKit

class PlayQueueViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var playQueueView: UITableView!
    
    let playQueue = playQueueDelegate
    let player = playbackDelegate
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        let doubleTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTap(sender:)))
        doubleTapGestureRecognizer.numberOfTapsRequired = 2
        playQueueView.addGestureRecognizer(doubleTapGestureRecognizer)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        playQueue.size
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "PlayQueueCell", for: indexPath)
        
        guard let playQueueCell = cell as? PlayQueueCell else {
            return cell
        }
        
        let trackIndex = indexPath.row
        
        playQueueCell.lblIndex.text = "\(trackIndex + 1)"
        playQueueCell.lblTitle.text = playQueue[trackIndex]?.displayName ?? "<None>"
        
        return playQueueCell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {65}
    
    @objc func handleDoubleTap(sender: UITapGestureRecognizer) {
        
        let touchPoint = sender.location(in: playQueueView)
        
        if let indexPath = playQueueView.indexPathForRow(at: touchPoint),
           let track = playQueue[indexPath.row] {
            
            player.play(track)
        }
    }
}

class PlayQueueCell: UITableViewCell {
    
    @IBOutlet var lblIndex: UILabel!
    @IBOutlet var lblTitle: UILabel!
}
