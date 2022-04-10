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
class PlayerSequencingViewController: NSViewController, Destroyable {

    @IBOutlet weak var btnRepeat: TintedImageButton!
    @IBOutlet weak var btnShuffle: TintedImageButton!
    
    private lazy var btnRepeatStateMachine: ButtonStateMachine<RepeatMode> = ButtonStateMachine(initialState: playQueue.repeatAndShuffleModes.repeatMode,
                                                                                                mappings: [
                                                                                                    ButtonStateMachine.StateMapping(state: .off, image: Images.imgRepeat, colorProperty: \.buttonOffColor, toolTip: "Repeat"),
                                                                                                    ButtonStateMachine.StateMapping(state: .all, image: Images.imgRepeat, colorProperty: \.buttonColor, toolTip: "Repeat"),
                                                                                                    ButtonStateMachine.StateMapping(state: .one, image: Images.imgRepeatOne, colorProperty: \.buttonColor, toolTip: "Repeat")
                                                                                                ],
                                                                                                button: btnRepeat)
    
    private lazy var btnShuffleStateMachine: ButtonStateMachine<ShuffleMode> = ButtonStateMachine(initialState: playQueue.repeatAndShuffleModes.shuffleMode,
                                                                                                  mappings: [
                                                                                                    ButtonStateMachine.StateMapping(state: .off, image: Images.imgShuffle, colorProperty: \.buttonOffColor, toolTip: "Shuffle"),
                                                                                                    ButtonStateMachine.StateMapping(state: .on, image: Images.imgShuffle, colorProperty: \.buttonColor, toolTip: "Shuffle")
                                                                                                  ],
                                                                                                  button: btnShuffle)
    
    // Delegate that conveys all repeat/shuffle requests to the sequencer
    let playQueue: PlayQueueDelegateProtocol = objectGraph.playQueueDelegate
    
    let colorSchemesManager: ColorSchemesManager = objectGraph.colorSchemesManager
    
    lazy var messenger = Messenger(for: self)
    
    override func viewDidLoad() {
        
        updateRepeatAndShuffleControls(playQueue.repeatAndShuffleModes)
        
        initSubscriptions()
    }
    
    func initSubscriptions() {}
    
    func destroy() {
        messenger.unsubscribeFromAll()
    }
    
    // Toggles the repeat mode
    @IBAction func repeatAction(_ sender: AnyObject) {
        toggleRepeatMode()
    }
    
    func toggleRepeatMode() {
        updateRepeatAndShuffleControls(playQueue.toggleRepeatMode())
    }
    
    // Toggles the shuffle mode
    @IBAction func shuffleAction(_ sender: AnyObject) {
        toggleShuffleMode()
    }
    
    func toggleShuffleMode() {
        updateRepeatAndShuffleControls(playQueue.toggleShuffleMode())
    }
    
    func setRepeatMode(_ repeatMode: RepeatMode) {
        updateRepeatAndShuffleControls(playQueue.setRepeatMode(repeatMode))
    }
    
    func setShuffleMode(_ shuffleMode: ShuffleMode) {
        updateRepeatAndShuffleControls(playQueue.setShuffleMode(shuffleMode))
    }
    
    func updateRepeatAndShuffleControls(_ modes: RepeatAndShuffleModes) {

        btnRepeatStateMachine.setState(modes.repeatMode)
        btnShuffleStateMachine.setState(modes.shuffleMode)
    }
}
