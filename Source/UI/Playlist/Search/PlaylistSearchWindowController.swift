//
//  PlaylistSearchWindowController.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

/*
    Window controller for the playlist search dialog
 */
class PlaylistSearchWindowController: NSWindowController, ModalDialogDelegate, Destroyable {
    
    @IBOutlet weak var searchField: ColoredCursorSearchField!
    
    @IBOutlet weak var lblSummary: NSTextField!
    @IBOutlet weak var lblMatchFieldName: NSTextField!
    @IBOutlet weak var lblMatchFieldValue: NSTextField!
    
    @IBOutlet weak var btnNextSearch: NSButton!
    @IBOutlet weak var btnPreviousSearch: NSButton!
    
    @IBOutlet weak var searchByName: NSButton!
    @IBOutlet weak var searchByArtist: NSButton!
    @IBOutlet weak var searchByTitle: NSButton!
    @IBOutlet weak var searchByAlbum: NSButton!
    
    @IBOutlet weak var comparisonType_contains: NSButton!
    @IBOutlet weak var comparisonType_equals: NSButton!
    @IBOutlet weak var comparisonType_beginsWith: NSButton!
    @IBOutlet weak var comparisonType_endsWith: NSButton!
    
    @IBOutlet weak var searchCaseSensitive: NSButton!
    
    // Delegate that relays search requests to the playlist
    private let playlist: PlaylistDelegateProtocol = objectGraph.playlistDelegate
    
    private var searchQuery: SearchQuery = SearchQuery()
    
    // Current playlist search results
    private var searchResults: SearchResults!
    
    private var modalDialogResponse: ModalDialogResponse = .ok
    
    override var windowNibName: String? {"PlaylistSearch"}
    
    private lazy var messenger = Messenger(for: self)
    
    override func windowDidLoad() {
        
        messenger.subscribe(to: .playlist_searchTextChanged, handler: searchTextChanged(_:))
        WindowManager.instance.registerModalComponent(self)
    }
    
    func destroy() {
        messenger.unsubscribeFromAll()
    }
    
    var isModal: Bool {self.window?.isVisible ?? false}

    func showDialog() -> ModalDialogResponse {
        
        // Don't do anything if no tracks in playlist
        guard playlist.size > 0 else {return .cancel}
        
        // Force loading of the window if it hasn't been loaded yet (only once)
        if !self.isWindowLoaded {_ = theWindow}
        
        searchField.stringValue = ""
        searchQuery.text = ""
        noResultsFound()
        theWindow.makeFirstResponder(searchField)
        
        theWindow.showCenteredOnScreen()
        return modalDialogResponse
    }
    
    // Called when any of the search criteria have changed, performs a new search
    private func updateSearch() {
        
        searchResults = playlist.search(searchQuery, PlaylistViewState.currentView)
        
        // Show the first result
        searchResults.hasResults ? nextSearchAction(self) : noResultsFound()
    }
    
    private func noResultsFound() {
        
        lblSummary.stringValue = "No results"
        lblMatchFieldName.stringValue = ""
        lblMatchFieldValue.stringValue = ""
        
        NSView.hideViews(btnNextSearch, btnPreviousSearch)
    }
    
    // Iterates to the previous search result
    @IBAction func previousSearchAction(_ sender: Any) {
        
        if let result = searchResults.previous() {
            updateSearchPanelWithResult(result)
        }
    }
    
    // Iterates to the next search result
    @IBAction func nextSearchAction(_ sender: Any) {
        
        if let result = searchResults.next() {
            updateSearchPanelWithResult(result)
        }
    }
    
    // Updates displayed search results info with the current search result
    private func updateSearchPanelWithResult(_ searchResult: SearchResult) {
        
        lblSummary.stringValue = String(format: "Selected result:   %d / %d",
                                        searchResults.currentIndex + 1, searchResults.count)
        
        lblMatchFieldName.stringValue = "Matched field:   \(searchResult.match.fieldKey.capitalizingFirstLetter())"
        lblMatchFieldValue.stringValue = "Matched value:   '\(searchResult.match.fieldValue)'"
        
        btnNextSearch.showIf(searchResults.hasNext)
        btnPreviousSearch.showIf(searchResults.hasPrevious)
        
        // Selects a track within the playlist view, to show the user where the track is located within the playlist
        messenger.publish(SelectSearchResultCommandNotification(searchResult: searchResult,
                                                                viewSelector: PlaylistViewState.currentViewSelector))
    }
    
    @IBAction func searchDoneAction(_ sender: Any) {
        
        modalDialogResponse = .ok
        theWindow.close()
    }
    
    // If no fields to compare or no search text, don't do the search
    private func redoSearchIfPossible() {
        searchQuery.queryPossible ? updateSearch() : noResultsFound()
    }
    
    func searchTextChanged(_ searchText: String) {
        
        searchQuery.text = searchText
        redoSearchIfPossible()
    }
    
    @IBAction func searchFieldsChangedAction(_ sender: Any) {
        
        var searchFields: SearchFields = .none
        
        searchFields.include(.name, if: searchByName.isOn)
        searchFields.include(.artist, if: searchByArtist.isOn)
        searchFields.include(.title, if: searchByTitle.isOn)
        searchFields.include(.album, if: searchByAlbum.isOn)
        
        searchQuery.fields = searchFields

        redoSearchIfPossible()
    }
    
    @IBAction func searchTypeChangedAction(_ sender: Any) {
        
        if comparisonType_equals.isOn {
            searchQuery.type = .equals
            
        } else if comparisonType_contains.isOn {
            searchQuery.type = .contains
            
        } else if comparisonType_beginsWith.isOn {
            searchQuery.type = .beginsWith
            
        } else {
            // Ends with
            searchQuery.type = .endsWith
        }
        
        redoSearchIfPossible()
    }
    
    @IBAction func searchOptionsChangedAction(_ sender: Any) {
        
        searchQuery.options.include(.caseSensitive, if: searchCaseSensitive.isOn)
        redoSearchIfPossible()
    }
}
