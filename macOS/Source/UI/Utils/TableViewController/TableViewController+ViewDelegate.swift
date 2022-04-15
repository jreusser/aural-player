//
//  TableViewController+ViewDelegate.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import Cocoa

extension TrackListViewController {
    
//    func buildCell<T: NSTableCellView>(forColumn column: NSUserInterfaceItemIdentifier, ofType type: T.Type = AuralTableCellView.self as! T.Type,
//                                       withText text: String, inFont font: PlatformFont, andColor color: PlatformColor) -> T? {
//
//        doBuildCell(forColumn: column, ofType: type, text: text, font: font, textColor: color)
//    }
//
//    func buildCell<T: NSTableCellView>(forColumn column: NSUserInterfaceItemIdentifier, ofType type: T.Type = AuralTableCellView.self as! T.Type,
//                                       withImage image: PlatformImage, inColor color: PlatformColor) -> T? {
//
//        doBuildCell(forColumn: column, ofType: type, image: image, imageColor: color)
//    }
//
//    func buildCell<T: NSTableCellView>(forColumn column: NSUserInterfaceItemIdentifier, ofType type: T.Type = AuralTableCellView.self as! T.Type,
//                                       withText text: String, inFont font: PlatformFont, inColor textColor: PlatformColor,
//                                       andImage image: PlatformImage, inColor imageColor: PlatformColor) -> T? {
//
//        doBuildCell(forColumn: column, ofType: type, text: text, font: font, textColor: textColor, image: image, imageColor: imageColor)
//    }
//
//    private func doBuildCell<T: NSTableCellView>(forColumn column: NSUserInterfaceItemIdentifier, ofType type: T.Type,
//                                                 text: String? = nil, font: PlatformFont? = nil, textColor: PlatformColor? = nil,
//                                                 image: PlatformImage? = nil, imageColor: PlatformColor? = nil) -> T? {
//
//        guard let cell = tableView.makeView(withIdentifier: column, owner: nil) as? T else {return nil}
//
//        if let text = text {
//
//            cell.text = text
//            cell.textFont = font
//            cell.textColor = textColor
//        }
//
//        cell.textField?.showIf(text != nil)
//
//        if let image = image {
//
//            cell.image = image
//            cell.imageColor = imageColor
//        }
//
//        cell.imageView?.showIf(image != nil)
//
//        return cell
//    }
}
