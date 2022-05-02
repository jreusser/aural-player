//
//  FilterUnitView.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

class FilterUnitView: NSView {
    
    // ------------------------------------------------------------------------
    
    // MARK: UI fields
    
    @IBOutlet weak var chart: FilterChart!
    
    @IBOutlet weak var bandsTable: NSTableView!
    
    @IBOutlet weak var btnAdd: NSButton!
    @IBOutlet weak var btnRemove: NSButton!
    
    // ------------------------------------------------------------------------
    
    // MARK: Services, utilities, helpers, and properties
    
    private static let noTabsShown: ClosedRange<Int> = (-1)...(-1)
    
    var filterUnit: FilterUnitDelegateProtocol = audioGraphDelegate.filterUnit
    
    // ------------------------------------------------------------------------
    
    // MARK: UI initialization / life-cycle
    
    func initialize(stateFunction: @escaping EffectsUnitStateFunction,
                    bandsDataFunction: @escaping () -> [FilterBand]) {
        
        chart.filterUnitStateFunction = stateFunction
        chart.bandsDataFunction = bandsDataFunction
        
        bandsTable.setBackgroundColor(systemColorScheme.backgroundColor)
    }
    
    func setBands(_ bands: [FilterBandView]) {
        updateCRUDButtonStates()
    }
    
    // ------------------------------------------------------------------------
    
    // MARK: View update
    
    func addBand(_ bandView: FilterBandView, selectNewTab: Bool) {
        
        
        redrawChart()
        updateCRUDButtonStates()
    }
    
    func removeSelectedBand() {
        
            
        redrawChart()
        updateCRUDButtonStates()
    }
    
    func stateChanged() {
        redrawChart()
    }
    
    // ------------------------------------------------------------------------
    
    // MARK: Helper functions
    
    private let maxNumBands: Int = 31
    
    private func updateCRUDButtonStates() {
        
//        btnAdd.isEnabled = numTabs < maxNumBands
//        btnRemove.isEnabled = numTabs > 0
        
        [btnAdd, btnRemove].forEach {$0?.redraw()}
    }
    
    func redrawChart() {
        chart.redraw()
    }
    
    // ------------------------------------------------------------------------
    
    // MARK: Theming
    
    func applyFontScheme(_ fontScheme: FontScheme) {
        
        redrawChart()

        // Redraw the add/remove band buttons
        [btnAdd, btnRemove].forEach {$0?.redraw()}
    }
    
    func applyColorScheme(_ scheme: ColorScheme) {
        
        redrawChart()
        [btnAdd, btnRemove].forEach {$0?.redraw()}
    }
    
    func changeBackgroundColor(_ color: NSColor) {
        redrawChart()
    }
    
    func changeSliderColors() {
    }
    
    func changeActiveUnitStateColor(_ color: NSColor) {
        redrawChart()
    }
    
    func changeBypassedUnitStateColor(_ color: NSColor) {
        redrawChart()
    }
    
    func changeSuppressedUnitStateColor(_ color: NSColor) {
        redrawChart()
    }
    
    func changeFunctionCaptionTextColor(_ color: NSColor) {
        redrawChart()
    }
}
