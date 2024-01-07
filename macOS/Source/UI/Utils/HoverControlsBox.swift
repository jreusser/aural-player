//
//  HoverControlsBox.swift
//  Aural
//
//  Copyright © 2023 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import Cocoa

class HoverControlsBox: NSBox {
    
    @IBOutlet weak var btnPlay: TintedImageButton!
    @IBOutlet weak var btnEnqueueAndPlay: TintedImageButton!
    @IBOutlet weak var btnRepeat: TintedImageButton!
    @IBOutlet weak var btnShuffle: TintedImageButton!
    
    private lazy var messenger: Messenger = Messenger(for: self)
    
    var group: Group? {
        
        didSet {
            
            guard let groupName = group?.displayName else {return}
            
            btnPlay.toolTip = "Play \(groupName)"
            btnEnqueueAndPlay.toolTip = "Enqueue and play \(groupName)"
            btnRepeat.toolTip = "Repeat \(groupName)"
            btnShuffle.toolTip = "Shuffle \(groupName)"
        }
    }
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        
        colorSchemesManager.registerObservers([btnPlay, btnEnqueueAndPlay, btnRepeat, btnShuffle],
                                              forProperty: \.buttonColor)
    }
    
    @IBAction func playGroupAction(_ sender: NSButton) {
        
        messenger.publish(.player_setRepeatMode, payload: RepeatMode.off)
        messenger.publish(.player_setShuffleMode, payload: ShuffleMode.off)
        
        doPlay(clearPlayQueue: true)
    }
    
    @IBAction func enqueueAndPlayGroupAction(_ sender: NSButton) {
        doPlay(clearPlayQueue: false)
    }
    
    @IBAction func repeatGroupAction(_ sender: NSButton) {
        
        messenger.publish(.player_setRepeatMode, payload: RepeatMode.all)
        messenger.publish(.player_setShuffleMode, payload: ShuffleMode.off)
        
        doPlay(clearPlayQueue: true)
    }
    
    @IBAction func shuffleGroupAction(_ sender: NSButton) {
        
        messenger.publish(.player_setRepeatMode, payload: RepeatMode.off)
        messenger.publish(.player_setShuffleMode, payload: ShuffleMode.on)
        
        doPlay(clearPlayQueue: true)
    }
    
    private func doPlay(clearPlayQueue: Bool) {
        
        if let group = self.group {
            
            messenger.publish(LibraryGroupPlayedNotification(group: group))
            messenger.publish(EnqueueAndPlayNowCommand(tracks: group.tracks, clearPlayQueue: clearPlayQueue))
        }
    }
}
