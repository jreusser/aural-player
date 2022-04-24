//
//  ButtonsColorSchemeViewController.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

/*
    Controller for the view that allows the user to edit general color scheme elements.
 */
class ButtonsColorSchemeViewController: ColorSchemeViewController {
    
    override var nibName: NSNib.Name? {"ButtonsColorScheme"}
    
    @IBOutlet weak var buttonColorPicker: AuralColorPicker!
    @IBOutlet weak var buttonOffColorPicker: AuralColorPicker!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        // Map control tags to their corresponding undo/redo actions
        
        actionsMap[buttonColorPicker.tag] = changeButtonColor
        actionsMap[buttonOffColorPicker.tag] = changeButtonOffColor
    }
    
    override func resetFields(_ scheme: ColorScheme, _ history: ColorSchemeHistory, _ clipboard: ColorClipboard) {
        
        super.resetFields(scheme, history, clipboard)
        
        // Update the UI to reflect the current system color scheme
        
        buttonColorPicker.color = systemColorScheme.buttonColor
        buttonOffColorPicker.color = systemColorScheme.buttonOffColor
    }
    
    @IBAction func buttonColorAction(_ sender: Any) {
        
        history.noteChange(ColorSchemeChange(tag: buttonColorPicker.tag, undoValue: systemColorScheme.buttonColor,
                                             redoValue: buttonColorPicker.color, changeType: .changeColor))
        changeButtonColor()
    }
    
    private func changeButtonColor() {
        systemColorScheme.buttonColor = buttonColorPicker.color
    }
    
    @IBAction func buttonOffColorAction(_ sender: Any) {
        
        history.noteChange(ColorSchemeChange(tag: buttonOffColorPicker.tag, undoValue: systemColorScheme.buttonOffColor,
                                             redoValue: buttonOffColorPicker.color, changeType: .changeColor))
        changeButtonOffColor()
    }
    
    private func changeButtonOffColor() {
        systemColorScheme.buttonOffColor = buttonOffColorPicker.color
    }
}
