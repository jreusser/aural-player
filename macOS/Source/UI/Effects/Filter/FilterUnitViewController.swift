//
//  FilterUnitViewController.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

/*
    View controller for the Filter effects unit
 */
class FilterUnitViewController: EffectsUnitViewController {
    
    override var nibName: String? {"FilterUnit"}
    
    // ------------------------------------------------------------------------
    
    // MARK: UI fields
    
    @IBOutlet weak var filterUnitView: FilterUnitView!
    @IBOutlet weak var bandsTableView: NSTableView!
    @IBOutlet weak var lblSummary: NSTextField!
    
    private var bandControllers: [FilterBandViewController] = []
    
    var bandEditors: [LazyWindowLoader<FilterBandEditorDialogController>] = []
    
    // ------------------------------------------------------------------------
    
    // MARK: Services, utilities, helpers, and properties
    
    var filterUnit: FilterUnitDelegateProtocol = audioGraphDelegate.filterUnit
    
    // ------------------------------------------------------------------------
    
    // MARK: UI initialization / life-cycle
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        
        effectsUnit = filterUnit
        presetsWrapper = PresetsWrapper<FilterPreset, FilterPresets>(filterUnit.presets)
    }
    
    override func oneTimeSetup() {
        
        super.oneTimeSetup()

        let bandsDataFunction = {[weak self] in self?.filterUnit.bands ?? []}
        filterUnitView.initialize(stateFunction: unitStateFunction, bandsDataFunction: bandsDataFunction)
        updateSummary()
    }
 
    override func initControls() {

        super.initControls()
        
        for bandIndex in filterUnit.bands.indices {
            
            let editor = LazyWindowLoader<FilterBandEditorDialogController>()
            
            editor.controllerInitFunction = {controller in
                controller.bandIndex = bandIndex
            }
            
            bandEditors.append(editor)
        }
    }
    
    private func updateSummary() {
        
        let numberOfBands = filterUnit.numberOfBands
        
        guard numberOfBands > 0 else {
            
            lblSummary.stringValue = "0 bands"
            return
        }
        
        let numberOfActiveBands = filterUnit.numberOfActiveBands
        let bandsCardinalString = numberOfBands == 1 ? "band" : "bands"
        
        lblSummary.stringValue = "\(numberOfBands) \(bandsCardinalString)  (\(numberOfActiveBands) active)"
    }
    
    // ------------------------------------------------------------------------
    
    // MARK: Actions
    
    @IBAction func addBandStopBandAction(_ sender: AnyObject) {
        doAddBand(ofType: .bandStop)
    }
    
    @IBAction func addBandPassBandAction(_ sender: AnyObject) {
        doAddBand(ofType: .bandPass)
    }
    
    @IBAction func addLowPassBandAction(_ sender: AnyObject) {
        doAddBand(ofType: .lowPass)
    }
    
    @IBAction func addHighPassBandAction(_ sender: AnyObject) {
        doAddBand(ofType: .highPass)
    }
    
    private func doAddBand(ofType bandType: FilterBandType) {
        
        // TODO: Check if 31 bands already, and display error alert.
        
        let newBandInfo: (band: FilterBand, index: Int) = filterUnit.addBand(ofType: bandType)
        bandsTableView.noteNumberOfRowsChanged()
        updateSummary()
        filterUnitView.redrawChart()
        
        let bandEditor = LazyWindowLoader<FilterBandEditorDialogController>()
        bandEditor.controller.bandIndex = newBandInfo.index
        bandEditors.append(bandEditor)
        
        bandEditor.showWindow()
    }
    
    @IBAction func removeBandsAction(_ sender: AnyObject) {
        
        let selRows = bandsTableView.selectedRowIndexes
        guard selRows.isNonEmpty else {return}
        
        for index in selRows.sortedDescending() {
            bandEditors[index].destroy()
        }
        
        bandEditors.removeItems(at: selRows)
        
        filterUnit.removeBands(atIndices: selRows)
        bandsTableView.reloadData()
        updateSummary()
        filterUnitView.redrawChart()
        
        for (index, editor) in bandEditors.enumerated() {
            
            if editor.isWindowLoaded {
                editor.controller.bandIndex = index
                
            } else {
                
                editor.controllerInitFunction = {controller in
                    controller.bandIndex = index
                }
            }
        }
    }
    
    // ------------------------------------------------------------------------
    
    // MARK: Message handling
    
    override func initSubscriptions() {
        
        super.initSubscriptions()
        
        messenger.subscribe(to: .filterUnit_bandUpdated, handler: bandUpdated(_:))
        
        fontSchemesManager.registerObserver(lblSummary, forProperty: \.effectsPrimaryFont)
        colorSchemesManager.registerObserver(lblSummary, forProperty: \.secondaryTextColor)
        
        messenger.subscribe(to: .filterUnit_bandBypassStateUpdated, handler: updateSummary)
        
//        messenger.subscribe(to: .changeBackgroundColor, handler: filterUnitView.changeBackgroundColor(_:))
//        messenger.subscribe(to: .changeTextButtonMenuColor, handler: filterUnitView.changeTextButtonMenuColor(_:))
//        messenger.subscribe(to: .changeSelectedTabButtonColor, handler: filterUnitView.changeSelectedTabButtonColor(_:))
//        messenger.subscribe(to: .changeTabButtonTextColor, handler: filterUnitView.changeTabButtonTextColor(_:))
//        messenger.subscribe(to: .changeButtonMenuTextColor, handler: filterUnitView.changeButtonMenuTextColor(_:))
//        messenger.subscribe(to: .changeSelectedTabButtonTextColor, handler: filterUnitView.changeSelectedTabButtonTextColor(_:))
    }
    
    override func stateChanged() {
        
        super.stateChanged()
        filterUnitView.stateChanged()
    }
    
    private func bandUpdated(_ band: Int) {
        bandsTableView.reloadRows([band], columns: [2, 3])
    }
    
    // ------------------------------------------------------------------------
    
    // MARK: Theming
    
