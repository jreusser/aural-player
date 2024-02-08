//
//  FilterUnitViewController.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
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
    @IBOutlet weak var addButtonMenuIcon: TintedIconMenuItem!
    
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
        
        addEditorsForAllBands()
        bandsTableView.reloadData()
        updateSummary()
        filterUnitView.redrawChart()
    }
    
    private func addEditorsForAllBands() {
        
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
        
        guard filterUnit.numberOfBands < filterUnit.maximumNumberOfBands else {
            
            NSAlert.showError(withTitle: "Cannot add Filter band", andText: "The Filter unit already has the maximum of \(filterUnit.maximumNumberOfBands) bands.")
            return
        }
        
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
        
        // TODO: Before removing, remove the bypass switches in the removed rows as FX unit state observers.
        
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
    
    // Applies a preset to the effects unit
    @IBAction override func presetsAction(_ sender: AnyObject) {
        
        for editor in bandEditors {
            editor.destroy()
        }
        
        bandEditors.removeAll()
        
        effectsUnit.applyPreset(named: sender.title)
        bandsTableView.reloadData()
        updateSummary()
        filterUnitView.redrawChart()
        
        addEditorsForAllBands()
    }
    
    // ------------------------------------------------------------------------
    
    // MARK: Message handling
    
    override func initSubscriptions() {
        
        super.initSubscriptions()
        
        messenger.subscribe(to: .filterUnit_bandUpdated, handler: bandUpdated(_:))
        
        //fontSchemesManager.registerObservers([self, lblSummary], forProperty: \.smallFont)
        
        colorSchemesManager.registerPropertyObserver(self, forProperty: \.backgroundColor, handler: backgroundColorChanged(_:))
        colorSchemesManager.registerPropertyObserver(self, forProperty: \.buttonColor, handler: buttonColorChanged(_:))
        colorSchemesManager.registerPropertyObserver(self, forProperty: \.primaryTextColor, handler: primaryTextColorChanged(_:))
        colorSchemesManager.registerPropertyObserver(self, forProperty: \.secondaryTextColor, handler: secondaryTextColorChanged(_:))
        colorSchemesManager.registerPropertyObserver(self, forProperty: \.primarySelectedTextColor, handler: primarySelectedTextColorChanged(_:))
        colorSchemesManager.registerPropertyObserver(self, forProperty: \.secondarySelectedTextColor, handler: secondarySelectedTextColorChanged(_:))
        
//        colorSchemesManager.registerObserver(lblSummary, forProperty: \.secondaryTextColor)
//        colorSchemesManager.registerSchemeObserver(self, forProperties: [\.backgroundColor, \.primaryTextColor, \.secondaryTextColor])
//        colorSchemesManager.registerObserver(addButtonMenuIcon, forProperty: \.buttonColor)
        
        messenger.subscribe(to: .filterUnit_bandBypassStateUpdated, handler: updateSummary)
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
    
    override func fontSchemeChanged() {
        
        super.fontSchemeChanged()
        bandsTableView.reloadAllRows(columns: [0, 2, 3])
    }
    
    override func colorSchemeChanged() {
        
        super.colorSchemeChanged()
        
        buttonColorChanged(systemColorScheme.buttonColor)
        lblSummary.textColor = systemColorScheme.secondaryTextColor
        
        bandsTableView.setBackgroundColor(systemColorScheme.backgroundColor)
        bandsTableView.reloadDataMaintainingSelection()
        
        filterUnitView.redrawChart()
    }
    
    private func backgroundColorChanged(_ newColor: PlatformColor) {
        bandsTableView.setBackgroundColor(newColor)
    }
    
    private func buttonColorChanged(_ newColor: PlatformColor) {
        
        // Edit buttons
        bandsTableView.reloadAllRows(columns: [4])
        addButtonMenuIcon.colorChanged(newColor)
    }
    
    private func primaryTextColorChanged(_ newColor: PlatformColor) {
        bandsTableView.reloadAllRows(columns: [3])
    }
    
    private func secondaryTextColorChanged(_ newColor: PlatformColor) {
        
        bandsTableView.reloadAllRows(columns: [2])
        lblSummary.textColor = newColor
    }
    
    private func primarySelectedTextColorChanged(_ newColor: PlatformColor) {
        bandsTableView.reloadRows(bandsTableView.selectedRowIndexes.toArray())
    }
    
    private func secondarySelectedTextColorChanged(_ newColor: PlatformColor) {
        bandsTableView.reloadRows(bandsTableView.selectedRowIndexes.toArray())
    }
    
    override func activeControlColorChanged(_ newColor: PlatformColor) {
        
        super.activeControlColorChanged(newColor)
        filterUnitView.redrawChart()
    }
    
    override func inactiveControlColorChanged(_ newColor: PlatformColor) {
        
        super.inactiveControlColorChanged(newColor)
        filterUnitView.redrawChart()
    }
    
    override func suppressedControlColorChanged(_ newColor: PlatformColor) {
        
        super.suppressedControlColorChanged(newColor)
        filterUnitView.redrawChart()
    }
    
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
