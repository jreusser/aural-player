//
//  DevicesViewController.swift
//  Aural
//
//  Copyright © 2023 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import Cocoa

class DevicesViewController: NSViewController, FontSchemePropertyObserver, ColorSchemeObserver {
    
    override var nibName: String? {"Devices"}
    
    // ------------------------------------------------------------------------
    
    // MARK: UI fields
    
    @IBOutlet weak var tableView: NSTableView!
    
    @IBOutlet weak var panSlider: NSSlider!
    @IBOutlet weak var lblPan: VALabel!

    // Caption labels
    
    @IBOutlet weak var lblBalance: VALabel!
    @IBOutlet weak var lblPanLeft: VALabel!
    @IBOutlet weak var lblPanRight: VALabel!
    
    private lazy var audioGraph: AudioGraphDelegateProtocol = audioGraphDelegate
    private lazy var soundProfiles: SoundProfiles = audioGraphDelegate.soundProfiles
    private lazy var messenger: Messenger = Messenger(for: self)
    
    var selectionChangeIsInternal: Bool = true
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        panSlider.floatValue = audioGraph.pan
        lblPan.stringValue = audioGraph.formattedPan
        
        fontSchemesManager.registerObserver(self, forProperty: \.effectsPrimaryFont)
        fontSchemesManager.registerObservers([lblBalance, lblPanLeft, lblPanRight, lblPan], forProperty: \.effectsPrimaryFont)

        colorSchemesManager.registerObservers([lblBalance, lblPanLeft, lblPanRight], forProperty: \.secondaryTextColor)
        colorSchemesManager.registerObserver(lblPan, forProperty: \.primaryTextColor)
        
        colorSchemesManager.registerObserver(self, forProperties: [\.backgroundColor, \.primaryTextColor, \.textSelectionColor])
        
        colorSchemesManager.registerSchemeObserver(panSlider, forProperties: [\.backgroundColor, \.activeControlColor, \.inactiveControlColor])
        
        messenger.subscribe(to: .player_panLeft, handler: panLeft)
        messenger.subscribe(to: .player_panRight, handler: panRight)
        
        messenger.subscribeAsync(to: .player_trackTransitioned, handler: trackTransitioned(_:),
                                 filter: {msg in msg.trackChanged})
        
        messenger.subscribeAsync(to: .deviceManager_deviceListUpdated, handler: deviceListUpdated)
        messenger.subscribeAsync(to: .deviceManager_defaultDeviceChanged, handler: defaultDeviceChanged)
        
        deviceListUpdated()
    }
    
    @IBAction func panAction(_ sender: Any) {
        
        audioGraph.pan = panSlider.floatValue
        lblPan.stringValue = audioGraph.formattedPan
    }
    
    // Pans the sound towards the left channel, by a certain preset value
    func panLeft() {
        
        panSlider.floatValue = audioGraph.panLeft()
        lblPan.stringValue = audioGraph.formattedPan
        
        messenger.publish(.effects_showEffectsUnitTab, payload: EffectsUnitType.devices)
    }
    
    // Pans the sound towards the right channel, by a certain preset value
    func panRight() {
        
        panSlider.floatValue = audioGraph.panRight()
        lblPan.stringValue = audioGraph.formattedPan
        
        messenger.publish(.effects_showEffectsUnitTab, payload: EffectsUnitType.devices)
    }
    
    private func trackTransitioned(_ notification: TrackTransitionNotification) {
        
        // Apply sound profile if there is one for the new track and the preferences allow it
        guard let theNewTrack = notification.endTrack, soundProfiles.hasFor(theNewTrack) else {return}
        
        panSlider.floatValue = audioGraph.pan
        lblPan.stringValue = audioGraph.formattedPan
    }
    
    // ---------------------------------------------------------------------------------------------------------
    
    // MARK: Device list updates
    
    private func deviceListUpdated() {
        
        selectionChangeIsInternal = true
        
        tableView.reloadData()
        tableView.selectRow(audioGraphDelegate.indexOfOutputDevice)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            self.selectionChangeIsInternal = false
        }
    }
    
    private func defaultDeviceChanged() {
        
        selectionChangeIsInternal = true
        
        tableView.selectRow(audioGraphDelegate.indexOfOutputDevice)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            self.selectionChangeIsInternal = false
        }
    }
    
    // ---------------------------------------------------------------------------------------------------------
    
    // MARK: Theming
    
    func fontChanged(to newFont: PlatformFont, forProperty property: KeyPath<FontScheme, PlatformFont>) {
        tableView.reloadDataMaintainingSelection()
    }
    
    func colorSchemeChanged() {
        
        tableView.setBackgroundColor(systemColorScheme.backgroundColor)
        tableView.reloadDataMaintainingSelection()
    }
    
    func colorChanged(to newColor: PlatformColor, forProperty property: KeyPath<ColorScheme, PlatformColor>) {
        
        switch property {
            
        case \.backgroundColor:
            
            tableView.setBackgroundColor(systemColorScheme.backgroundColor)
            
        case \.primaryTextColor:
            
            tableView.reloadDataMaintainingSelection()
            
        case \.textSelectionColor:
            
            tableView.redoRowSelection()
            
        default:
            
            return
        }
    }
}
