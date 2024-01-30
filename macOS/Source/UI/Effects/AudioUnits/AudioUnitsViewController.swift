//
//  AudioUnitsViewController.swift
//  Aural
//
//  Copyright © 2023 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa
import AVFoundation

/*
    View controller for the Audio Units view.
 */
class AudioUnitsViewController: NSViewController, ColorSchemePropertyObserver, FontSchemePropertyObserver {
    
    override var nibName: String? {"AudioUnits"}
    
    // ------------------------------------------------------------------------
    
    // MARK: UI fields
    
//    @IBOutlet weak var lblCaption: NSTextField!
    
    @IBOutlet weak var tableView: NSTableView!
    @IBOutlet weak var tableScrollView: NSScrollView!
    @IBOutlet weak var tableClipView: NSClipView!

    // Audio Unit ID -> Dialog
    private var editorDialogs: [String: AudioUnitEditorDialogController] = [:]
    
    @IBOutlet weak var btnAudioUnitsMenu: NSPopUpButton!
    @IBOutlet weak var addAudioUnitMenuIconItem: TintedIconMenuItem!
    @IBOutlet weak var btnRemove: TintedImageButton!
    
    // ------------------------------------------------------------------------
    
    // MARK: Services, utilities, helpers, and properties
    
    let audioGraph: AudioGraphDelegateProtocol = audioGraphDelegate
    
    private(set) lazy var messenger = Messenger(for: self)
    
    // ------------------------------------------------------------------------
    
    // MARK: UI initialization / life-cycle
    
    override func viewDidLoad() {
        
        fontSchemesManager.registerObserver(self, forProperty: \.effectsPrimaryFont)

        colorSchemesManager.registerSchemeObserver(self)
        colorSchemesManager.registerPropertyObserver(self, forProperty: \.backgroundColor, handler: backgroundColorChanged(_:))
        colorSchemesManager.registerPropertyObserver(self, forProperty: \.primaryTextColor, handler: primaryTextColorChanged(_:))
        colorSchemesManager.registerPropertyObserver(self, forProperty: \.primarySelectedTextColor, handler: primarySelectedTextColorChanged(_:))
        colorSchemesManager.registerPropertyObserver(self, forProperty: \.textSelectionColor, handler: textSelectionColorChanged(_:))
        
        colorSchemesManager.registerPropertyObserver(self, forProperty: \.buttonColor, changeReceivers: [btnRemove, addAudioUnitMenuIconItem])
        colorSchemesManager.registerPropertyObserver(self, forProperty: \.buttonColor, handler: buttonColorChanged(_:))
        
        colorSchemesManager.registerPropertyObserver(self, forProperty: \.activeControlColor, handler: activeControlColorChanged(_:))
        colorSchemesManager.registerPropertyObserver(self, forProperty: \.inactiveControlColor, handler: inactiveControlColorChanged(_:))
        colorSchemesManager.registerPropertyObserver(self, forProperty: \.suppressedControlColor, handler: suppressedControlColorChanged(_:))
    }
    
    override func destroy() {
        messenger.unsubscribeFromAll()
    }
    
    // ------------------------------------------------------------------------
    
    // MARK: Actions

    @IBAction func addAudioUnitAction(_ sender: Any) {
        
        if let audioUnitComponent = btnAudioUnitsMenu.selectedItem?.representedObject as? AVAudioUnitComponent,
           let result = audioGraph.addAudioUnit(ofType: audioUnitComponent.audioComponentDescription.componentType,
                                                andSubType: audioUnitComponent.audioComponentDescription.componentSubType) {
            
            let audioUnit = result.0
            
            // Refresh the table view with the new row.
            tableView.noteNumberOfRowsChanged()
            
            // Create an editor dialog for the new audio unit.
            editorDialogs[audioUnit.id] = AudioUnitEditorDialogController(for: audioUnit)
            
            // Open the audio unit editor window with the new audio unit's custom view.
            DispatchQueue.main.async {

                self.doEditAudioUnit(audioUnit)
                self.messenger.publish(.auEffectsUnit_audioUnitsAddedOrRemoved)
                self.messenger.publish(.effects_unitStateChanged)
            }
        }
    }
    
