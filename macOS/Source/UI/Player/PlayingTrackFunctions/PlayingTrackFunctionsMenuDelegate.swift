//
//  PlayingTrackFunctionsMenuDelegate.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

/*
    View controller for the functions toolbar that is displayed whenever a track is currently playing.
    Handles functions relevant to the playing track, such as favoriting, bookmarking, viewing detailed info, etc.
 
    Also handles such requests from app menus.
 */
class PlayingTrackFunctionsMenuDelegate: NSObject, NSMenuDelegate {
    
    @IBOutlet weak var btnMenu: TintedIconMenuItem!
    
    // Button to add/remove the currently playing track to/from the Favorites list
    @IBOutlet weak var favoritesMenuItem: ToggleMenuItem!
    
    @IBOutlet weak var sliderView: WindowedModeSeekSliderView!
    @IBOutlet weak var seekPositionMarkerView: NSView!
    
    @IBOutlet weak var playerWindowRootView: NSView!
    
    // Delegate that provides info about the playing track
    private lazy var player: PlaybackInfoDelegateProtocol = playbackInfoDelegate
    
    // Delegate that provides access to the Favorites track list.
    private lazy var favorites: FavoritesDelegateProtocol = favoritesDelegate
    
    // Popup view that displays a brief notification when the currently playing track is added/removed to/from the Favorites list
    private lazy var infoPopup: InfoPopupViewController = InfoPopupViewController.instance
    
    private lazy var bookmarkInputReceiver: BookmarkNameInputReceiver = BookmarkNameInputReceiver()
    private lazy var bookmarkNamePopover: StringInputPopoverViewController = StringInputPopoverViewController.create(bookmarkInputReceiver)
    
    private lazy var messenger = Messenger(for: self)
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        
        updateFavoriteButtonState()
        colorSchemesManager.registerObservers([btnMenu], forProperty: \.buttonColor)
        
        // Subscribe to various notifications
        
        messenger.subscribe(to: .favoritesList_trackAdded, handler: trackAddedToFavorites(_:))
        messenger.subscribe(to: .favoritesList_tracksRemoved, handler: tracksRemovedFromFavorites(_:))
        
        messenger.subscribe(to: .player_moreInfo, handler: moreInfo)
        messenger.subscribe(to: .favoritesList_addOrRemove, handler: addOrRemoveFavorite)
        messenger.subscribe(to: .player_bookmarkPosition, handler: bookmarkPosition)
        messenger.subscribe(to: .player_bookmarkLoop, handler: bookmarkLoop)
    }
    
    func menuWillOpen(_ menu: NSMenu) {
        updateFavoriteButtonState()
    }
    
    private func updateFavoriteButtonState() {
        
        if let playingTrack = player.playingTrack {
            favoritesMenuItem.onIf(favorites.favoriteWithFileExists(playingTrack.file))
        }
    }
    
    func destroy() {
        
        TrackInfoWindowController.destroy()
        messenger.unsubscribeFromAll()
    }
    
    private func moreInfo() {
        moreInfoAction(self)
    }
    
    // Shows a popover with detailed information for the currently playing track, if there is one
    @IBAction func moreInfoAction(_ sender: AnyObject) {
        
        // If there is a track currently playing, load detailed track info and toggle the popover view
        guard let playingTrack = player.playingTrack else {return}
                
        trackReader.loadAuxiliaryMetadata(for: playingTrack)
        TrackInfoViewContext.displayedTrack = playingTrack
        windowLayoutsManager.showWindow(withId: .trackInfo)
    }
    
    // Shows (selects) the currently playing track, within the playlist, if there is one
    @IBAction func showPlayingTrackAction(_ sender: Any) {
        messenger.publish(.playQueue_showPlayingTrack)
    }
    
    // Adds/removes the currently playing track to/from the "Favorites" list
    @IBAction func favoriteAction(_ sender: Any) {
        addOrRemoveFavorite()
    }
    
    private func addOrRemoveFavorite() {
        
        guard let playingTrack = player.playingTrack else {return}

        // Toggle the button state
        if favorites.favoriteWithFileExists(playingTrack.file) {
            favorites.deleteFavoriteWithFile(playingTrack.file)
            
        } else {
            _ = favorites.addFavorite(playingTrack)
        }
    }
    
    // Adds the currently playing track position to/from the "Bookmarks" list
    @IBAction func bookmarkAction(_ sender: Any) {
        
        if let playingTrack = player.playingTrack {
            doBookmark(playingTrack, player.seekPosition.timeElapsed)
        }
    }
    
    private func bookmarkPosition() {
        bookmarkAction(self)
    }
    
    // When a bookmark menu item is clicked, the item is played
    private func bookmarkLoop() {
        
        // Check if we have a complete loop
        if let playingTrack = player.playingTrack, let loop = player.playbackLoop, let loopEndTime = loop.endTime {
            doBookmark(playingTrack, loop.startTime, loopEndTime)
        }
    }
    
    private func doBookmark(_ playingTrack: Track, _ startTime: Double, _ endTime: Double? = nil) {
        
        let formattedStartTime: String = ValueFormatter.formatSecondsToHMS(startTime)
        let defaultBookmarkName: String
        
        if let theEndTime = endTime {
            
            // Loop
            let formattedEndTime: String = ValueFormatter.formatSecondsToHMS(theEndTime)
            defaultBookmarkName = "\(playingTrack.displayName) (\(formattedStartTime) ⇄ \(formattedEndTime))"
            
        } else {
            
            // Single position
            defaultBookmarkName = "\(playingTrack.displayName) (\(formattedStartTime))"
        }
        
        bookmarkInputReceiver.context = BookmarkInputContext(track: playingTrack, startPosition: startTime,
                                                             endPosition: endTime, defaultName: defaultBookmarkName)
        
        // Show popover
        
        let autoHideIsOn: Bool = playerUIState.viewType == .expandedArt || !playerUIState.showControls
        
        windowLayoutsManager.mainWindow.makeKeyAndOrderFront(self)
        
        // If controls are being auto-hidden, don't display popover relative to any view within the window. Show it relative to the window itself.
        if autoHideIsOn {

            // Show popover relative to window
            bookmarkNamePopover.show(playerWindowRootView, NSRectEdge.maxX)
            
        } else {
            
            sliderView.positionSeekPositionMarkerView()
            
            // Show popover relative to seek slider
            if seekPositionMarkerView.isVisible {
                bookmarkNamePopover.show(seekPositionMarkerView, NSRectEdge.maxY)

            } // Show popover relative to window
            else {
                bookmarkNamePopover.show(playerWindowRootView, NSRectEdge.maxX)
            }
        }
    }
    
    func trackAddedToFavorites(_ favorite: Favorite) {
        favoritesUpdated([favorite.file], true)
    }
    
    func tracksRemovedFromFavorites(_ removedFavorites: Set<Favorite>) {
        favoritesUpdated(Set(removedFavorites.map {$0.file}), false)
    }
    
    // Responds to a notification that a track has been added to / removed from the Favorites list, by updating the UI to reflect the new state
    private func favoritesUpdated(_ updatedFavoritesFiles: Set<URL>, _ added: Bool) {
        
        // Do this only if the track in the message is the playing track
        guard let playingTrack = player.playingTrack, updatedFavoritesFiles.contains(playingTrack.file) else {return}
        
        // TODO: Is this really required ???
        windowLayoutsManager.mainWindow.makeKeyAndOrderFront(self)
        
        updateFavoriteButtonState()
        
        infoPopup.showMessage(added ? "Track added to Favorites !" : "Track removed from Favorites !",
                                  playerWindowRootView, .maxX)
    }
}
