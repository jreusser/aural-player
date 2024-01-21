//
//  TuneBrowserHistory.swift
//  Aural
//
//  Copyright © 2023 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Foundation

class TuneBrowserHistory {
    
    var backStack: Stack<FileSystemFolderItem> = Stack()
    var forwardStack: Stack<FileSystemFolderItem> = Stack()
    
    func notePreviousLocation(_ location: FileSystemFolderItem) {
        
        if backStack.peek() != location {
            backStack.push(location)
        }
        
        forwardStack.clear()
    }
    
    func back(from currentLocation: FileSystemFolderItem) -> FileSystemFolderItem? {
        
        if let location = backStack.pop() {
            
            forwardStack.push(currentLocation)
            return location
        }
        
        return nil
    }
    
    func back(to previousLocation: FileSystemFolderItem) {
        
        var poppedURL: FileSystemFolderItem? = nil
        
        repeat {
            
            guard let thePoppedURL = backStack.pop() else {break}
            
            if thePoppedURL != previousLocation {
                forwardStack.push(thePoppedURL)
            }
            
            poppedURL = thePoppedURL
            
        } while poppedURL != previousLocation
    }
    
    var canGoBack: Bool {!backStack.isEmpty}
    
    func forward(from currentLocation: FileSystemFolderItem) -> FileSystemFolderItem? {
        
        if let location = forwardStack.pop() {
            
            backStack.push(currentLocation)
            return location
        }
        
        return nil
    }
    
    var canGoForward: Bool {!forwardStack.isEmpty}
}
