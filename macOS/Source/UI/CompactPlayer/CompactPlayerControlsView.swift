//
//  CompactPlayerControlsView.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import SwiftUI

struct CompactPlayerControlsView: View {
    
    @ObservedObject var model: CompactPlayerViewModel
    
    init(model: CompactPlayerViewModel) {
        self.model = model
    }
    
    var body: some View {
        
        HStack {
            
            Button(action: {
                _ = playQueueDelegate.toggleRepeatMode()
                
            }, label: {
                
                Image(nsImage: imageForRepeatMode())
                    .resizable()
                    .foregroundColor(Color(colorForRepeatModeImage()))
                    .aspectRatio(contentMode: .fit)
            })
            .buttonStyle(PlainButtonStyle())
            .frame(width: 16, height: 16)
            .padding(.leading, 10)
            .help("Repeat")
            
            Spacer()
            
            // Previous Track button
            
            Button(action: {
                playbackDelegate.previousTrack()
                
            }, label: {
                Image(systemName: "backward.end")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            })
            .buttonStyle(PlainButtonStyle())
            .frame(width: 14, height: 14)
            .padding(.trailing, 5)
            .help(model.previousTrackDisplayName)
            
            // Play / Pause button
            
            Button(action: {
                playbackDelegate.togglePlayPause()
                
            }, label: {
                
                Image(nsImage: model.isPlaying ? .imgPause : .imgPlay)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            })
            .buttonStyle(PlainButtonStyle())
            .frame(width: 20, height: 20)
            .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 5))
            .foregroundColor(Color(model.buttonColor))
            .help(model.isPlaying ? "Pause" : "Play")
            
            // Next Track button
            
            Button(action: {
                playbackDelegate.nextTrack()
                
            }, label: {
                Image(systemName: "forward.end")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            })
            .buttonStyle(PlainButtonStyle())
            .frame(width: 14, height: 14)
            .help(model.nextTrackDisplayName)
            
            Spacer()
        }
    }
    
    private func imageForRepeatMode() -> NSImage {
        
        switch model.repeatMode {
            
        case .off:
            return .imgRepeat
            
        case .all:
            return .imgRepeat
            
        case .one:
            return .imgRepeatOne
        }
    }
    
    private func colorForRepeatModeImage() -> NSColor {
        model.repeatMode == .off ? model.buttonColor : model.activeControlColor
    }
}

#Preview {
    CompactPlayerControlsView(model: .init())
}
