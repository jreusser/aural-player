//
//  CompactPlayQueueSearchViewController.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import AppKit

class CompactPlayQueueSearchViewController: NSViewController {
    
    override var nibName: NSNib.Name? {"CompactPlayQueueSearch"}
    
    @IBOutlet weak var searchField: NSSearchField!
    @IBOutlet weak var resultsTable: NSTableView!
    @IBOutlet weak var lblSummary: NSTextField!
    
    private var searchQuery: SearchQuery = SearchQuery()
    
    // Current search results
    private(set) var searchResults: SearchResults!
    
    private lazy var messenger = Messenger(for: self)
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        fontSchemesManager.registerObserver(self)
        colorSchemesManager.registerSchemeObserver(self)
    }

    override func viewDidAppear() {
        
        super.viewDidAppear()
        
        searchField.focusRingType = .none
        
        searchField.stringValue = ""
        searchQuery.text = ""
        noResultsFound()
        view.window?.makeFirstResponder(searchField)
    }
    
    // Called when any of the search criteria have changed, performs a new search
    private func updateSearch() {
        
        searchResults = playQueueDelegate.search(searchQuery)
        
        guard searchResults.hasResults else {
            
            lblSummary.stringValue = "No results found"
            print("No Results for Query: '\(searchQuery.text)'")
            return
        }
        
        print("Results for Query: '\(searchQuery.text)' ...")
        lblSummary.stringValue = "\(searchResults.count) \(searchResults.count == 1 ? "result" : "results") found"
        
        for (index, res) in searchResults.results.enumerated() {
            print("\t\(index + 1): '\(res.location.track.displayName)' at: \((res.location as! PlayQueueSearchResultLocation).index)")
        }
    }
    
    private func noResultsFound() {
        lblSummary.stringValue = "No results found"
    }
    
    // If no fields to compare or no search text, don't do the search
    private func redoSearchIfPossible() {
        
        searchQuery.queryPossible ? updateSearch() : noResultsFound()
        resultsTable.reloadData()
    }
    
    @IBAction func searchTextChangeAction(_ sender: Any) {
        
        searchQuery.text = searchField.stringValue
        searchField.recentSearches.append(searchField.stringValue)
        redoSearchIfPossible()
    }
    
    @IBAction func playResultAction(_ sender: NSTableView) {
        
        let selRows = resultsTable.selectedRowIndexes
        
        if selRows.count == 1, let resultIndex = selRows.first,
            let result = searchResults?.results[resultIndex],
           let pqLocation = result.location as? PlayQueueSearchResultLocation {
            
            messenger.publish(TrackPlaybackCommandNotification(index: pqLocation.index))
        }
    }
    
    @IBAction func searchDoneAction(_ sender: Any) {
        view.window?.close()
    }
}

extension CompactPlayQueueSearchViewController: FontSchemeObserver {
    
    func fontSchemeChanged() {
        
        searchField.font = systemFontScheme.smallFont
        lblSummary.font = systemFontScheme.smallFont
        resultsTable.reloadData()
    }
}

extension CompactPlayQueueSearchViewController: ColorSchemeObserver {
    
    func colorSchemeChanged() {
        
        searchField.textColor = systemColorScheme.primaryTextColor
        lblSummary.textColor = systemColorScheme.secondaryTextColor
        
        resultsTable.setBackgroundColor(systemColorScheme.backgroundColor)
        resultsTable.reloadData()
    }
}
