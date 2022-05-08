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
    private var font: PlatformFont? = nil
    private var textColor: PlatformColor? = nil
    private var selectedTextColor: PlatformColor? = nil
    
    private var attributedText: NSAttributedString? = nil
    private var selectedAttributedText: NSAttributedString? = nil

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
    
    func withText(text: String, inFont font: PlatformFont, andColor color: PlatformColor, selectedTextColor: PlatformColor) -> TableCellBuilder {
        
        self.text = text
        self.font = font
        self.textColor = color
        self.selectedTextColor = selectedTextColor
        
        return self
    }
    
    func withAttributedText(strings: [(text: String, font: PlatformFont, color: PlatformColor)], selectedTextColors: [PlatformColor]) -> TableCellBuilder {
        
        var attStr: NSMutableAttributedString = strings[0].text.attributed(font: strings[0].font, color: strings[0].color)
        var selAttStr: NSMutableAttributedString = strings[0].text.attributed(font: strings[0].font, color: selectedTextColors[0])
        
        if strings.count > 1 {
            
            for index in 1..<strings.count {
                
                attStr = attStr + strings[index].text.attributed(font: strings[index].font, color: strings[index].color)
                selAttStr = selAttStr + strings[index].text.attributed(font: strings[index].font, color: selectedTextColors[index])
            }
        }
        
//        let style: NSMutableParagraphStyle = NSMutableParagraphStyle()
//        style.lineBreakMode = .byTruncatingTail
//
//        attStr.addAttribute(.paragraphStyle, value: style, range: NSMakeRange(0, attStr.length))
//        selAttStr.addAttribute(.paragraphStyle, value: style, range: NSMakeRange(0, selAttStr.length))
        
        self.attributedText = attStr
        self.selectedAttributedText = selAttStr
        
        return self
    }
    
    func withImage(image: PlatformImage, inColor color: PlatformColor) -> TableCellBuilder {
        
        self.image = image
        self.imageColor = color
        
        return self
    }
    
    func buildCell(forTableView tableView: NSTableView, forColumnWithId columnId: NSUserInterfaceItemIdentifier, inRow row: Int) -> AuralTableCellView? {

        guard let cell = cellFactory(tableView, columnId) else {return nil}
        
        if let attributedText = self.attributedText, let selectedAttributedText = self.selectedAttributedText {
            
            cell.attributedText = attributedText
            
//            cell.textField?.maximumNumberOfLines = 1
            
            cell.unselectedAttributedText = attributedText
            cell.selectedAttributedText = selectedAttributedText
            
        } else if let text = self.text, let selectedTextColor = self.selectedTextColor {
            
            cell.text = text
            cell.textFont = self.font
            cell.textColor = self.textColor
            
            cell.unselectedTextColor = self.textColor
            cell.selectedTextColor = selectedTextColor
        }
        
        cell.textField?.showIf(attributedText != nil || text != nil)
        
        if let image = self.image, let imageColor = self.imageColor {
            
            cell.image = image
            cell.imageColor = imageColor
        }
        
        cell.imageView?.showIf(image != nil)
        
        cell.rowSelectionStateFunction = {[weak tableView] in
            tableView?.selectedRowIndexes.contains(row) ?? false
        }
        
        return cell
    }
}