    @IBAction func editAudioUnitAction(_ sender: Any) {
        
        let selectedRow = tableView.selectedRow
        
        if selectedRow >= 0 {

            // Open the audio unit editor window with the new audio unit's custom view.
            doEditAudioUnit(audioGraph.audioUnits[selectedRow])
        }
    }
    
    func doEditAudioUnit(_ audioUnit: HostedAudioUnitDelegateProtocol) {
        
        if editorDialogs[audioUnit.id] == nil {
            editorDialogs[audioUnit.id] = AudioUnitEditorDialogController(for: audioUnit)
        }
        
        if let dialog = editorDialogs[audioUnit.id], let dialogWindow = dialog.window {
            
            windowLayoutsManager.addChildWindow(dialogWindow)
            dialog.showWindow(self)
        }
    }
    
    @IBAction func removeAudioUnitsAction(_ sender: Any) {
        
        let selRows = tableView.selectedRowIndexes
        
        if !selRows.isEmpty {
            
            for unit in audioGraph.removeAudioUnits(at: selRows) {
                
                editorDialogs[unit.id]?.close()
                editorDialogs.removeValue(forKey: unit.id)
            }
            
            tableView.reloadData()
            messenger.publish(.auEffectsUnit_audioUnitsAddedOrRemoved)
            messenger.publish(.effects_unitStateChanged)
        }
    }
    
    // MARK: Theming
    
    func fontChanged(to newFont: PlatformFont, forProperty property: KeyPath<FontScheme, PlatformFont>) {
        tableView.reloadAllRows(columns: [1])
    }
    
    func applyFontScheme(_ fontScheme: FontScheme) {
        tableView.reloadAllRows(columns: [1])
    }
}

extension AudioUnitsViewController: ColorSchemeObserver {
    
    func colorSchemeChanged() {
        
        backgroundColorChanged(systemColorScheme.backgroundColor)
        btnRemove.contentTintColor = systemColorScheme.buttonColor
        addAudioUnitMenuIconItem.colorChanged(systemColorScheme.buttonColor)
        tableView.reloadDataMaintainingSelection()
    }
    
    private func backgroundColorChanged(_ newColor: NSColor) {
        tableView.setBackgroundColor(newColor)
    }
    
    func primaryTextColorChanged(_ newColor: NSColor) {
        tableView.reloadAllRows(columns: [1])
    }
    
    func primarySelectedTextColorChanged(_ newColor: NSColor) {
        tableView.reloadRows(tableView.selectedRowIndexes, columns: [1])
    }
    
    func activeControlColorChanged(_ newColor: NSColor) {
        
        let rowsForActiveUnits: [Int] = tableView.allRowIndices.filter {audioGraph.audioUnits[$0].state == .active}
        tableView.reloadRows(rowsForActiveUnits, columns: [0])
    }
    
    func inactiveControlColorChanged(_ newColor: NSColor) {
        
        let rowsForBypassedUnits: [Int] = tableView.allRowIndices.filter {audioGraph.audioUnits[$0].state == .bypassed}
        tableView.reloadRows(rowsForBypassedUnits, columns: [0])
    }
    
    func suppressedControlColorChanged(_ newColor: NSColor) {
        
        let rowsForSuppressedUnits: [Int] = tableView.allRowIndices.filter {audioGraph.audioUnits[$0].state == .suppressed}
        tableView.reloadRows(rowsForSuppressedUnits, columns: [0])
    }
    
    func buttonColorChanged(_ newColor: NSColor) {
        tableView.reloadAllRows(columns: [2])
    }
    
    private func textSelectionColorChanged(_ newColor: NSColor) {
        tableView.redoRowSelection()
    }
}

// ------------------------------------------------------------------------

// MARK: NSMenuDelegate

extension AudioUnitsViewController: NSMenuDelegate {
    
    func menuNeedsUpdate(_ menu: NSMenu) {
        
        // Remove all dynamic items (all items after the first icon item).
        while menu.items.count > 1 {
            menu.removeItem(at: 1)
        }
        
        for unit in audioUnitsManager.audioUnits {

            let itemTitle = "\(unit.name) v\(unit.versionString) by \(unit.manufacturerName)"
            let item = NSMenuItem(title: itemTitle)
            item.target = self
            item.representedObject = unit
            
            menu.addItem(item)
        }
    }
}
