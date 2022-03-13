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
    
    private lazy var btnRepeatStateMachine: ButtonStateMachine<RepeatMode> = ButtonStateMachine(initialState: sequencer.repeatAndShuffleModes.repeatMode,
                                                                                                mappings: [
                                                                                                    ButtonStateMachine.StateMapping(state: .off, image: Images.imgRepeat, colorProperty: \.buttonOffColor, toolTip: "Repeat"),
                                                                                                    ButtonStateMachine.StateMapping(state: .all, image: Images.imgRepeat, colorProperty: \.buttonColor, toolTip: "Repeat"),
                                                                                                    ButtonStateMachine.StateMapping(state: .one, image: Images.imgRepeatOne, colorProperty: \.buttonColor, toolTip: "Repeat")
                                                                                                ],
                                                                                                button: btnRepeat)
    
    private lazy var btnShuffleStateMachine: ButtonStateMachine<ShuffleMode> = ButtonStateMachine(initialState: sequencer.repeatAndShuffleModes.shuffleMode,
                                                                                                  mappings: [
                                                                                                    ButtonStateMachine.StateMapping(state: .off, image: Images.imgShuffle, colorProperty: \.buttonOffColor, toolTip: "Shuffle"),
                                                                                                    ButtonStateMachine.StateMapping(state: .on, image: Images.imgShuffle, colorProperty: \.buttonColor, toolTip: "Shuffle")
                                                                                                  ],
                                                                                                  button: btnShuffle)
    
    // Delegate that conveys all repeat/shuffle requests to the sequencer
    let sequencer: SequencerDelegateProtocol = objectGraph.sequencerDelegate
    
    let colorSchemesManager: ColorSchemesManager = objectGraph.colorSchemesManager
    
    // When the buttons are in an "Off" state, they should be tinted according to the system color scheme's off state button color.
//    var offStateTintFunction: TintFunction {{.gray}}
//    
//    // When the buttons are in an "On" state, they should be tinted according to the system color scheme's function button color.
//    var onStateTintFunction: TintFunction {{.white}}
    
    lazy var messenger = Messenger(for: self)
    
    override func viewDidLoad() {
        
        updateRepeatAndShuffleControls(sequencer.repeatAndShuffleModes)
        
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
        updateRepeatAndShuffleControls(sequencer.toggleRepeatMode())
    }
    
    // Toggles the shuffle mode
    @IBAction func shuffleAction(_ sender: AnyObject) {
        toggleShuffleMode()
    }
    
    func toggleShuffleMode() {
        updateRepeatAndShuffleControls(sequencer.toggleShuffleMode())
    }
    
    func setRepeatMode(_ repeatMode: RepeatMode) {
        updateRepeatAndShuffleControls(sequencer.setRepeatMode(repeatMode))
    }
    
    func setShuffleMode(_ shuffleMode: ShuffleMode) {
        updateRepeatAndShuffleControls(sequencer.setShuffleMode(shuffleMode))
    }
    
    func updateRepeatAndShuffleControls(_ modes: (repeatMode: RepeatMode, shuffleMode: ShuffleMode)) {

        btnRepeatStateMachine.setState(modes.repeatMode)
        btnShuffleStateMachine.setState(modes.shuffleMode)
    }
}
