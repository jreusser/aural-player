//
//  MenuBarPlayerSequencingViewController.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

class MenuBarPlayerSequencingViewController: PlayerSequencingViewController {
    
    override func initSubscriptions() {}
    
    override func updateRepeatAndShuffleControls(_ modes: RepeatAndShuffleModes) {
        
        guard let btnRepeat = btnRepeat as? FillableImageButton,
              let btnShuffle = btnShuffle as? FillableImageButton else {
            
            return
        }
        
        switch modes.repeatMode {
            
        case .off:
            btnRepeat.fill(image: .imgRepeat, withColor: .darkGray)
            
        case .all:
            btnRepeat.fill(image: .imgRepeat, withColor: .white)
            
        case .one:
            btnRepeat.fill(image: .imgRepeatOne, withColor: .white)
        }
        
        btnShuffle.fill(image: .imgShuffle, withColor: modes.shuffleMode == .on ? .white : .darkGray)
    }
}
