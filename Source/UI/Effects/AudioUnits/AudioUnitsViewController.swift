import Cocoa
import AVFoundation

/*
    View controller for the Audio Units view.
 */
class AudioUnitsViewController: NSViewController, NSMenuDelegate, NotificationSubscriber {
    
    @IBOutlet weak var lblCaption: NSTextField!
    
    @IBOutlet weak var tableView: NSTableView!
    @IBOutlet weak var tableScrollView: NSScrollView!
    @IBOutlet weak var tableClipView: NSClipView!
    
    private var editorDialogs: [OSType: AudioUnitEditorDialogController] = [:]
    
    override var nibName: String? {return "AudioUnits"}
    
    private let audioGraph: AudioGraphDelegateProtocol = ObjectGraph.audioGraphDelegate
    
    private let audioUnitsManager: AudioUnitsManager = ObjectGraph.audioUnitsManager
    
    @IBOutlet weak var btnAudioUnitsMenu: NSPopUpButton!
    @IBOutlet weak var audioUnitsMenuIconItem: TintedIconMenuItem!
    @IBOutlet weak var btnRemove: TintedImageButton!
    
    override func viewDidLoad() {
        
        audioUnitsMenuIconItem.tintFunction = {return Colors.functionButtonColor}
        btnRemove.tintFunction = {return Colors.functionButtonColor}
        
        applyFontScheme(FontSchemes.systemScheme)
        applyColorScheme(ColorSchemes.systemScheme)
        
        // Subscribe to notifications
        Messenger.subscribe(self, .fx_unitStateChanged, self.stateChanged)
        Messenger.subscribe(self, .auFXUnit_showEditor, {(notif: ShowAudioUnitEditorCommandNotification) in self.doEditAudioUnit(notif.audioUnit)})
        
        Messenger.subscribe(self, .applyFontScheme, self.applyFontScheme(_:))
        Messenger.subscribe(self, .applyColorScheme, self.applyColorScheme(_:))
        
        Messenger.subscribe(self, .changeBackgroundColor, self.changeBackgroundColor(_:))
        
        Messenger.subscribe(self, .changeMainCaptionTextColor, self.changeMainCaptionTextColor(_:))
        Messenger.subscribe(self, .changeFunctionButtonColor, self.changeFunctionButtonColor(_:))
        Messenger.subscribe(self, .fx_changeFunctionCaptionTextColor, self.changeFunctionCaptionTextColor(_:))
        
        Messenger.subscribe(self, .fx_changeActiveUnitStateColor, self.changeActiveUnitStateColor(_:))
        Messenger.subscribe(self, .fx_changeBypassedUnitStateColor, self.changeBypassedUnitStateColor(_:))
        Messenger.subscribe(self, .fx_changeSuppressedUnitStateColor, self.changeSuppressedUnitStateColor(_:))
        
        Messenger.subscribe(self, .playlist_changeSelectionBoxColor, self.changeSelectionBoxColor(_:))
    }

    @IBAction func addAudioUnitAction(_ sender: Any) {
        
        if let audioUnitComponent = btnAudioUnitsMenu.selectedItem?.representedObject as? AVAudioUnitComponent,
           let result = audioGraph.addAudioUnit(ofType: audioUnitComponent.audioComponentDescription.componentSubType) {
            
            let audioUnit = result.0
            
            // Refresh the table view with the new row.
            tableView.noteNumberOfRowsChanged()
            
            let editorDialog = AudioUnitEditorDialogController(for: audioUnit)
            editorDialogs[audioUnit.componentSubType] = editorDialog
            
            // Open the audio unit editor window with the new audio unit's custom view.
            DispatchQueue.main.async {

                editorDialog.showDialog()
                Messenger.publish(.fx_unitStateChanged)
            }
        }
    }
    
    @IBAction func editAudioUnitAction(_ sender: Any) {
        
        let selectedRow = tableView.selectedRow
        
        if selectedRow >= 0 {

            // Open the audio unit editor window with the new audio unit's custom view.
            let audioUnit = audioGraph.audioUnits[selectedRow]
            doEditAudioUnit(audioUnit)
        }
    }
    
    private func doEditAudioUnit(_ audioUnit: HostedAudioUnitDelegateProtocol) {
        
        if editorDialogs[audioUnit.componentSubType] == nil {
            editorDialogs[audioUnit.componentSubType] = AudioUnitEditorDialogController(for: audioUnit)
        }
        
        editorDialogs[audioUnit.componentSubType]?.showDialog()
    }
    
