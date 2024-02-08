//
//  ThemePopupMenuController.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

/*
    Controller for the popup menu that lists the available themes and opens the theme editor panel.
 */
class ThemePopupMenuController: GenericPresetPopupMenuController {
    
    private lazy var creationDialogController: CreateThemeDialogController = CreateThemeDialogController.instance
    private lazy var managerWindowController: PresetsManagerWindowController = PresetsManagerWindowController.instance
    
    override var descriptionOfPreset: String {"theme"}
    override var descriptionOfPreset_plural: String {"themes"}
    
    override var userDefinedPresets: [UserManagedObject] {themesManager.userDefinedObjects}
    override var numberOfUserDefinedPresets: Int {themesManager.numberOfUserDefinedObjects}
    
    private lazy var uiState: WindowAppearanceState = windowAppearanceState
    
    override func presetExists(named name: String) -> Bool {
        themesManager.objectExists(named: name)
    }
    
    // Receives a new theme name and saves the new theme.
    override func addPreset(named name: String) {
        
        // Copy the current system scheme into the new scheme, and name it with the user's given scheme name
        let fontScheme: FontScheme = FontScheme(name: "Font scheme for theme '\(name)'", copying: systemFontScheme)
        let colorScheme: ColorScheme = ColorScheme("Color scheme for theme '\(name)'", false, systemColorScheme)
        let windowAppearance: WindowAppearance = WindowAppearance(cornerRadius: uiState.cornerRadius)
        
        themesManager.addObject(Theme(name: name, fontScheme: fontScheme, colorScheme: colorScheme, windowAppearance: windowAppearance, userDefined: true))
    }
    
    override func applyPreset(named name: String) {
        themesManager.applyTheme(named: name)
    }
    
    @IBAction func createThemeAction(_ sender: NSMenuItem) {
        _ = creationDialogController.showDialog()
    }
    
    @IBAction func manageThemesAction(_ sender: NSMenuItem) {
        managerWindowController.showThemesManager()
    }
    
    deinit {
        CreateThemeDialogController.destroy()
    }
}
