//
//  PlayerSequencingViewController.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

/*
    View controller for playback sequencing controls (repeat/shuffle).
    Also handles sequencing requests from app menus.
 */
class PlayerSequencingViewController: NSViewController, NotificationSubscriber, Destroyable {
    
    @IBOutlet weak var btnShuffle: MultiStateImageButton!
    @IBOutlet weak var btnRepeat: MultiStateImageButton!
    
    // Delegate that conveys all repeat/shuffle requests to the sequencer
    let sequencer: SequencerDelegateProtocol = ObjectGraph.sequencerDelegate
    
    let colorSchemesManager: ColorSchemesManager = ObjectGraph.colorSchemesManager
    
    // When the buttons are in an "Off" state, they should be tinted according to the system color scheme's off state button color.
    var offStateTintFunction: TintFunction {{.gray}}
    
    // When the buttons are in an "On" state, they should be tinted according to the system color scheme's function button color.
    var onStateTintFunction: TintFunction {{.white}}
    
    override func viewDidLoad() {
        
        btnRepeat.stateImageMappings = [(RepeatMode.off, (Images.imgRepeatOff, offStateTintFunction)), (RepeatMode.one, (Images.imgRepeatOne, onStateTintFunction)), (RepeatMode.all, (Images.imgRepeatAll, onStateTintFunction))]

        btnShuffle.stateImageMappings = [(ShuffleMode.off, (Images.imgShuffleOff, offStateTintFunction)), (ShuffleMode.on, (Images.imgShuffleOn, onStateTintFunction))]
        
        updateRepeatAndShuffleControls(sequencer.repeatAndShuffleModes)
        
        initSubscriptions()
    }
    
    func initSubscriptions() {}
    
    func destroy() {
        Messenger.unsubscribeAll(for: self)
    }
    
    // Toggles the repeat mode
    @IBAction func repeatAction(_ sender: AnyObject) {
        updateRepeatAndShuffleControls(sequencer.toggleRepeatMode())
    }
    
    // Toggles the shuffle mode
    @IBAction func shuffleAction(_ sender: AnyObject) {
        updateRepeatAndShuffleControls(sequencer.toggleShuffleMode())
    }
    
    func setRepeatMode(_ repeatMode: RepeatMode) {
        updateRepeatAndShuffleControls(sequencer.setRepeatMode(repeatMode))
    }
    
    func setShuffleMode(_ shuffleMode: ShuffleMode) {
        updateRepeatAndShuffleControls(sequencer.setShuffleMode(shuffleMode))
    }
    
    func updateRepeatAndShuffleControls(_ modes: (repeatMode: RepeatMode, shuffleMode: ShuffleMode)) {

        btnShuffle.switchState(modes.shuffleMode)
        btnRepeat.switchState(modes.repeatMode)
    }
}
