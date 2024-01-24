//
//  CompactPlayerTrackInfoView.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import SwiftUI

struct CompactPlayerTrackInfoView: View {
    
    @ObservedObject var model: CompactPlayerViewModel
    
    init(model: CompactPlayerViewModel) {
        self.model = model
    }
    
    var body: some View {
        
        VStack {
            
            Image(nsImage: model.coverArt)
                .resizable()
                .cornerRadius(8)
                .aspectRatio(contentMode: .fit)
                .frame(width: 280, height: 280)
                .padding(10)
            
            HStack {
                
                if #available(macOS 12, *) {
                    
                    Text(AttributedString(artistTitleAttributedString))
                        .lineLimit(1).truncationMode(.tail)
                        .padding(.leading, 12)
                    
                } else {
                    
                    Text(artistTitleString)
                        .lineLimit(1).truncationMode(.tail)
                        .foregroundColor(Color(model.primaryTextColor))
                        .font(Font(model.secondaryTextFont))
                        .padding(.leading, 12)
                }
                
                Spacer()
                
                Text(model.seekPositionText)
                    .padding(.trailing, 12)
                    .font(Font(model.secondaryTextFont))
                    .foregroundColor(Color(model.secondaryTextColor))
            }
            
            Spacer()
        }
    }
    
    private var artistTitleString: String {
        
        if let artist = model.artist {
            return "\(artist)  \(model.title)"
        } else {
            return model.title
        }
    }
    
    @available(macOS 12, *)
    private var artistTitleAttributedString: NSAttributedString {
        
        if let artist = model.artist {
            
            return (artist + "   ").attributed(font: model.secondaryTextFont, color: model.secondaryTextColor) + model.title.attributed(font: model.secondaryTextFont, color: model.primaryTextColor)
            
        } else {
            
            return model.title.attributed(font: model.secondaryTextFont, color: model.primaryTextColor)
        }
    }
}

#Preview {
    CompactPlayerTrackInfoView(model: .init())
}
