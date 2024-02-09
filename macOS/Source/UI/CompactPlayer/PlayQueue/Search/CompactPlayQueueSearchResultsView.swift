//
//  CompactPlayQueueSearchResultsView.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import AppKit

class CompactPlayQueueSearchResultsView: MouseTrackingView {
    
    @IBOutlet weak var searchTable: NSTableView!
    
    override func viewDidMoveToWindow() {
        
        super.viewDidMoveToWindow()
        startTracking()
    }
    
    override func mouseMoved(with event: NSEvent) {
        
        super.mouseMoved(with: event)
        
        // Moved from previous row to a different one, hide the previously shown button.
        for rowShowingButton in searchTable.allRowIndices {
            
            if let cell = cellForRow(rowShowingButton) {
                
                cell.btnPlay.hide()
                cell.textField?.show()
            }
        }
        
        let row = searchTable.row(at: searchTable.convert(event.locationInWindow, from: nil))
        
        if let cell = cellForRow(row) {
            
            print("Showing for row: \(row)")
            
            cell.btnPlay.show()
            cell.textField?.hide()
        }
    }
    
    private func cellForRow(_ row: Int) -> CompactPlayQueueSearchResultIndexCell? {
        
        guard row >= 0,
              let cell = searchTable.view(atColumn: 0, row: row, makeIfNecessary: false) as? CompactPlayQueueSearchResultIndexCell else {
            
            return nil
        }
        
        return cell
    }
}
