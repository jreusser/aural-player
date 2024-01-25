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
    @State private var volumePerc: Float = 0
    
    init(model: CompactPlayerViewModel) {
        
        self.model = model
        self.volumePerc = model.volume
    }
    
    var body: some View {
        
        ZStack {
            
            sequencingControls
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.leading, 10)
            
            playbackControls
                .frame(maxWidth: .infinity, alignment: .center)
            
            volumeControls
                .frame(maxWidth: .infinity, alignment: .trailing)
                .padding(.trailing, 10)
            
        }
    }
    
    var sequencingControls: some View {
        
        HStack {
            
            Button(action: {
                _ = playQueueDelegate.toggleRepeatMode()
                
            }, label: {
                
                Image(nsImage: model.repeatButtonImage)
                    .resizable()
                    .foregroundColor(Color(model.repeatButtonImageColor))
                    .aspectRatio(contentMode: .fill)
            })
            .buttonStyle(PlainButtonStyle())
            .frame(width: 13, height: 13)
            .help("Repeat")
            
            Button(action: {
                _ = playQueueDelegate.toggleShuffleMode()
                
            }, label: {
                
                Image(systemName: "shuffle")
                    .resizable()
                    .foregroundColor(Color(model.shuffleButtonImageColor))
                    .aspectRatio(contentMode: .fill)
            })
            .buttonStyle(PlainButtonStyle())
            .frame(width: 13, height: 13)
            .padding(.leading, 5)
            .help("Shuffle")
        }
    }
    
    var playbackControls: some View {
        
        HStack {
            
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
                
                Image(nsImage: model.playButtonImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            })
            .buttonStyle(PlainButtonStyle())
            .frame(width: 20, height: 20)
            .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 5))
            .foregroundColor(Color(model.buttonColor))
            .help(model.playButtonTooltip)
            
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
        }
    }
    
    var volumeControls: some View {
        
        HStack {
            
            Button(action: {
                model.muteStateUpdated()
                
            }) {
                
                HStack {
                    Image(nsImage: model.volumeButtonImage)
                        .foregroundColor(Color(model.buttonColor))
                    Spacer().frame(minWidth: 0)
                }
            }
            .buttonStyle(PlainButtonStyle())
            .frame(width: 16, height: 16)
            .help("Mute / Unmute")
            
            // Volume Slider
            
            GeometryReader { geometry in
                
                ZStack(alignment: .leading) {
                    Rectangle()
                        .foregroundColor(Color(model.inactiveControlColor))
                    Rectangle()
                        .foregroundColor(Color(model.activeControlColor))
                        .frame(width: geometry.size.width * CGFloat(volumePerc / 100), height: 4)
                }
            }
            .frame(width: 50, height: 4)
            .gesture(DragGesture(minimumDistance: 0)
                .onChanged({ value in
                    
                    self.volumePerc = min(max(0, Float(value.location.x / 50 * 100)), 100)
                    print("\(volumePerc)%")
                    audioGraphDelegate.volume = volumePerc
                    model.volumeUpdated()
                }))
        }
    }
}

#Preview {
    CompactPlayerControlsView(model: .init())
        .frame(width: 300)
}
