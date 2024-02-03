//
//  TrackInfoViewController+Theming.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import AppKit

extension TrackInfoViewController: FontSchemeObserver {
    
    func fontSchemeChanged() {
        
        lblMainCaption.font = systemFontScheme.captionFont
        lblTrackTitle.font = systemFontScheme.prominentFont
        lblTabCaption.font = systemFontScheme.captionFont
        
        tabViewControllers.forEach {
            $0.fontSchemeChanged()
        }
    }
}

extension TrackInfoViewController: ColorSchemeObserver {
    
    func colorSchemeChanged() {

        lblMainCaption.textColor = systemColorScheme.captionTextColor
        updateTrackTitle()
        lblTabCaption.textColor = systemColorScheme.captionTextColor
        
        exportMenuIcon.colorChanged(systemColorScheme.buttonColor)
        
        tabButtonsBox.fillColor = systemColorScheme.backgroundColor
        tabButtons.forEach {
            $0.redraw()
        }
        
        tabViewControllers.forEach {
            $0.colorSchemeChanged()
        }
    }
    
    func backgroundColorChanged(_ newColor: PlatformColor) {
        
        tabButtonsBox.fillColor = newColor
        
        tabViewControllers.forEach {
            $0.backgroundColorChanged(newColor)
        }
    }
    
    func primaryTextColorChanged(_ newColor: PlatformColor) {
        
        updateTrackTitle()
        
        tabViewControllers.forEach {
            $0.primaryTextColorChanged(newColor)
        }
    }
    
    func secondaryTextColorChanged(_ newColor: PlatformColor) {
        
        updateTrackTitle()
        
        tabViewControllers.forEach {
            $0.secondaryTextColorChanged(newColor)
        }
    }
    
    func buttonColorChanged(_ newColor: PlatformColor) {
        tabButtons[tabView.selectedIndex].redraw()
    }
    
    func inactiveControlColorChanged(_ newColor: PlatformColor) {
        
        for button in tabButtons {
            
            if let buttonCell = button.cell as? TabGroupButtonCell, !buttonCell.isOn {
                button.redraw()
            }
        }
    }
}
