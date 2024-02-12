//
//  MainWindowController+EventHandling.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import Cocoa

extension MainWindowController {
    
    private var gesturesPreferences: GesturesControlsPreferences {preferences.controlsPreferences.gestures}
    
    // Registers handlers for keyboard events and trackpad/mouse gestures (NSEvent).
    func setUpEventHandling() {
        
        eventMonitor.registerHandler(forEventType: .keyDown, self.handleKeyDown(_:))
        eventMonitor.registerHandler(forEventType: .scrollWheel, self.handleScroll(_:))
        eventMonitor.registerHandler(forEventType: .swipe, self.handleSwipe(_:))

        eventMonitor.startMonitoring()
    }
    
    // Handles a single key press event. Returns nil if the event has been successfully handled (or needs to be suppressed),
    // returns the same event otherwise.
    func handleKeyDown(_ event: NSEvent) -> NSEvent? {

        // One-off special case: Without this, a space key press (for play/pause) is not sent to main window
        // Send the space key event to the main window unless a modal component is currently displayed
        if event.charactersIgnoringModifiers == " ",
           !windowLayoutsManager.isShowingModalComponent {

            self.window?.keyDown(with: event)
            return nil
        }

        return event
    }

    // Handles a single swipe event
    func handleSwipe(_ event: NSEvent) -> NSEvent? {

        // If a modal dialog is open, don't do anything
        // Also, ignore any gestures that weren't triggered over the main window (they trigger other functions if performed over the playlist window)

        if event.window === self.window,
           !windowLayoutsManager.isShowingModalComponent,
           let swipeDirection = event.gestureDirection, swipeDirection.isHorizontal {

            handleTrackChange(swipeDirection)
        }

        return event
    }

    // Handles a single scroll event
    func handleScroll(_ event: NSEvent) -> NSEvent? {

        // If a modal dialog is open, don't do anything
        // Also, ignore any gestures that weren't triggered over the main window (they trigger other functions if performed over the playlist window)

        // Calculate the direction and magnitude of the scroll (nil if there is no direction information)
        if event.window === self.window,
           !windowLayoutsManager.isShowingModalComponent,
           let scrollDirection = event.gestureDirection {

            // Vertical scroll = volume control, horizontal scroll = seeking
            scrollDirection.isVertical ? handleVolumeControl(event, scrollDirection) : handleSeek(event, scrollDirection)
        }

        return event
    }
    
    func handleTrackChange(_ swipeDirection: GestureDirection) {
        
        if gesturesPreferences.allowTrackChange {
            
            // Publish the command notification
            messenger.publish(swipeDirection == .left ? .Player.previousTrack : .Player.nextTrack)
        }
    }
    
    func handleVolumeControl(_ event: NSEvent, _ scrollDirection: GestureDirection) {
        
        if gesturesPreferences.allowVolumeControl && ScrollSession.validateEvent(timestamp: event.timestamp, eventDirection: scrollDirection) {
        
            // Scroll up = increase volume, scroll down = decrease volume
            messenger.publish(scrollDirection == .up ?.Player.increaseVolume : .Player.decreaseVolume, payload: UserInputMode.continuous)
        }
    }
    
    func handleSeek(_ event: NSEvent, _ scrollDirection: GestureDirection) {
        
        if gesturesPreferences.allowSeeking {
            
            // If no track is playing, seeking cannot be performed
            if playbackInfoDelegate.state.isNotPlayingOrPaused {
                return
            }
            
            // Seeking forward (do not allow residual scroll)
            if scrollDirection == .right && isResidualScroll(event) {
                return
            }
            
            if ScrollSession.validateEvent(timestamp: event.timestamp, eventDirection: scrollDirection) {
        
                // Scroll left = seek backward, scroll right = seek forward
                messenger.publish(scrollDirection == .left ? .Player.seekBackward : .Player.seekForward, payload: UserInputMode.continuous)
            }
        }
    }
    
    /*
        "Residual scrolling" occurs when seeking forward to the end of a playing track (scrolling right), resulting in the next track playing while the scroll is still occurring. Inertia (i.e. the momentum phase of the scroll) can cause scrolling, and hence seeking, to continue after the new track has begun playing. This is undesirable behavior. The scrolling should stop when the new track begins playing.
     
        To prevent residual scrolling, we need to take into account the following variables:
        - the time when the scroll session began
        - the time when the new track began playing
        - the time interval between this event and the last event
     
        Returns a value indicating whether or not this event constitutes residual scroll.
     */
    func isResidualScroll(_ event: NSEvent) -> Bool {
    
        // If the scroll session began before the currently playing track began playing, then it is now invalid and all its future events should be ignored.
        if let playingTrackStartTime = playbackInfoDelegate.playingTrackStartTime,
           let scrollSessionStartTime = ScrollSession.sessionStartTime,
            scrollSessionStartTime < playingTrackStartTime {
        
            // If the time interval between this event and the last one in the scroll session is within the maximum allowed gap between events, it is a part of the previous scroll session
            let lastEventTime = ScrollSession.lastEventTime ?? 0
            
            // If the session is invalid and this event is part of that invalid session, that indicates residual scroll, and the event should not be processed
            if (event.timestamp - lastEventTime) < ScrollSession.maxTimeGapSeconds {
                
                // Mark the timestamp of this event (for future events), but do not process it
                ScrollSession.updateLastEventTime(event)
                return true
            }
        }
        
        // Not residual scroll
        return false
    }
}
