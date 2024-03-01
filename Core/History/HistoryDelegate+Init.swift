////
////  HistoryDelegate+Init.swift
////  Aural
////
////  Copyright © 2024 Kartik Venugopal. All rights reserved.
////
////  This software is licensed under the MIT software license.
////  See the file "LICENSE" in the project root directory for license terms.
////  
//
//import Foundation
//
//extension HistoryDelegate {
//    
//    func initialize(fromPersistentState persistentState: HistoryPersistentState?) {
//        
//        // Restore the history model object from persistent state.
//        guard let persistentState = persistentState else {return}
//        
//        // Move to a background thread to unblock the main thread.
//        DispatchQueue.global(qos: .utility).async {
//            
//            // TODO: Recently Added
//            
//            let recentlyPlayed = persistentState.recentlyPlayed ?? []
//            
//            for state in recentlyPlayed.reversed() {
//                
//                guard let itemType = state.itemType, let lastEventTime = state.lastEventTime, let eventCount = state.eventCount else {continue}
//                
//                var item: HistoryItem? = nil
//                
//                switch itemType {
//                    
//                case .track:
//                    
//                    guard let trackFile = state.trackFile else {continue}
//                    
//                    let track = Track(trackFile)
//                    item = TrackHistoryItem(track: track, lastEventTime: lastEventTime, eventCount: eventCount)
//                    
//                    TrackLoader.mediumPriorityQueue.addOperation {
//                        
//                        do {
//                            
//                            let metadata = try fileReader.getPrimaryMetadata(for: trackFile)
//                            track.setPrimaryMetadata(from: FileMetadata(primary: metadata))
//                            
//                        } catch {
//                            NSLog("Failed to read track metadata for file: '\(trackFile.path)'")
//                        }
//                    }
//                    
//                case .playlistFile:
//                    
//                    if let playlistFile = state.playlistFile {
//                        item = PlaylistFileHistoryItem(playlistFile: playlistFile, lastEventTime: lastEventTime, eventCount: eventCount)
//                    }
//                    
//                case .folder:
//                    
//                    if let folder = state.folder {
//                        item = FolderHistoryItem(folder: folder, lastEventTime: lastEventTime, eventCount: eventCount)
//                    }
//                    
//                case .group:
//                    
//                    if let groupName = state.groupName, let groupType = state.groupType {
//                        item = GroupHistoryItem(groupName: groupName, groupType: groupType, lastEventTime: lastEventTime, eventCount: eventCount)
//                    }
//                }
//                
//                if let theItem = item {
////                    self.recentlyPlayedItems[theItem.key] = theItem
//                }
//            }
//        }
//    }
//}
