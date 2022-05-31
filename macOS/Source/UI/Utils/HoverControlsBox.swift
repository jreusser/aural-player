//
//  HoverControlsBox.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import Cocoa

class HoverControlsBox: NSBox {
    
    @IBOutlet weak var btnPlay: TintedImageButton!
    @IBOutlet weak var btnRepeat: TintedImageButton!
    @IBOutlet weak var btnShuffle: TintedImageButton!
    
    private lazy var messenger: Messenger = Messenger(for: self)
    
    var group: Group? {
        
        didSet {
            
            guard let groupName = group?.name,
            let groupType = group?.groupType else {return}
            
            btnPlay.toolTip = "Play \(groupType) '\(groupName)'"
            btnRepeat.toolTip = "Repeat \(groupType) '\(groupName)'"
            btnShuffle.toolTip = "Shuffle \(groupType) '\(groupName)'"
        }
    }
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        
        colorSchemesManager.registerObservers([btnPlay, btnRepeat, btnShuffle],
                                              forProperty: \.buttonColor)
    }
    
    @IBAction func playGroupAction(_ sender: NSButton) {
        doPlay()
    }
    
    @IBAction func repeatGroupAction(_ sender: NSButton) {
        
        messenger.publish(.player_setRepeatMode, payload: RepeatMode.all)
        messenger.publish(.player_setShuffleMode, payload: ShuffleMode.off)
        
        doPlay()
    }
    
    @IBAction func shuffleGroupAction(_ sender: NSButton) {
        
        messenger.publish(.player_setRepeatMode, payload: RepeatMode.off)
        messenger.publish(.player_setShuffleMode, payload: ShuffleMode.on)
        
        doPlay()
    }
    
    private func doPlay() {
        
        if let group = self.group {
            messenger.publish(EnqueueAndPlayNowCommand(tracks: group.tracks, clearPlayQueue: false))
        }
    }
}
