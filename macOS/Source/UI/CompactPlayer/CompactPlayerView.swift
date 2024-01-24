//
//  CompactPlayerView.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import SwiftUI

struct CompactPlayerView: View {
    
    @ObservedObject var model: CompactPlayerViewModel = .init()
    
    var body: some View {
        
        VStack {
            
            CompactPlayerTrackInfoView(model: self.model)
            CompactPlayerControlsView(model: self.model)
                .padding(.bottom, 15)
            
            Spacer()
            
        }
        .frame(width: 300, height: 390)
        .cornerRadius(10)
    }
}

#Preview {
    CompactPlayerView()
}
