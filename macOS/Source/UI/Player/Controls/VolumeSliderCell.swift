//
//  VolumeSliderCell.swift
//  Aural
//
//  Copyright © 2023 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

// Cell for volume slider
class VolumeSliderCell: HorizontalSliderCell {
    
    override var knobWidth: CGFloat {10}
    override var knobHeightOutsideBar: CGFloat {4}
}
