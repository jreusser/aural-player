//
//  LibraryBuildProgressViewController.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import Cocoa

class LibraryBuildProgressViewController: NSViewController {
    
    override var nibName: String? {"LibraryBuildProgress"}
}

class LibraryBuildProgressWindowController: NSWindowController {
    
//    override var nibName: String? {"LibraryBuildProgress"}
    override var windowNibName: NSNib.Name? {"LibraryBuildProgress"}
}