    @IBAction func removeAudioUnitsAction(_ sender: Any) {
        
        let selRows = tableView.selectedRowIndexes
        
        if !selRows.isEmpty {
            
            let removedUnits = audioGraph.removeAudioUnits(at: selRows)
            for unit in removedUnits {
                editorDialogs.removeValue(forKey: unit.componentSubType)
            }
            
            tableView.reloadData()
            Messenger.publish(.fx_unitStateChanged)
        }
    }
    
    func applyFontScheme(_ fontScheme: FontScheme) {
        
        lblCaption.font = FontSchemes.systemScheme.effects.unitCaptionFont
        tableView.reloadData(forRowIndexes: IndexSet((0..<tableView.numberOfRows)), columnIndexes: [1])
    }
    
    func applyColorScheme(_ scheme: ColorScheme) {
        
        changeBackgroundColor(scheme.general.backgroundColor)
        changeMainCaptionTextColor(scheme.general.mainCaptionTextColor)
        
        audioUnitsMenuIconItem.reTint()
        btnRemove.reTint()
        
        let selectedRows = tableView.selectedRowIndexes
        tableView.reloadData()
        
        if !selectedRows.isEmpty {
            
            tableView.selectRowIndexes(IndexSet(), byExtendingSelection: false)
            tableView.selectRowIndexes(selectedRows, byExtendingSelection: false)
        }
    }
    
    private func changeBackgroundColor(_ color: NSColor) {
        
        tableScrollView.backgroundColor = color
        tableClipView.backgroundColor = color
        tableView.backgroundColor = color
    }
    
    func changeMainCaptionTextColor(_ color: NSColor) {
        lblCaption.textColor = color
    }
    
    func changeFunctionCaptionTextColor(_ color: NSColor) {
        tableView.reloadData(forRowIndexes: IndexSet((0..<tableView.numberOfRows)), columnIndexes: [1])
    }
    
    func changeActiveUnitStateColor(_ color: NSColor) {
        
        let rowsForActiveUnits: [Int] = (0..<tableView.numberOfRows).filter {audioGraph.audioUnits[$0].state == .active}
        tableView.reloadData(forRowIndexes: IndexSet(rowsForActiveUnits), columnIndexes: [0])
    }
    
    func changeBypassedUnitStateColor(_ color: NSColor) {
        
        let rowsForBypassedUnits: [Int] = (0..<tableView.numberOfRows).filter {audioGraph.audioUnits[$0].state == .bypassed}
        tableView.reloadData(forRowIndexes: IndexSet(rowsForBypassedUnits), columnIndexes: [0])
    }
    
    func changeSuppressedUnitStateColor(_ color: NSColor) {
        
        let rowsForSuppressedUnits: [Int] = (0..<tableView.numberOfRows).filter {audioGraph.audioUnits[$0].state == .bypassed}
        tableView.reloadData(forRowIndexes: IndexSet(rowsForSuppressedUnits), columnIndexes: [0])
    }
    
    func stateChanged() {
        tableView.reloadData(forRowIndexes: IndexSet((0..<tableView.numberOfRows)), columnIndexes: [0])
    }
    
    func changeFunctionButtonColor(_ color: NSColor) {
        
        audioUnitsMenuIconItem.reTint()
        btnRemove.reTint()
        
        tableView.reloadData(forRowIndexes: IndexSet((0..<tableView.numberOfRows)), columnIndexes: [2])
    }
    
    private func changeSelectionBoxColor(_ color: NSColor) {
        
        // Note down the selected rows, clear the selection, and re-select the originally selected rows (to trigger a repaint of the selection boxes)
        let selectedRows = tableView.selectedRowIndexes
        
        if !selectedRows.isEmpty {
            
            tableView.selectRowIndexes(IndexSet(), byExtendingSelection: false)
            tableView.selectRowIndexes(selectedRows, byExtendingSelection: false)
        }
    }
    
    // MARK: Menu Delegate functions
    
    func menuNeedsUpdate(_ menu: NSMenu) {
        
        // Remove all custom presets (all items before the first separator)
        while menu.items.count > 1 {
            menu.removeItem(at: 1)
        }
        
        for unit in audioUnitsManager.audioUnits {

            let item = NSMenuItem(title: unit.name, action: nil, keyEquivalent: "")
            item.target = self
            item.representedObject = unit
            
            menu.addItem(item)
        }
    }
}