//    override func applyFontScheme(_ fontScheme: FontScheme) {
//
//        super.applyFontScheme(fontScheme)
//        filterUnitView.applyFontScheme(fontScheme)
//    }
//    
////    override func applyColorScheme(_ scheme: ColorScheme) {
////
////        // Need to do this to avoid multiple redundant redraw() calls
////
////        super.changeFunctionButtonColor(scheme.buttonColor)
//////        super.changeFunctionCaptionTextColor(scheme.secondaryTextColor)
//////        super.changeFunctionValueTextColor(scheme.primaryTextColor)
////
////        super.changeActiveUnitStateColor(scheme.activeControlColor)
////        super.changeBypassedUnitStateColor(scheme.inactiveControlColor)
////        super.changeSuppressedUnitStateColor(scheme.suppressedControlColor)
////
////        filterUnitView.applyColorScheme(scheme)
////    }
//    
//    override func changeSliderColors() {
//        filterUnitView.changeSliderColors()
//    }
    
//    override func changeActiveUnitStateColor(_ color: NSColor) {
//
//        super.changeActiveUnitStateColor(color)
//        filterUnitView.changeActiveUnitStateColor(color)
//    }
//
//    override func changeBypassedUnitStateColor(_ color: NSColor) {
//
//        super.changeBypassedUnitStateColor(color)
//        filterUnitView.changeBypassedUnitStateColor(color)
//    }
//
//    override func changeSuppressedUnitStateColor(_ color: NSColor) {
//
//        super.changeSuppressedUnitStateColor(color)
//        filterUnitView.changeSuppressedUnitStateColor(color)
//    }
    
//    override func changeFunctionCaptionTextColor(_ color: NSColor) {
//
//        super.changeFunctionCaptionTextColor(color)
//        filterUnitView.changeFunctionCaptionTextColor(color)
//    }
//
//    override func changeFunctionValueTextColor(_ color: NSColor) {
//
//        super.changeFunctionValueTextColor(color)
//        filterUnitView.changeFunctionValueTextColor(color)
//    }
    
//    override func changeFunctionButtonColor(_ color: NSColor) {
//        
//        super.changeFunctionButtonColor(color)
//        filterUnitView.changeFunctionButtonColor(color)
//    }
}
