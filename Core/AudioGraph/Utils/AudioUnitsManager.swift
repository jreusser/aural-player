//
//  AudioUnitsManager.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import AVFoundation

///
/// Utility class that determines which Audio Units (AU) plug-ins that are supported by the app are installed on the local system.
///
class AudioUnitsManager {
    
    private let componentManager: AVAudioUnitComponentManager = .shared()
    
    let audioUnits: [AVAudioUnitComponent]
    
    private static let componentsBlackList: Set<String> = ["AUNewPitch", "AURoundTripAAC", "AUNetSend"]
    private static let acceptedComponentTypes: Set<OSType> = [kAudioUnitType_Effect, kAudioUnitType_MusicEffect, kAudioUnitType_Panner]
    
    init() {
        
        #if os(macOS)
        
        self.audioUnits = componentManager.components {component, _ in
            
            Self.acceptedComponentTypes.contains(component.componentType) &&
                component.hasCustomView &&
                !Self.componentsBlackList.contains(component.name)
            
        }.sorted(by: {$0.name < $1.name})
        
        #elseif os(iOS)
        
        self.audioUnits = []
        
#endif
    }
    
    func audioUnit(ofType type: OSType, andSubType subType: OSType) -> AVAudioUnitComponent? {
        audioUnits.first(where: {$0.componentType == type && $0.componentSubType == subType})
    }
}
