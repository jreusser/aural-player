//
//  TableCellBuilder.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import Foundation
import AppKit

typealias TableCellCreationFunction = (NSTableView, NSUserInterfaceItemIdentifier) -> AuralTableCellView?

class TableCellBuilder {
    
    static let noCell: TableCellBuilder = .init(cellFactory: {_,_ in nil})
    
    private var text: String? = nil
    private var attributedText: NSAttributedString? = nil
    private var font: PlatformFont? = nil
    private var textColor: PlatformColor? = nil

    private var image: PlatformImage? = nil
    private var imageColor: PlatformColor? = nil
    
    private let cellFactory: TableCellCreationFunction
    
    init() {

        cellFactory = {tableView, columnId in
            tableView.makeView(withIdentifier: columnId, owner: nil) as? AuralTableCellView
        }
    }

    init<T: AuralTableCellView>(ofType type: T.Type) {

        cellFactory = {tableView, columnId in
            tableView.makeView(withIdentifier: columnId, owner: nil) as? T
        }
    }
    
    fileprivate init(cellFactory: @escaping TableCellCreationFunction) {
        self.cellFactory = cellFactory
    }
    
    func withText(text: String, inFont font: PlatformFont, andColor color: PlatformColor) -> TableCellBuilder {
        
        self.text = text
        self.font = font
        self.textColor = color
        
        return self
    }
    
    func withAttributedText(strings: [(text: String, font: PlatformFont, color: PlatformColor)]) -> TableCellBuilder {
        
        var attStr = strings[0].text.attributed(font: strings[0].font, color: strings[0].color)
        
        if strings.count > 1 {
            
            for index in 1..<strings.count {
                attStr = attStr + strings[index].text.attributed(font: strings[index].font, color: strings[index].color)
            }
        }
        
        self.attributedText = attStr
        
        return self
    }
    
    func withImage(image: PlatformImage, inColor color: PlatformColor) -> TableCellBuilder {
        
        self.image = image
        self.imageColor = color
        
        return self
    }
    
    func buildCell(forTableView tableView: NSTableView, forColumnWithId columnId: NSUserInterfaceItemIdentifier) -> AuralTableCellView? {

        guard let cell = cellFactory(tableView, columnId) else {return nil}
        
        if let attributedText = self.attributedText {
            
            cell.attributedText = attributedText
            
        } else if let text = self.text {
            
            cell.text = text
            cell.textFont = self.font
            cell.textColor = self.textColor
        }
        
        cell.textField?.showIf(attributedText != nil || text != nil)
        
        if let image = self.image, let imageColor = self.imageColor {
            
            cell.image = image
            cell.imageColor = imageColor
        }
        
        cell.imageView?.showIf(image != nil)
        
        return cell
    }
}
